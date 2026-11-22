import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/painting.dart';
import 'package:path/path.dart' as p;

import '../../../core/images/system_decoded_image.dart';
import '../../../viewer/domain/constants/supported_image_extensions.dart';
import '../../domain/entities/rgba_image.dart';
import '../../domain/services/image_pixel_source.dart';
import 'rgba_conversions.dart';

/// Decodes files with Flutter's codecs (or macOS ImageIO for HEIC, AVIF and
/// TIFF). EXIF orientation is applied by the decoder.
class FlutterImagePixelSource implements ImagePixelSource {
  const FlutterImagePixelSource();

  /// Formats the editor opens. Vector, animated and icon files are left out:
  /// editing would flatten them to a single still image.
  static const Set<String> _editableExtensions = {
    '.jpg',
    '.jpeg',
    '.png',
    '.bmp',
    '.webp',
  };

  @override
  bool canEdit(String path) {
    final extension = p.extension(path).toLowerCase();
    return _editableExtensions.contains(extension) ||
        (isSystemImageDecodingAvailable &&
            systemDecodedImageExtensions.contains(extension));
  }

  @override
  Future<RgbaImage?> load(String path, {int? maxDimension}) async {
    try {
      final provider = providerFor(path, maxDimension: maxDimension);
      final info = await _resolveUncached(provider);
      try {
        return await rgbaFromUiImage(info.image);
      } finally {
        info.dispose();
      }
    } catch (error) {
      debugPrint('Unable to decode $path for editing: $error');
      return null;
    }
  }

  /// The provider that decodes [path] at no more than [maxDimension].
  static ImageProvider providerFor(String path, {int? maxDimension}) {
    final extension = p.extension(path).toLowerCase();
    if (isSystemImageDecodingAvailable &&
        systemDecodedImageExtensions.contains(extension)) {
      return SystemDecodedImage(path, maxPixelSize: maxDimension);
    }
    final file = FileImage(File(path));
    if (maxDimension == null) {
      return file;
    }
    return ResizeImage(
      file,
      width: maxDimension,
      height: maxDimension,
      policy: ResizeImagePolicy.fit,
      allowUpscaling: false,
    );
  }

  /// Decodes without going through the [ImageCache]: full-size images used
  /// for editing would otherwise crowd out the viewer's cache.
  static Future<ImageInfo> _resolveUncached(ImageProvider provider) async {
    final key = await provider.obtainKey(ImageConfiguration.empty);
    // ignore: invalid_use_of_protected_member
    final completer = provider.loadImage(
      key,
      PaintingBinding.instance.instantiateImageCodecWithSize,
    );
    final result = Completer<ImageInfo>();
    late final ImageStreamListener listener;
    listener = ImageStreamListener(
      (info, _) {
        completer.removeListener(listener);
        if (!result.isCompleted) {
          result.complete(info);
        } else {
          info.dispose();
        }
      },
      onError: (error, stackTrace) {
        completer.removeListener(listener);
        if (!result.isCompleted) {
          result.completeError(error, stackTrace);
        }
      },
    );
    completer.addListener(listener);
    return result.future;
  }
}
