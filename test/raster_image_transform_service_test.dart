import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:image/image.dart' as img;
import 'package:oiv/viewer/data/services/raster_image_transform_service.dart';
import 'package:oiv/viewer/domain/services/image_transform_service.dart';
import 'package:path/path.dart' as p;

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  /// A 40×20 JPEG, optionally with an EXIF orientation tag and a camera make.
  Uint8List jpeg({int? orientation, String? make}) {
    final image = img.Image(width: 40, height: 20)
      ..exif.imageIfd.orientation = orientation;
    if (make != null) {
      image.exif.imageIfd['Make'] = img.IfdValueAscii(make);
    }
    if (orientation == null && make == null) {
      image.exif.clear();
    }
    return img.encodeJpg(image);
  }

  Future<ui.Size> decodedSize(Uint8List bytes) async {
    final codec = await ui.instantiateImageCodec(bytes);
    final frame = await codec.getNextFrame();
    return ui.Size(frame.image.width.toDouble(), frame.image.height.toDouble());
  }

  int? orientationOf(Uint8List bytes) =>
      img.decodeJpgExif(bytes)?.imageIfd.orientation;

  group('composeOrientation', () {
    test('adds clockwise turns and keeps mirroring', () {
      expect(composeOrientation(1, 1), 6);
      expect(composeOrientation(6, 1), 3);
      expect(composeOrientation(3, 1), 8);
      expect(composeOrientation(8, 1), 1);
      expect(composeOrientation(1, 3), 8);
      expect(composeOrientation(2, 1), 7);
      expect(composeOrientation(7, 2), 5);
      expect(composeOrientation(4, 2), 2);
    });

    test('treats unknown values as upright', () {
      expect(composeOrientation(0, 1), 6);
      expect(composeOrientation(42, 2), 3);
    });
  });

  group('rotateJpegOrientation', () {
    test('edits only the orientation bytes of existing EXIF', () {
      final original = jpeg(orientation: 1, make: 'TestCam');

      final rotated = rotateJpegOrientation(original, 1)!;

      expect(orientationOf(rotated), 6);
      expect(rotated.length, original.length);
      var differingBytes = 0;
      for (var i = 0; i < original.length; i++) {
        if (original[i] != rotated[i]) {
          differingBytes += 1;
        }
      }
      expect(differingBytes, lessThanOrEqualTo(2));
      expect(
        img.decodeJpgExif(rotated)?.imageIfd['Make']?.toString(),
        'TestCam',
      );
    });

    test('adds an orientation tag to a JPEG without EXIF', () {
      final original = jpeg();
      expect(img.decodeJpgExif(original)?.isEmpty ?? true, isTrue);

      final rotated = rotateJpegOrientation(original, 3)!;

      expect(orientationOf(rotated), 8);
    });

    test('leaves EXIF without an orientation tag alone', () {
      final original = jpeg(make: 'TestCam');

      expect(rotateJpegOrientation(original, 1), isNull);
    });

    test('rejects data that is not a JPEG', () {
      expect(
        rotateJpegOrientation(Uint8List.fromList([1, 2, 3, 4]), 1),
        isNull,
      );
    });

    test("Flutter's decoder honours the new orientation", () async {
      final rotated = rotateJpegOrientation(jpeg(orientation: 1), 1)!;

      final size = await decodedSize(rotated);

      expect(size, const ui.Size(20, 40));
    });
  });

  group('RasterImageTransformService', () {
    late Directory directory;
    final service = RasterImageTransformService();

    setUp(() async {
      directory = await Directory.systemTemp.createTemp('oiv_rotate');
    });

    tearDown(() async {
      await directory.delete(recursive: true);
    });

    test('rotates a PNG on disk and leaves no temp file', () async {
      final path = p.join(directory.path, 'wide.png');
      await File(
        path,
      ).writeAsBytes(img.encodePng(img.Image(width: 40, height: 20)));

      final result = await service.saveRotation(path, 1);

      expect(result, RotationSaveResult.saved);
      final saved = img.decodePng(await File(path).readAsBytes())!;
      expect((saved.width, saved.height), (20, 40));
      expect(directory.listSync(), hasLength(1));
    });

    test('rotates a JPEG on disk via its orientation tag', () async {
      final path = p.join(directory.path, 'photo.jpg');
      await File(path).writeAsBytes(jpeg(orientation: 6));

      final result = await service.saveRotation(path, 1);

      expect(result, RotationSaveResult.saved);
      expect(orientationOf(await File(path).readAsBytes()), 3);
    });

    test('reports unsupported formats without touching the file', () async {
      final path = p.join(directory.path, 'anim.webp');
      await File(path).writeAsBytes(<int>[1, 2, 3]);

      expect(service.canSaveRotation(path), isFalse);
      expect(
        await service.saveRotation(path, 1),
        RotationSaveResult.unsupportedFormat,
      );
      expect(await File(path).readAsBytes(), <int>[1, 2, 3]);
    });

    test('fails safely on a corrupt file', () async {
      final path = p.join(directory.path, 'broken.png');
      await File(path).writeAsBytes(<int>[1, 2, 3]);

      expect(await service.saveRotation(path, 1), RotationSaveResult.failed);
      expect(await File(path).readAsBytes(), <int>[1, 2, 3]);
    });
  });
}
