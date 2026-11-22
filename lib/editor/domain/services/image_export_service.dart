import '../entities/export_options.dart';
import '../entities/image_edits.dart';

/// Writes edited copies of images. Never overwrites an existing file.
abstract class ImageExportService {
  /// Renders [imagePath] with [edits] and writes it into [directory].
  /// Returns the new file's path, or null if exporting failed.
  Future<String?> export(
    String imagePath,
    ImageEdits edits,
    ExportOptions options,
    String directory,
  );
}
