import 'dart:typed_data';
import 'dart:ui' as ui;

import '../../domain/entities/rgba_image.dart';

/// Reads the pixels of a decoded [image] (straight alpha).
Future<RgbaImage?> rgbaFromUiImage(ui.Image image) async {
  final data = await image.toByteData(
    format: ui.ImageByteFormat.rawStraightRgba,
  );
  if (data == null) {
    return null;
  }
  return RgbaImage(
    image.width,
    image.height,
    data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes),
  );
}

/// Uploads [image] as a [ui.Image] that can be painted.
Future<ui.Image> uiImageFromRgba(RgbaImage image) async {
  final buffer = await ui.ImmutableBuffer.fromUint8List(
    _premultiplied(image.pixels),
  );
  final descriptor = ui.ImageDescriptor.raw(
    buffer,
    width: image.width,
    height: image.height,
    pixelFormat: ui.PixelFormat.rgba8888,
  );
  try {
    final codec = await descriptor.instantiateCodec();
    final frame = await codec.getNextFrame();
    codec.dispose();
    return frame.image;
  } finally {
    descriptor.dispose();
    buffer.dispose();
  }
}

/// [ui.PixelFormat.rgba8888] expects premultiplied alpha; most photos are
/// opaque, so only copy when there is transparency.
Uint8List _premultiplied(Uint8List pixels) {
  var opaque = true;
  for (var i = 3; i < pixels.length; i += 4) {
    if (pixels[i] != 255) {
      opaque = false;
      break;
    }
  }
  if (opaque) {
    return pixels;
  }
  final result = Uint8List.fromList(pixels);
  for (var i = 0; i < result.length; i += 4) {
    final alpha = result[i + 3];
    if (alpha == 255) {
      continue;
    }
    result[i] = (result[i] * alpha + 127) ~/ 255;
    result[i + 1] = (result[i + 1] * alpha + 127) ~/ 255;
    result[i + 2] = (result[i + 2] * alpha + 127) ~/ 255;
  }
  return result;
}
