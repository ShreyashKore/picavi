/// Why a file operation could not be completed.
enum FileOperationError { alreadyExists, invalidName, notFound, failed }

class FileOperationException implements Exception {
  const FileOperationException(this.error, [this.message]);

  final FileOperationError error;
  final String? message;

  @override
  String toString() => 'FileOperationException($error, $message)';
}

/// File-level actions on images. Implementations never delete permanently:
/// removal always goes through the system Trash / Recycle Bin.
abstract class FileOperationsService {
  /// Moves [path] to the system Trash. Returns false when the platform has
  /// no trash or the move failed.
  Future<bool> moveToTrash(String path);

  /// Renames [path] to [newFileName] in the same folder and returns the new
  /// path. Throws [FileOperationException].
  Future<String> rename(String path, String newFileName);

  /// Copies [paths] into [destinationDirectory]. Returns each copied path
  /// mapped to its new path (which gets a " (2)" style suffix when the name
  /// was taken). Existing files are never overwritten.
  Future<Map<String, String>> copyTo(
    List<String> paths,
    String destinationDirectory,
  );

  /// Moves [paths] into [destinationDirectory]. Returns each moved path
  /// mapped to its new path. Existing files are never overwritten.
  Future<Map<String, String>> moveTo(
    List<String> paths,
    String destinationDirectory,
  );

  /// Shows [path] selected in the platform file manager.
  Future<bool> reveal(String path);

  /// Puts the image at [path] on the clipboard.
  Future<bool> copyImageToClipboard(String path);

  /// Lets the user open [path] in another application.
  Future<bool> openWith(String path, {required String prompt});
}
