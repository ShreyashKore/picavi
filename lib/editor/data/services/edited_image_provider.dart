import 'dart:ui' as ui;

import 'package:flutter/foundation.dart';
import 'package:flutter/painting.dart';

import '../../domain/entities/image_edits.dart';
import '../../domain/services/edit_render_service.dart';
import '../../domain/services/image_pixel_source.dart';
import 'flutter_image_pixel_source.dart';
import 'isolate_edit_render_service.dart';
import 'rgba_conversions.dart';

/// Shows an image with its edits applied, rendered in the background at no
/// more than [maxDimension] on the long edge.
@immutable
class EditedImageProvider extends ImageProvider<EditedImageProvider> {
  const EditedImageProvider(
    this.path,
    this.edits, {
    required this.maxDimension,
    this.revision = 0,
    this.pixelSource = const FlutterImagePixelSource(),
    this.renderService = const IsolateEditRenderService(),
  });

  /// Long edge used for the main view of an edited image.
  static const int viewerMaxDimension = 2560;

  final String path;
  final ImageEdits edits;
  final int maxDimension;

  /// Changes when the original file was rewritten.
  final int revision;
  final ImagePixelSource pixelSource;
  final EditRenderService renderService;

  @override
  Future<EditedImageProvider> obtainKey(ImageConfiguration configuration) {
    return SynchronousFuture<EditedImageProvider>(this);
  }

  @override
  ImageStreamCompleter loadImage(
    EditedImageProvider key,
    ImageDecoderCallback decode,
  ) {
    return OneFrameImageStreamCompleter(
      _load(),
      informationCollector: () => <DiagnosticsNode>[
        ErrorDescription('Edited image: $path'),
      ],
    );
  }

  Future<ImageInfo> _load() async {
    final source = await pixelSource.load(path, maxDimension: maxDimension);
    if (source == null) {
      throw StateError('Unable to decode $path');
    }
    final rendered = await renderService.render(source, edits.operations);
    final ui.Image image = await uiImageFromRgba(rendered);
    return ImageInfo(image: image, debugLabel: path);
  }

  @override
  bool operator ==(Object other) =>
      other is EditedImageProvider &&
      other.path == path &&
      other.edits == edits &&
      other.maxDimension == maxDimension &&
      other.revision == revision;

  @override
  int get hashCode => Object.hash(path, edits, maxDimension, revision);

  @override
  String toString() =>
      '${objectRuntimeType(this, 'EditedImageProvider')}("$path", '
      '${edits.operations.length} edits, max $maxDimension)';
}
