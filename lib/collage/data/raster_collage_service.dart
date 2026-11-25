import 'dart:io';
import 'dart:isolate';
import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:image/image.dart' as img;
import 'package:path/path.dart' as p;

import '../../editor/data/pipeline/edit_pipeline.dart';
import '../../editor/data/services/flutter_image_pixel_source.dart';
import '../../editor/data/services/raster_image_export_service.dart'
    show availableExportPath;
import '../../editor/domain/entities/edit_operation.dart';
import '../../editor/domain/entities/rgba_image.dart';
import '../../editor/domain/services/image_pixel_source.dart';
import '../domain/collage_options.dart';
import 'collage_renderer.dart';

class RasterCollageService implements CollageService {
  const RasterCollageService({
    this.pixelSource = const FlutterImagePixelSource(),
  });

  final ImagePixelSource pixelSource;

  /// Long edge to decode each photo at: enough for its share of the canvas.
  static int decodeSizeFor(int count, CollageOptions options) {
    if (options.layout == CollageLayout.contactSheet) {
      return 480;
    }
    final share =
        math.max(options.width, options.height) / math.sqrt(math.max(1, count));
    return (share * 1.5).round().clamp(400, 2400);
  }

  @override
  Future<List<String>> create(
    List<CollagePhoto> photos,
    CollageOptions options,
    String directory, {
    required String fileName,
    void Function(int done, int total)? onProgress,
  }) async {
    final maxDimension = decodeSizeFor(photos.length, options);
    final loaded = <(RgbaImage, List<EditOperation>, String)>[];
    onProgress?.call(0, photos.length);
    for (var i = 0; i < photos.length; i++) {
      final photo = photos[i];
      final pixels = await pixelSource.load(
        photo.path,
        maxDimension: maxDimension,
      );
      if (pixels != null) {
        loaded.add((pixels, photo.edits.operations, p.basename(photo.path)));
      }
      onProgress?.call(i + 1, photos.length);
    }
    if (loaded.isEmpty) {
      return const [];
    }

    try {
      final pages = await Isolate.run(
        () => renderCollageJpegs(loaded, options),
      );
      final written = <String>[];
      for (var i = 0; i < pages.length; i++) {
        final name = pages.length == 1 ? fileName : '$fileName ${i + 1}';
        final target = await availableExportPath(directory, name, '.jpg');
        final temporary = File(
          p.join(directory, '.${p.basename(target)}.picavi-tmp'),
        );
        await temporary.writeAsBytes(pages[i], flush: true);
        await temporary.rename(target);
        written.add(target);
      }
      return written;
    } catch (error) {
      debugPrint('Unable to make a collage: $error');
      return const [];
    }
  }
}

/// Applies each photo's edits, lays out the pages and encodes them as JPEG.
@visibleForTesting
List<Uint8List> renderCollageJpegs(
  List<(RgbaImage, List<EditOperation>, String)> photos,
  CollageOptions options,
) {
  final tiles = [
    for (final (pixels, operations, name) in photos)
      CollageTile(applyEdits(pixels, operations), name),
  ];
  return [
    for (final page in renderCollagePages(tiles, options))
      img.encodeJpg(page, quality: 90),
  ];
}
