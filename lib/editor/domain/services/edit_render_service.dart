import '../entities/edit_operation.dart';
import '../entities/rgba_image.dart';

/// Applies edits to pixels and measures images for the automatic fixes.
abstract class EditRenderService {
  /// [source] with [operations] applied. [source] is left unchanged.
  Future<RgbaImage> render(RgbaImage source, List<EditOperation> operations);

  /// Measures [image] and returns the matching one-click fix.
  Future<LevelsEdit> autoFix(RgbaImage image, AutoFixKind kind);
}
