import '../entities/rgba_image.dart';

/// Decodes image files to pixels (EXIF orientation already applied).
abstract class ImagePixelSource {
  /// Whether the editor can open the file at [path].
  bool canEdit(String path);

  /// The image at [path], no larger than [maxDimension] on its long edge
  /// (null for full size), or null if it couldn't be decoded.
  Future<RgbaImage?> load(String path, {int? maxDimension});
}
