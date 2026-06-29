import 'package:path/path.dart' as p;

import 'gallery_image.dart';

/// A recently opened folder paired with a handful of preview images, used to
/// render the start-screen history list.
class RecentFolder {
  const RecentFolder({
    required this.path,
    required this.previewImages,
    required this.imageCount,
  });

  final String path;
  final List<GalleryImage> previewImages;
  final int imageCount;

  String get name => p.basename(path);
}
