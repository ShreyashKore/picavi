import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:image/image.dart' as img;
import 'package:oiv/editor/data/services/raster_image_export_service.dart';
import 'package:oiv/editor/domain/entities/edit_operation.dart';
import 'package:oiv/editor/domain/entities/export_options.dart';
import 'package:oiv/editor/domain/entities/image_edits.dart';
import 'package:oiv/editor/domain/entities/rgba_image.dart';
import 'package:oiv/editor/domain/services/image_pixel_source.dart';
import 'package:path/path.dart' as p;

class _FakePixelSource implements ImagePixelSource {
  _FakePixelSource(this.image);

  final RgbaImage? image;

  @override
  bool canEdit(String path) => true;

  @override
  Future<RgbaImage?> load(String path, {int? maxDimension}) async =>
      image?.copy();
}

RgbaImage _gray(int width, int height, {int alpha = 255}) {
  final image = RgbaImage.blank(width, height);
  for (var i = 0; i < image.pixels.length; i += 4) {
    image.pixels.setAll(i, [120, 120, 120, alpha]);
  }
  return image;
}

void main() {
  group('renderForExport', () {
    test('applies edits and shrinks to the long edge', () {
      final bytes = renderForExport(_gray(400, 200), const [
        CropEdit(NormalizedRect(0, 0, 0.5, 1)),
      ], const ExportOptions(format: ExportFormat.png, maxDimension: 100));

      final decoded = img.decodePng(bytes)!;
      expect((decoded.width, decoded.height), (100, 100));
    });

    test('never upscales', () {
      final bytes = renderForExport(
        _gray(40, 20),
        const [],
        const ExportOptions(maxDimension: 1000),
      );

      final decoded = img.decodeJpg(bytes)!;
      expect((decoded.width, decoded.height), (40, 20));
    });

    test('flattens transparency onto white for JPEG', () {
      final bytes = renderForExport(
        _gray(8, 8, alpha: 0),
        const [],
        const ExportOptions(),
      );

      final pixel = img.decodeJpg(bytes)!.getPixel(4, 4);
      expect(pixel.r, greaterThan(240));
    });

    test('keeps the camera EXIF but drops the orientation', () {
      final original = img.Image(width: 8, height: 8)
        ..exif.imageIfd.orientation = 6
        ..exif.imageIfd['Make'] = img.IfdValueAscii('TestCam');
      final originalJpeg = img.encodeJpg(original);

      final bytes = renderForExport(
        _gray(8, 8),
        const [],
        const ExportOptions(),
        originalJpeg: originalJpeg,
      );

      final exif = img.decodeJpgExif(bytes)!;
      expect(exif.imageIfd['Make']?.toString(), 'TestCam');
      expect(exif.imageIfd.orientation, isNull);
    });
  });

  group('RasterImageExportService', () {
    late Directory directory;

    setUp(() async {
      directory = await Directory.systemTemp.createTemp('oiv_export');
    });

    tearDown(() async {
      await directory.delete(recursive: true);
    });

    test('writes a new file and never overwrites', () async {
      final service = RasterImageExportService(
        pixelSource: _FakePixelSource(_gray(10, 10)),
      );
      final source = p.join(directory.path, 'photo.png');
      await File(source).writeAsBytes([1, 2, 3]);
      await File(p.join(directory.path, 'photo.jpg')).writeAsString('keep');

      final exported = await service.export(
        source,
        const ImageEdits([EffectEdit(EffectKind.sepia, 1)]),
        const ExportOptions(),
        directory.path,
      );

      expect(p.basename(exported!), 'photo (2).jpg');
      expect(
        await File(p.join(directory.path, 'photo.jpg')).readAsString(),
        'keep',
      );
      expect(await File(source).readAsBytes(), [1, 2, 3]);
      expect(img.decodeJpg(await File(exported).readAsBytes()), isNotNull);
      expect(directory.listSync(), hasLength(3));
    });

    test('returns null when the image can\'t be decoded', () async {
      final service = RasterImageExportService(
        pixelSource: _FakePixelSource(null),
      );

      final exported = await service.export(
        p.join(directory.path, 'x.png'),
        ImageEdits.none,
        const ExportOptions(),
        directory.path,
      );

      expect(exported, isNull);
      expect(directory.listSync(), isEmpty);
    });
  });
}
