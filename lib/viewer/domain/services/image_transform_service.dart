enum RotationSaveResult {
  /// The file now shows the rotation.
  saved,

  /// This format can't be rotated on disk yet.
  unsupportedFormat,

  /// Reading or writing the file failed; the original is unchanged.
  failed,
}

/// Writes simple edits back to image files.
abstract class ImageTransformService {
  /// Whether [saveRotation] can handle the format of [path].
  bool canSaveRotation(String path);

  /// Rotates the image at [path] by [quarterTurnsClockwise] (1–3) on disk.
  Future<RotationSaveResult> saveRotation(
    String path,
    int quarterTurnsClockwise,
  );
}
