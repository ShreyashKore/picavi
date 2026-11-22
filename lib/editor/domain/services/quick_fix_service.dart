import '../entities/image_edits.dart';

/// One-click edits that can be applied to many images at once.
enum QuickFix { feelingLucky, autoContrast, autoColor, blackAndWhite, sepia }

abstract class QuickFixService {
  /// [current] with [fix] added for the image at [path], or null if the
  /// image couldn't be read.
  Future<ImageEdits?> apply(String path, ImageEdits current, QuickFix fix);
}
