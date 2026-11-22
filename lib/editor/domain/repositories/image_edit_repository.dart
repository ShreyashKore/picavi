import '../entities/image_edits.dart';

/// Stores edits next to the images (never inside them).
abstract class ImageEditRepository {
  /// Edits for every image in [directory] that has any, keyed by full path.
  Future<Map<String, ImageEdits>> loadDirectory(String directory);

  Future<ImageEdits> load(String imagePath);

  /// Saves [edits] for [imagePath]; empty edits remove the entry. Returns
  /// false when the edits couldn't be written.
  Future<bool> save(String imagePath, ImageEdits edits);

  /// Carries the edits of [from] over to [to] after a rename or move.
  Future<void> move(String from, String to);

  /// Gives [to] the same edits as [from] after a copy.
  Future<void> copy(String from, String to);
}
