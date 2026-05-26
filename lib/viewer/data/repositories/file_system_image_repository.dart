import 'dart:io';

import 'package:path/path.dart' as p;

import '../../domain/constants/supported_image_extensions.dart';
import '../../domain/entities/gallery_image.dart';
import '../../domain/repositories/image_repository.dart';

class FileSystemImageRepository implements ImageRepository {
  @override
  Future<FileSystemEntityType> entityType(String path) {
    return FileSystemEntity.type(path);
  }

  @override
  Future<bool> exists(String path) {
    return File(path).exists();
  }

  @override
  Future<List<GalleryImage>> readImagesFromDirectory(
    String directoryPath,
  ) async {
    final images = <GalleryImage>[];

    await for (final entity in Directory(
      directoryPath,
    ).list(followLinks: false)) {
      if (entity is File && isSupportedImagePath(entity.path)) {
        images.add(GalleryImage(path: entity.absolute.path));
      }
    }

    images.sort(
      (left, right) =>
          left.fileName.toLowerCase().compareTo(right.fileName.toLowerCase()),
    );

    return images;
  }

  @override
  bool isSupportedImagePath(String path) {
    return supportedImageExtensions.contains(p.extension(path).toLowerCase());
  }

  @override
  String? normalizeIncomingPath(String rawPath) {
    final trimmedPath = rawPath.trim();
    if (trimmedPath.isEmpty) {
      return null;
    }

    final uri = Uri.tryParse(trimmedPath);
    if (uri != null && uri.hasScheme && uri.scheme == 'file') {
      return uri.toFilePath();
    }

    return trimmedPath;
  }

  @override
  String normalizedPath(String path) {
    final normalized = p.normalize(path);
    return Platform.isWindows ? normalized.toLowerCase() : normalized;
  }
}
