import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:oiv/library/data/repositories/sqlite_catalog_repository.dart';
import 'package:oiv/library/data/services/hashing_duplicate_finder.dart';
import 'package:oiv/library/domain/entities/catalog_image.dart';
import 'package:path/path.dart' as p;

void main() {
  late Directory root;
  late SqliteCatalogRepository catalog;

  setUp(() async {
    root = await Directory.systemTemp.createTemp('oiv_dupes');
    catalog = SqliteCatalogRepository.inMemory();
  });

  tearDown(() async {
    await catalog.close();
    await root.delete(recursive: true);
  });

  Future<void> add(String name, String body) async {
    final path = p.join(root.path, name);
    await File(path).writeAsString(body);
    await catalog.upsert([
      CatalogImage(
        path: path,
        folder: root.path,
        name: name,
        stamp: FileStamp(body.length, 0),
      ),
    ]);
  }

  test('groups identical files, ignoring same-size different ones', () async {
    await add('a.jpg', 'same body');
    await add('b.jpg', 'same body');
    await add('c.jpg', 'diff body');
    await add('d.jpg', 'unique and longer');
    await add('e.jpg', 'xx');
    await add('f.jpg', 'xx');
    final progress = <(int, int)>[];

    final groups = await HashingDuplicateFinder(
      catalog,
      batchSize: 2,
    ).find(onProgress: (checked, total) => progress.add((checked, total)));

    expect(groups.map((g) => g.map((i) => i.name).toList()), [
      ['a.jpg', 'b.jpg'],
      ['e.jpg', 'f.jpg'],
    ]);
    expect(progress.first, (0, 5));
    expect(progress.last, (5, 5));
  });

  test('files that vanished are skipped', () async {
    await add('a.jpg', 'same');
    await add('b.jpg', 'same');
    await File(p.join(root.path, 'b.jpg')).delete();

    expect(await HashingDuplicateFinder(catalog).find(), isEmpty);
  });
}
