import 'dart:io';

import '../entities/gallery_image.dart';

abstract class ImageRepository {
  Future<FileSystemEntityType> entityType(String path);

  Future<bool> exists(String path);

  Future<List<GalleryImage>> readImagesFromDirectory(String directoryPath);

  bool isSupportedImagePath(String path);

  String? normalizeIncomingPath(String rawPath);

  String normalizedPath(String path);
}
