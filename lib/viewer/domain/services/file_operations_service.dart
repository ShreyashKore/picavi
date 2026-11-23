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
/// Where a share menu should point: a rectangle in logical pixels from the
/// window's top-left corner.
class ShareAnchor {
  const ShareAnchor(this.left, this.top, this.width, this.height);

  final double left;
  final double top;
  final double width;
  final double height;
}

abstract class FileOperationsService {
  /// Whether [share] is available on this platform.
  bool get canShare;

  /// Shows the system share menu for [paths] next to [anchor].
  Future<bool> share(List<String> paths, ShareAnchor anchor);

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
