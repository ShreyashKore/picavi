import 'dart:io';

import 'package:exif/exif.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:oiv/library/data/repositories/sidecar_photo_info_repository.dart';
import 'package:oiv/library/data/repositories/sqlite_catalog_repository.dart';
import 'package:oiv/library/data/services/file_system_library_indexer.dart';
import 'package:oiv/library/domain/entities/catalog_image.dart';
import 'package:oiv/library/domain/entities/geo_point.dart';
import 'package:oiv/library/domain/entities/library_query.dart';
import 'package:oiv/library/domain/entities/photo_info.dart';
import 'package:oiv/library/presentation/controllers/library_controller.dart';
import 'package:oiv/library/presentation/models/place_clusters.dart';
import 'package:path/path.dart' as p;
import 'package:sqlite3/sqlite3.dart';

import 'support/editor_fakes.dart';
import 'support/library_fakes.dart';

CatalogImage located(String path, {GeoPoint? gps, GeoPoint? manual}) =>
    CatalogImage(
      path: path,
      folder: p.dirname(path),
      name: p.basename(path),
      stamp: const FileStamp(1, 0),
      gps: gps,
      info: PhotoInfo(location: manual),
    );

void main() {
  const goa = GeoPoint(15.5, 73.8);
  const paris = GeoPoint(48.8566, 2.3522);

  test('parses EXIF GPS degrees, minutes, seconds and hemispheres', () {
    final point = parseExifGps(
      [Ratio(48, 1), Ratio(51, 1), Ratio(2376, 100)],
      'N',
      [Ratio(2, 1), Ratio(21, 1), Ratio(768, 100)],
      'E',
    )!;
    expect(point.latitude, closeTo(48.8566, 1e-4));
    expect(point.longitude, closeTo(2.3521, 1e-4));

    final south = parseExifGps(
      [Ratio(33, 1), Ratio(52, 1), Ratio(0, 1)],
      'S',
      [Ratio(151, 1), Ratio(12, 1), Ratio(0, 1)],
      'W',
    )!;
    expect(south.latitude, lessThan(0));
    expect(south.longitude, lessThan(0));

    expect(parseExifGps([Ratio(0, 1)], 'N', [Ratio(0, 1)], 'E'), isNull);
    expect(parseExifGps(null, null, null, null), isNull);
    expect(parseExifGps([Ratio(1, 0)], 'N', [Ratio(1, 1)], 'E'), isNull);
  });

  test(
    'a location set by hand wins over GPS and round-trips the sidecar',
    () async {
      expect(located('/a.jpg', gps: goa, manual: paris).location, paris);
      expect(located('/a.jpg', gps: goa).location, goa);

      final dir = await Directory.systemTemp.createTemp('oiv_place');
      addTearDown(() => dir.delete(recursive: true));
      const repo = SidecarPhotoInfoRepository();
      final path = p.join(dir.path, 'a.jpg');
      await repo.save(path, const PhotoInfo(location: paris));
      expect((await repo.load(path)).location, paris);
      await repo.save(path, PhotoInfo.none);
      expect(await repo.loadDirectory(dir.path), isEmpty);
    },
  );

  test('catalog filters by location and bounds', () async {
    final catalog = SqliteCatalogRepository.inMemory();
    addTearDown(catalog.close);
    await catalog.upsert([
      located('/p/goa.jpg', gps: goa),
      located('/p/paris.jpg', manual: paris),
      located('/p/nowhere.jpg'),
    ]);

    final withLocation = await catalog.search(
      const LibraryQuery(onlyWithLocation: true),
    );
    expect(withLocation.map((i) => i.name).toSet(), {'goa.jpg', 'paris.jpg'});
    expect(
      withLocation.firstWhere((i) => i.name == 'paris.jpg').location,
      paris,
    );

    final europe = await catalog.search(
      const LibraryQuery(
        bounds: GeoBounds(south: 35, west: -10, north: 60, east: 30),
      ),
    );
    expect(europe.map((i) => i.name), ['paris.jpg']);
  });

  test('upgrades a version 1 catalog in place', () async {
    final dir = await Directory.systemTemp.createTemp('oiv_migrate');
    addTearDown(() => dir.delete(recursive: true));
    final path = p.join(dir.path, 'catalog.sqlite');
    final old = sqlite3.open(path);
    old.execute('''
      CREATE TABLE images (path TEXT PRIMARY KEY, folder TEXT NOT NULL,
        name TEXT NOT NULL, size INTEGER NOT NULL, modified INTEGER NOT NULL,
        taken INTEGER, camera TEXT, starred INTEGER NOT NULL DEFAULT 0,
        caption TEXT NOT NULL DEFAULT '', tags TEXT NOT NULL DEFAULT '[]',
        hidden INTEGER NOT NULL DEFAULT 0, edits TEXT NOT NULL DEFAULT '[]',
        search TEXT NOT NULL DEFAULT '');
      CREATE TABLE albums (id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL, created INTEGER NOT NULL);
      CREATE TABLE album_items (album_id INTEGER NOT NULL, path TEXT NOT NULL,
        position INTEGER NOT NULL, PRIMARY KEY (album_id, path));
      INSERT INTO images (path, folder, name, size, modified, starred)
        VALUES ('/p/old.jpg', '/p', 'old.jpg', 5, 0, 1);
      INSERT INTO albums (name, created) VALUES ('Kept', 0);
      PRAGMA user_version = 1;
    ''');
    old.close();

    final catalog = SqliteCatalogRepository.open(path);
    addTearDown(catalog.close);

    final kept = (await catalog.image('/p/old.jpg'))!;
    expect(kept.info.starred, isTrue);
    expect(kept.location, isNull);
    expect((await catalog.albums()).single.name, 'Kept');
    await catalog.upsert([located('/p/new.jpg', gps: goa)]);
    expect(
      await catalog.search(const LibraryQuery(onlyWithLocation: true)),
      hasLength(1),
    );
  });

  test('clusters merge nearby photos when zoomed out', () {
    final images = [
      located('/1.jpg', gps: goa),
      located('/2.jpg', gps: const GeoPoint(15.51, 73.81)),
      located('/3.jpg', gps: paris),
      located('/4.jpg'),
    ];

    final world = clusterPlaces(images, 3);
    expect(world.map((c) => c.images.length), [2, 1]);

    final street = clusterPlaces(images, 17);
    expect(street, hasLength(3));
  });

  test('the library sets and removes locations on the selection', () async {
    final fixture = LibraryFixture(
      [located('/pics/a.jpg', gps: goa)],
      roots: ['/pics'],
    );
    final info = InMemoryPhotoInfoRepository();
    final controller = LibraryController(
      catalog: fixture.catalog,
      indexer: fixture.indexer,
      settings: fixture.settings,
      photoInfo: info,
      fileOperations: fixture.files,
      duplicateFinder: fixture.duplicates,
    );
    addTearDown(controller.dispose);
    await controller.open();
    await pumpEventQueue();
    await controller.showPlaces();
    expect(controller.state.images, hasLength(1));

    controller.select('/pics/a.jpg');
    await controller.setSelectionLocation(paris);
    expect(info.stored['/pics/a.jpg']?.location, paris);
    expect(controller.state.images.single.location, paris);

    await controller.setSelectionLocation(null);
    expect(info.stored, isEmpty);
    expect(controller.state.images.single.location, goa);
  });
}
