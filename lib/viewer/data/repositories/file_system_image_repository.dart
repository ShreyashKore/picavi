import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:path/path.dart' as p;

import '../../domain/constants/supported_image_extensions.dart';
import '../../domain/entities/gallery_image.dart';
import '../../domain/entities/image_sort_order.dart';
import '../../domain/repositories/image_repository.dart';
import '../../domain/utils/natural_compare.dart';

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
    String directoryPath, {
    ImageSortOrder sortOrder = const ImageSortOrder(),
  }) async {
    final images = <GalleryImage>[];

    await for (final entity in Directory(
      directoryPath,
    ).list(followLinks: false)) {
      if (entity is File && isSupportedImagePath(entity.path)) {
        images.add(GalleryImage(path: entity.absolute.path));
      }
    }

    return sortImages(images, sortOrder);
  }

  @override
  Future<List<GalleryImage>> sortImages(
    List<GalleryImage> images,
    ImageSortOrder sortOrder,
  ) async {
    final stats = switch (sortOrder.field) {
      ImageSortField.modified || ImageSortField.size => await _statAll(images),
      _ => const <String, FileStat?>{},
    };

    int compareByField(GalleryImage left, GalleryImage right) {
      switch (sortOrder.field) {
        case ImageSortField.name:
          return 0;
        case ImageSortField.type:
          return p
              .extension(left.path)
              .toLowerCase()
              .compareTo(p.extension(right.path).toLowerCase());
        case ImageSortField.modified:
          final leftTime = stats[left.path]?.modified;
          final rightTime = stats[right.path]?.modified;
          if (leftTime == null || rightTime == null) {
            return 0;
          }
          return leftTime.compareTo(rightTime);
        case ImageSortField.size:
          return (stats[left.path]?.size ?? 0).compareTo(
            stats[right.path]?.size ?? 0,
          );
      }
    }

    final sorted = List<GalleryImage>.of(images)
      ..sort((left, right) {
        var result = compareByField(left, right);
        if (result == 0) {
          result = compareNaturally(left.fileName, right.fileName);
        }
        return sortOrder.ascending ? result : -result;
      });
    return sorted;
  }

  @override
  Stream<void> watchDirectory(String directoryPath) {
    if (!FileSystemEntity.isWatchSupported) {
      return const Stream<void>.empty();
    }

    try {
      return Directory(directoryPath)
          .watch()
          .where(
            (event) =>
                isSupportedImagePath(event.path) ||
                (event is FileSystemMoveEvent &&
                    event.destination != null &&
                    isSupportedImagePath(event.destination!)),
          )
          .map<void>((_) {})
          .handleError((Object error) {
            debugPrint('Stopped watching $directoryPath: $error');
          });
    } catch (error) {
      debugPrint('Unable to watch $directoryPath: $error');
      return const Stream<void>.empty();
    }
  }

  Future<Map<String, FileStat?>> _statAll(List<GalleryImage> images) async {
    final entries = await Future.wait(
      images.map((image) async {
        try {
          return MapEntry<String, FileStat?>(
            image.path,
            await File(image.path).stat(),
          );
        } on FileSystemException {
          return MapEntry<String, FileStat?>(image.path, null);
        }
      }),
    );
    return Map<String, FileStat?>.fromEntries(entries);
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

    if (trimmedPath.startsWith('-') && !trimmedPath.startsWith('file://')) {
      return null;
    }

    final sanitizedPath = _stripWrappingQuotes(trimmedPath);

    final uri = Uri.tryParse(sanitizedPath);
    if (uri != null && uri.hasScheme && uri.scheme == 'file') {
      return uri.toFilePath();
    }

    return sanitizedPath;
  }

  @override
  String normalizedPath(String path) {
    final normalized = p.normalize(path);
    return Platform.isWindows ? normalized.toLowerCase() : normalized;
  }

  String _stripWrappingQuotes(String path) {
    if (path.length >= 2 &&
        ((path.startsWith('"') && path.endsWith('"')) ||
            (path.startsWith("'") && path.endsWith("'")))) {
      return path.substring(1, path.length - 1);
    }

    return path;
  }
}
