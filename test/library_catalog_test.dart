import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:image/image.dart' as img;
import 'package:oiv/core/sidecar/picavi_sidecar_store.dart';
import 'package:oiv/editor/domain/entities/edit_operation.dart';
import 'package:oiv/editor/domain/entities/image_edits.dart';
import 'package:oiv/library/data/repositories/sqlite_catalog_repository.dart';
import 'package:oiv/library/data/services/file_system_library_indexer.dart';
import 'package:oiv/library/domain/entities/catalog_image.dart';
import 'package:oiv/library/domain/entities/library_query.dart';
import 'package:oiv/library/domain/entities/photo_info.dart';
import 'package:path/path.dart' as p;

CatalogImage photo(
  String path, {
  int size = 10,
  int modified = 0,
  DateTime? taken,
  String? camera,
  PhotoInfo info = PhotoInfo.none,
}) => CatalogImage(
  path: path,
  folder: p.dirname(path),
  name: p.basename(path),
  stamp: FileStamp(size, modified),
  taken: taken,
  camera: camera,
  info: info,
);

void main() {
  group('SqliteCatalogRepository', () {
    late SqliteCatalogRepository catalog;

    setUp(() => catalog = SqliteCatalogRepository.inMemory());
    tearDown(() => catalog.close());

    test('upserts, lists folders and searches by every field', () async {
      await catalog.upsert([
        photo(
          '/lib/goa/beach.jpg',
          taken: DateTime(2019, 7, 14),
          camera: 'Canon EOS R',
        ),
        photo(
          '/lib/goa/fort.jpg',
          taken: DateTime(2019, 7, 15),
          info: const PhotoInfo(
            starred: true,
            caption: 'Old fort',
            tags: ['history'],
          ),
        ),
        photo(
          '/lib/home/cat.png',
          modified: DateTime(2021, 1, 1).millisecondsSinceEpoch,
        ),
      ]);

      final folders = await catalog.folders(const LibraryQuery());
      expect(folders.map((f) => (f.path, f.imageCount)), [
        ('/lib/goa', 2),
        ('/lib/home', 1),
      ]);

      Future<List<String>> names(LibraryQuery query) async => [
        for (final image in await catalog.search(query)) image.name,
      ];

      expect(await names(const LibraryQuery()), [
        'cat.png',
        'fort.jpg',
        'beach.jpg',
      ]);
      expect(await names(const LibraryQuery(text: 'canon')), ['beach.jpg']);
      expect(await names(const LibraryQuery(text: 'HISTORY fort')), [
        'fort.jpg',
      ]);
      expect(await names(const LibraryQuery(text: '2019-07')), [
        'fort.jpg',
        'beach.jpg',
      ]);
      expect(await names(const LibraryQuery(text: 'goa beach')), ['beach.jpg']);
      expect(await names(const LibraryQuery(text: '50%')), isEmpty);
      expect(await names(const LibraryQuery(starredOnly: true)), ['fort.jpg']);
      expect(await names(const LibraryQuery(folder: '/lib/goa')), [
        'beach.jpg',
        'fort.jpg',
      ]);
    });

    test('hidden photos and folders are left out unless asked for', () async {
      await catalog.upsert([
        photo('/lib/a/1.jpg', info: const PhotoInfo(hidden: true)),
        photo('/lib/a/2.jpg'),
        photo('/lib/b/3.jpg'),
      ]);

      final visible = await catalog.search(
        const LibraryQuery(hiddenFolders: {'/lib/b'}),
      );
      expect(visible.map((i) => i.name), ['2.jpg']);
      expect(
        await catalog.search(
          const LibraryQuery(includeHidden: true, hiddenFolders: {'/lib/b'}),
        ),
        hasLength(3),
      );
      expect(
        (await catalog.folders(
          const LibraryQuery(hiddenFolders: {'/lib/b'}),
        )).map((f) => f.path),
        ['/lib/a'],
      );
    });

    test('imagesUnder and removeOutside respect folder boundaries', () async {
      await catalog.upsert([
        photo('/lib/a/1.jpg'),
        photo('/lib/a/deep/2.jpg'),
        photo('/lib/ab/3.jpg'),
      ]);

      expect((await catalog.imagesUnder('/lib/a')).keys.toSet(), {
        '/lib/a/1.jpg',
        '/lib/a/deep/2.jpg',
      });

      await catalog.removeOutside(['/lib/ab']);
      expect((await catalog.search(const LibraryQuery())).map((i) => i.path), [
        '/lib/ab/3.jpg',
      ]);
    });

    test('updates info and edits in place', () async {
      await catalog.upsert([photo('/lib/a/1.jpg')]);

      await catalog.updateInfo('/lib/a/1.jpg', const PhotoInfo(tags: ['x']));
      await catalog.updateEdits(
        '/lib/a/1.jpg',
        const ImageEdits([EffectEdit(EffectKind.sepia, 1)]),
      );

      final image = (await catalog.image('/lib/a/1.jpg'))!;
      expect(image.info.tags, ['x']);
      expect(
        image.edits.operations.single,
        const EffectEdit(EffectKind.sepia, 1),
      );
      expect(
        (await catalog.search(const LibraryQuery(text: 'x'))),
        hasLength(1),
      );
    });

    test('albums keep their order and survive missing photos', () async {
      await catalog.upsert([
        photo('/lib/a/1.jpg'),
        photo('/lib/a/2.jpg'),
        photo('/lib/a/3.jpg'),
      ]);
      final album = await catalog.createAlbum('Trip');

      await catalog.addToAlbum(album.id, ['/lib/a/3.jpg', '/lib/a/1.jpg']);
      await catalog.addToAlbum(album.id, ['/lib/a/2.jpg', '/lib/a/1.jpg']);
      expect(
        (await catalog.search(
          LibraryQuery(albumId: album.id),
        )).map((i) => i.name),
        ['3.jpg', '1.jpg', '2.jpg'],
      );

      await catalog.remove(['/lib/a/3.jpg']);
      await catalog.removeFromAlbum(album.id, ['/lib/a/1.jpg']);
      await catalog.renameAlbum(album.id, 'Goa');
      final albums = await catalog.albums();
      expect(albums.single.name, 'Goa');
      expect(albums.single.imageCount, 1);
      expect(albums.single.coverPath, '/lib/a/2.jpg');

      await catalog.deleteAlbum(album.id);
      expect(await catalog.albums(), isEmpty);
      expect(await catalog.search(const LibraryQuery()), hasLength(2));
    });

    test('same-size candidates', () async {
      await catalog.upsert([
        photo('/a/1.jpg', size: 5),
        photo('/a/2.jpg', size: 5),
        photo('/a/3.jpg', size: 6),
      ]);

      expect((await catalog.sameSizeCandidates()).map((i) => i.name), [
        '1.jpg',
        '2.jpg',
      ]);
    });

    test('a corrupt catalog file is set aside', () async {
      final dir = await Directory.systemTemp.createTemp('oiv_catalog');
      addTearDown(() => dir.delete(recursive: true));
      final path = p.join(dir.path, 'catalog.db');
      await File(path).writeAsString('this is not a database' * 100);

      final reopened = SqliteCatalogRepository.open(path);
      await reopened.upsert([photo('/a/1.jpg')]);

      expect(await reopened.search(const LibraryQuery()), hasLength(1));
      await reopened.close();
    });
  });

  group('FileSystemLibraryIndexer', () {
    late Directory root;
    late SqliteCatalogRepository catalog;

    setUp(() async {
      root = await Directory.systemTemp.createTemp('oiv_index');
      catalog = SqliteCatalogRepository.inMemory();
    });

    tearDown(() async {
      await catalog.close();
      await root.delete(recursive: true);
    });

    Future<String> jpeg(String relative, {String? taken, String? model}) async {
      final image = img.Image(width: 4, height: 4);
      if (taken != null) {
        image.exif.exifIfd['DateTimeOriginal'] = img.IfdValueAscii(taken);
      }
      if (model != null) {
        image.exif.imageIfd['Model'] = img.IfdValueAscii(model);
      }
      final file = File(p.join(root.path, relative));
      await file.parent.create(recursive: true);
      await file.writeAsBytes(img.encodeJpg(image));
      return file.path;
    }

    Future<List<IndexProgress>> run([List<String>? roots]) =>
        FileSystemLibraryIndexer(
          catalog,
          extensions: {'.jpg', '.png'},
          batchSize: 2,
        ).index(roots ?? [root.path]).toList();

    test(
      'indexes photos with EXIF, sidecar info, skipping hidden folders',
      () async {
        final beach = await jpeg(
          'goa/beach.jpg',
          taken: '2019:07:14 18:02:11',
          model: 'Pixel 7',
        );
        await jpeg('goa/fort.jpg');
        await jpeg('.cache/thumb.jpg');
        await File(p.join(root.path, 'goa', 'notes.txt')).writeAsString('x');
        await const PicaviSidecarStore().update(p.join(root.path, 'goa'), (
          entries,
        ) {
          entries['beach.jpg'] = {
            'starred': true,
            'edits': [
              {'op': 'rotate', 'turns': 1},
            ],
          };
        });

        final progress = await run();

        expect(progress.last.done, isTrue);
        expect(progress.last.found, 2);
        expect(progress.last.processed, 2);
        final indexed = (await catalog.image(beach))!;
        expect(indexed.taken, DateTime(2019, 7, 14, 18, 2, 11));
        expect(indexed.camera, 'Pixel 7');
        expect(indexed.info.starred, isTrue);
        expect(indexed.edits.operations.single, const RotateEdit(1));
        expect(await catalog.search(const LibraryQuery()), hasLength(2));
      },
    );

    test(
      're-indexing removes deleted photos and picks up sidecar changes',
      () async {
        final beach = await jpeg('goa/beach.jpg');
        final fort = await jpeg('goa/fort.jpg');
        await run();

        await File(fort).delete();
        await const PicaviSidecarStore().update(p.dirname(beach), (entries) {
          entries['beach.jpg'] = {'caption': 'Sunset'};
        });
        await run();

        final all = await catalog.search(const LibraryQuery());
        expect(all.map((i) => i.path), [beach]);
        expect(all.single.info.caption, 'Sunset');
      },
    );

    test('removing a root drops its photos; nested roots are merged', () async {
      await jpeg('a/1.jpg');
      await jpeg('b/2.jpg');
      final a = p.join(root.path, 'a');

      expect(FileSystemLibraryIndexer.normalizeRoots([a, root.path, '$a/']), [
        root.path,
      ]);

      await run();
      expect(await catalog.search(const LibraryQuery()), hasLength(2));
      await run([a]);
      expect((await catalog.search(const LibraryQuery())).map((i) => i.name), [
        '1.jpg',
      ]);
    });

    test('a missing root just indexes nothing', () async {
      final progress = await run([p.join(root.path, 'gone')]);

      expect(progress.last.done, isTrue);
      expect(progress.last.found, 0);
    });
  });

  test('parseExifDate rejects empty dates', () {
    expect(
      parseExifDate('2019:07:14 18:02:11'),
      DateTime(2019, 7, 14, 18, 2, 11),
    );
    expect(parseExifDate('0000:00:00 00:00:00'), isNull);
    expect(parseExifDate('garbage'), isNull);
  });
}
