import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:image/image.dart' as img;
import 'package:oiv/editor/domain/entities/edit_operation.dart';
import 'package:oiv/editor/domain/entities/image_edits.dart';
import 'package:oiv/library/data/services/thumbnail_cache.dart';
import 'package:oiv/library/domain/entities/catalog_image.dart';

import 'support/editor_fakes.dart';

void main() {
  late Directory directory;
  late FakePixelSource pixels;
  late ThumbnailCache cache;
  const stamp = FileStamp(10, 1000);

  setUp(() async {
    directory = await Directory.systemTemp.createTemp('oiv_thumbs');
    pixels = FakePixelSource(gradientImage(80, 40));
    cache = ThumbnailCache(directory.path, pixelSource: pixels);
  });

  tearDown(() async {
    await directory.delete(recursive: true);
  });

  test('makes a thumbnail once, then serves it from disk', () async {
    final first = await cache.thumbnail('/a/1.jpg', stamp, ImageEdits.none);
    final second = await ThumbnailCache(
      directory.path,
      pixelSource: pixels,
    ).thumbnail('/a/1.jpg', stamp, ImageEdits.none);

    expect(img.decodeJpg(first!)!.width, 80);
    expect(second, first);
    expect(pixels.loads, [('/a/1.jpg', ThumbnailCache.size)]);
  });

  test('concurrent requests for one photo decode it once', () async {
    await Future.wait([
      for (var i = 0; i < 5; i++)
        cache.thumbnail('/a/1.jpg', stamp, ImageEdits.none),
    ]);

    expect(pixels.loads, hasLength(1));
  });

  test('edits and file changes give a new thumbnail', () async {
    const rotated = ImageEdits([RotateEdit(1)]);
    expect(
      cache.keyFor('/a/1.jpg', stamp, ImageEdits.none),
      isNot(cache.keyFor('/a/1.jpg', stamp, rotated)),
    );
    expect(
      cache.keyFor('/a/1.jpg', stamp, ImageEdits.none),
      isNot(
        cache.keyFor('/a/1.jpg', const FileStamp(10, 2000), ImageEdits.none),
      ),
    );

    final bytes = await cache.thumbnail('/a/1.jpg', stamp, rotated);
    expect(img.decodeJpg(bytes!)!.height, 80);
  });

  test('undecodable photos give null and nothing is stored', () async {
    pixels.image = null;

    expect(await cache.thumbnail('/a/1.jpg', stamp, ImageEdits.none), isNull);
    expect(directory.listSync(), isEmpty);

    await cache.clear();
    expect(await directory.exists(), isFalse);
    await directory.create();
  });
}
