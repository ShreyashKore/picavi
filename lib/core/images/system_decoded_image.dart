import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/foundation.dart';
import 'package:flutter/painting.dart';
import 'package:flutter/services.dart';

/// Whether this platform can decode [systemDecodedImageExtensions] natively.
bool get isSystemImageDecodingAvailable => Platform.isMacOS;

/// Loads an image the OS decodes for us (HEIC, AVIF, TIFF on macOS). The
/// native side applies EXIF orientation and returns JPEG or PNG bytes no
/// larger than [maxPixelSize] on the long edge.
@immutable
class SystemDecodedImage extends ImageProvider<SystemDecodedImage> {
  const SystemDecodedImage(this.path, {this.maxPixelSize, this.scale = 1});

  static const MethodChannel _channel = MethodChannel(
    'com.gyanoba.oiv/file_open',
  );

  /// Upper bound for the long edge; null means full size (capped natively).
  final int? maxPixelSize;
  final String path;
  final double scale;

  @override
  Future<SystemDecodedImage> obtainKey(ImageConfiguration configuration) {
    return SynchronousFuture<SystemDecodedImage>(this);
  }

  @override
  ImageStreamCompleter loadImage(
    SystemDecodedImage key,
    ImageDecoderCallback decode,
  ) {
    return MultiFrameImageStreamCompleter(
      codec: _load(decode),
      scale: scale,
      debugLabel: path,
      informationCollector: () => <DiagnosticsNode>[
        ErrorDescription('Path: $path'),
      ],
    );
  }

  Future<ui.Codec> _load(ImageDecoderCallback decode) async {
    final bytes = await _channel.invokeMethod<Uint8List>('decodeImage', {
      'path': path,
      'maxPixelSize': maxPixelSize,
    });
    if (bytes == null || bytes.isEmpty) {
      throw StateError('The system could not decode $path');
    }
    return decode(await ui.ImmutableBuffer.fromUint8List(bytes));
  }

  @override
  bool operator ==(Object other) =>
      other is SystemDecodedImage &&
      other.path == path &&
      other.maxPixelSize == maxPixelSize &&
      other.scale == scale;

  @override
  int get hashCode => Object.hash(path, maxPixelSize, scale);

  @override
  String toString() =>
      '${objectRuntimeType(this, 'SystemDecodedImage')}("$path", '
      'maxPixelSize: $maxPixelSize)';
}
