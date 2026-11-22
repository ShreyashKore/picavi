import 'dart:io';
import 'dart:isolate';
import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:image/image.dart' as img;
import 'package:path/path.dart' as p;

import '../../domain/entities/edit_operation.dart';
import '../../domain/entities/export_options.dart';
import '../../domain/entities/image_edits.dart';
import '../../domain/entities/rgba_image.dart';
import '../../domain/services/image_export_service.dart';
import '../../domain/services/image_pixel_source.dart';
import '../pipeline/edit_pipeline.dart';
import 'flutter_image_pixel_source.dart';

/// Renders edits at full size in a background isolate and writes a new
/// JPEG or PNG. The original is never touched and nothing is overwritten.
class RasterImageExportService implements ImageExportService {
  const RasterImageExportService({
    this.pixelSource = const FlutterImagePixelSource(),
  });

  final ImagePixelSource pixelSource;

  @override
  Future<String?> export(
    String imagePath,
    ImageEdits edits,
    ExportOptions options,
    String directory,
  ) async {
    File? temporary;
    try {
      final source = await pixelSource.load(imagePath);
      if (source == null) {
        return null;
      }
      final extension = p.extension(imagePath).toLowerCase();
      final original =
          options.format == ExportFormat.jpeg &&
              (extension == '.jpg' || extension == '.jpeg')
          ? await File(imagePath).readAsBytes()
          : null;

      final operations = edits.operations;
      final encoded = await Isolate.run(
        () => renderForExport(
          source,
          operations,
          options,
          originalJpeg: original,
        ),
      );

      final target = await availableExportPath(
        directory,
        p.basenameWithoutExtension(imagePath),
        options.format.extension,
      );
      temporary = File(p.join(directory, '.${p.basename(target)}.picavi-tmp'));
      await temporary.writeAsBytes(encoded, flush: true);
      await temporary.rename(target);
      return target;
    } catch (error) {
      debugPrint('Unable to export $imagePath: $error');
      try {
        if (temporary != null && await temporary.exists()) {
          await temporary.delete();
        }
      } catch (_) {}
      return null;
    }
  }
}

/// A path in [directory] for `name + extension` that doesn't exist yet,
/// adding " (2)", " (3)", … when needed.
Future<String> availableExportPath(
  String directory,
  String name,
  String extension,
) async {
  var candidate = p.join(directory, '$name$extension');
  var counter = 2;
  while (await FileSystemEntity.type(candidate) !=
      FileSystemEntityType.notFound) {
    candidate = p.join(directory, '$name ($counter)$extension');
    counter += 1;
  }
  return candidate;
}

/// Applies [operations], resizes and encodes. When [originalJpeg] is given
/// its EXIF (camera, date, GPS, …) is carried over, minus the orientation
/// (already applied) and the stale embedded thumbnail.
@visibleForTesting
Uint8List renderForExport(
  RgbaImage source,
  List<EditOperation> operations,
  ExportOptions options, {
  Uint8List? originalJpeg,
}) {
  final rendered = applyEdits(source, operations);
  var image = img.Image.fromBytes(
    width: rendered.width,
    height: rendered.height,
    bytes: rendered.pixels.buffer,
    bytesOffset: rendered.pixels.offsetInBytes,
    numChannels: 4,
  );

  final maxDimension = options.maxDimension;
  if (maxDimension != null &&
      math.max(image.width, image.height) > maxDimension) {
    final landscape = image.width >= image.height;
    image = img.copyResize(
      image,
      width: landscape ? maxDimension : null,
      height: landscape ? null : maxDimension,
      interpolation: img.Interpolation.average,
    );
  }

  switch (options.format) {
    case ExportFormat.png:
      return img.encodePng(image);
    case ExportFormat.jpeg:
      // JPEG has no transparency: flatten onto white rather than black.
      final flattened = img.Image(
        width: image.width,
        height: image.height,
        numChannels: 3,
      );
      img.fill(flattened, color: img.ColorRgb8(255, 255, 255));
      img.compositeImage(flattened, image);
      final jpeg = img.encodeJpg(flattened, quality: options.jpegQuality);
      return _withExifFrom(originalJpeg, jpeg) ?? jpeg;
  }
}

Uint8List? _withExifFrom(Uint8List? originalJpeg, Uint8List jpeg) {
  if (originalJpeg == null) {
    return null;
  }
  try {
    final exif = img.decodeJpgExif(originalJpeg);
    if (exif == null || exif.isEmpty) {
      return null;
    }
    exif.imageIfd.orientation = null;
    exif.directories.remove('ifd1');
    exif.thumbnailData = null;
    return img.injectJpgExif(jpeg, exif);
  } catch (_) {
    return null;
  }
}
