import 'dart:typed_data';

/// Uncompressed pixels: 4 bytes per pixel (R, G, B, straight alpha), rows
/// top to bottom.
class RgbaImage {
  RgbaImage(this.width, this.height, this.pixels)
    : assert(pixels.length == width * height * 4);

  RgbaImage.blank(this.width, this.height)
    : pixels = Uint8List(width * height * 4);

  final int width;
  final int height;
  final Uint8List pixels;

  RgbaImage copy() => RgbaImage(width, height, Uint8List.fromList(pixels));
}
