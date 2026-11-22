import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:oiv/viewer/data/repositories/file_system_image_repository.dart';
import 'package:oiv/viewer/domain/entities/image_sort_order.dart';
import 'package:oiv/viewer/domain/utils/natural_compare.dart';
import 'package:path/path.dart' as p;

void main() {
  late Directory directory;
  final repository = FileSystemImageRepository();

  setUp(() async {
    directory = await Directory.systemTemp.createTemp('oiv_repo_test');
  });

  tearDown(() async {
    await directory.delete(recursive: true);
  });

  Future<void> writeImage(String name, {int bytes = 1, DateTime? modified}) {
    final file = File(p.join(directory.path, name));
    return file.writeAsBytes(List<int>.filled(bytes, 0)).then((_) async {
      if (modified != null) {
        await file.setLastModified(modified);
      }
    });
  }

  Future<List<String>> namesFor(ImageSortOrder order) async {
    final images = await repository.readImagesFromDirectory(
      directory.path,
      sortOrder: order,
    );
    return images.map((image) => image.fileName).toList();
  }

  test('sorts names naturally and ignores unsupported files', () async {
    await writeImage('IMG_10.jpg');
    await writeImage('img_2.png');
    await writeImage('IMG_1.jpg');
    await writeImage('notes.txt');

    expect(await namesFor(const ImageSortOrder()), <String>[
      'IMG_1.jpg',
      'img_2.png',
      'IMG_10.jpg',
    ]);
  });

  test('lists HEIC/TIFF/AVIF only where the system can decode them', () async {
    await writeImage('a.heic');
    await writeImage('b.tiff');
    await writeImage('c.avif');
    await writeImage('d.jpg');

    final names = await namesFor(const ImageSortOrder());

    expect(
      names,
      Platform.isMacOS
          ? <String>['a.heic', 'b.tiff', 'c.avif', 'd.jpg']
          : <String>['d.jpg'],
    );
  });

  test('sorts by size and by modified date in both directions', () async {
    final now = DateTime(2026, 1, 1);
    await writeImage('a.png', bytes: 30, modified: now);
    await writeImage(
      'b.png',
      bytes: 10,
      modified: now.subtract(const Duration(days: 2)),
    );
    await writeImage(
      'c.png',
      bytes: 20,
      modified: now.subtract(const Duration(days: 1)),
    );

    expect(
      await namesFor(const ImageSortOrder(field: ImageSortField.size)),
      <String>['b.png', 'c.png', 'a.png'],
    );
    expect(
      await namesFor(
        const ImageSortOrder(field: ImageSortField.modified, ascending: false),
      ),
      <String>['a.png', 'c.png', 'b.png'],
    );
  });

  test('sorts by type, then by name', () async {
    await writeImage('b.png');
    await writeImage('a.png');
    await writeImage('c.gif');

    expect(
      await namesFor(const ImageSortOrder(field: ImageSortField.type)),
      <String>['c.gif', 'a.png', 'b.png'],
    );
  });

  test('watchDirectory reports added and removed images only', () async {
    await writeImage('a.png');
    var events = 0;
    final subscription = repository
        .watchDirectory(directory.path)
        .listen((_) => events += 1);
    addTearDown(subscription.cancel);
    // Give the OS watcher time to start; macOS replays recent history
    // (the creation of a.png) on start, which isn't what we're testing.
    await Future<void>.delayed(const Duration(milliseconds: 300));
    events = 0;

    await File(p.join(directory.path, 'notes.txt')).writeAsString('x');
    await Future<void>.delayed(const Duration(milliseconds: 600));
    expect(events, 0, reason: 'unsupported files are ignored');

    await writeImage('b.png');
    await Future<void>.delayed(const Duration(milliseconds: 600));
    expect(events, greaterThan(0), reason: 'new image reported');

    events = 0;
    await File(p.join(directory.path, 'a.png')).delete();
    await Future<void>.delayed(const Duration(milliseconds: 600));
    expect(events, greaterThan(0), reason: 'deleted image reported');
  }, skip: !FileSystemEntity.isWatchSupported);

  group('compareNaturally', () {
    test('orders embedded numbers by value', () {
      final names = <String>['b10', 'b2', 'a', 'B1']..sort(compareNaturally);
      expect(names, <String>['a', 'B1', 'b2', 'b10']);
    });
  });

  group('ImageSortOrder.storageKey', () {
    test('round-trips and falls back for unknown values', () {
      const order = ImageSortOrder(
        field: ImageSortField.modified,
        ascending: false,
      );
      expect(ImageSortOrder.fromStorageKey(order.storageKey), order);
      expect(
        ImageSortOrder.fromStorageKey('bogus:desc'),
        const ImageSortOrder(),
      );
      expect(ImageSortOrder.fromStorageKey(null), const ImageSortOrder());
    });
  });
}
