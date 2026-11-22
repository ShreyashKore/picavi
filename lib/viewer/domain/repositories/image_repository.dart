import 'dart:io';

import '../entities/gallery_image.dart';
import '../entities/image_sort_order.dart';

abstract class ImageRepository {
  Future<FileSystemEntityType> entityType(String path);

  Future<bool> exists(String path);

  Future<List<GalleryImage>> readImagesFromDirectory(
    String directoryPath, {
    ImageSortOrder sortOrder = const ImageSortOrder(),
  });

  /// Returns [images] ordered by [sortOrder].
  Future<List<GalleryImage>> sortImages(
    List<GalleryImage> images,
    ImageSortOrder sortOrder,
  );

  /// Emits whenever the set of files in [directoryPath] may have changed.
  /// Emits nothing if the platform can't watch the folder.
  Stream<void> watchDirectory(String directoryPath);

  bool isSupportedImagePath(String path);

  String? normalizeIncomingPath(String rawPath);

  String normalizedPath(String path);
}
