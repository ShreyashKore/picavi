import '../entities/photo_info.dart';

/// Stars, captions, tags and the hidden flag, kept next to the photos.
abstract class PhotoInfoRepository {
  /// Info for every photo in [directory] that has any, keyed by full path.
  Future<Map<String, PhotoInfo>> loadDirectory(String directory);

  Future<PhotoInfo> load(String imagePath);

  /// Returns false when the info couldn't be written.
  Future<bool> save(String imagePath, PhotoInfo info);

  Future<void> move(String from, String to);

  Future<void> copy(String from, String to);
}
