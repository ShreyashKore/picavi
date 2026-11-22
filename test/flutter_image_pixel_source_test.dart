import 'dart:async';
import 'dart:io';

import 'package:flutter/painting.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:image/image.dart' as img;
import 'package:oiv/editor/data/services/edited_image_provider.dart';
import 'package:oiv/editor/data/services/flutter_image_pixel_source.dart';
import 'package:oiv/editor/domain/entities/edit_operation.dart';
import 'package:oiv/editor/domain/entities/image_edits.dart';
import 'package:path/path.dart' as p;

import 'support/editor_fakes.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late Directory directory;
  const source = FlutterImagePixelSource();

  setUp(() async {
    directory = await Directory.systemTemp.createTemp('oiv_pixels');
  });

  tearDown(() async {
    await directory.delete(recursive: true);
  });

  Future<String> writeFile(String name, List<int> bytes) async {
    final path = p.join(directory.path, name);
    await File(path).writeAsBytes(bytes);
    return path;
  }

  test('edits raster formats but not vectors, icons or GIFs', () {
    expect(source.canEdit('/a/photo.JPG'), isTrue);
    expect(source.canEdit('/a/photo.webp'), isTrue);
    expect(source.canEdit('/a/logo.svg'), isFalse);
    expect(source.canEdit('/a/anim.gif'), isFalse);
    expect(source.canEdit('/a/app.ico'), isFalse);
  });

  test('decodes straight RGBA, shrinking to the long edge', () async {
    final image = img.Image(width: 64, height: 32, numChannels: 4);
    img.fill(image, color: img.ColorRgba8(200, 100, 50, 128));
    final path = await writeFile('half.png', img.encodePng(image));

    final full = (await source.load(path))!;
    final small = (await source.load(path, maxDimension: 16))!;

    expect((full.width, full.height), (64, 32));
    // Straight alpha: premultiplied red would be about 100.
    final pixel = full.pixels.sublist(0, 4);
    for (final (channel, expected) in [(0, 200), (1, 100), (2, 50), (3, 128)]) {
      expect(pixel[channel], closeTo(expected, 1));
    }
    expect((small.width, small.height), (16, 8));
  });

  test('applies EXIF orientation', () async {
    final image = img.Image(width: 40, height: 20)
      ..exif.imageIfd.orientation = 6;
    final path = await writeFile('turned.jpg', img.encodeJpg(image));

    final decoded = (await source.load(path))!;

    expect((decoded.width, decoded.height), (20, 40));
  });

  test('returns null for files it cannot decode', () async {
    final path = await writeFile('broken.png', [1, 2, 3]);

    expect(await source.load(path), isNull);
  });

  test('EditedImageProvider renders the edits', () async {
    final provider = EditedImageProvider(
      '/photos/a.jpg',
      const ImageEdits([CropEdit(NormalizedRect(0, 0, 0.5, 1))]),
      maxDimension: 512,
      pixelSource: FakePixelSource(gradientImage(80, 40)),
      renderService: SyncRenderService(),
    );

    final info = await (() {
      final completer = Completer<ImageInfo>();
      provider
          .resolve(ImageConfiguration.empty)
          .addListener(
            ImageStreamListener(
              (info, _) => completer.complete(info),
              onError: completer.completeError,
            ),
          );
      return completer.future;
    })();

    expect((info.image.width, info.image.height), (40, 40));
    expect(
      provider,
      EditedImageProvider(
        '/photos/a.jpg',
        const ImageEdits([CropEdit(NormalizedRect(0, 0, 0.5, 1))]),
        maxDimension: 512,
      ),
    );
    info.dispose();
  });
}
