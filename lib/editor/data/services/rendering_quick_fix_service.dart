import '../../domain/entities/edit_operation.dart';
import '../../domain/entities/image_edits.dart';
import '../../domain/services/edit_render_service.dart';
import '../../domain/services/image_pixel_source.dart';
import '../../domain/services/quick_fix_service.dart';
import 'flutter_image_pixel_source.dart';
import 'isolate_edit_render_service.dart';

/// Applies quick fixes. The automatic ones measure the image (with its
/// existing edits) at a modest size, which is plenty for a histogram.
class RenderingQuickFixService implements QuickFixService {
  const RenderingQuickFixService({
    this.pixelSource = const FlutterImagePixelSource(),
    this.renderService = const IsolateEditRenderService(),
  });

  static const int _measureMaxDimension = 1024;

  final ImagePixelSource pixelSource;
  final EditRenderService renderService;

  @override
  Future<ImageEdits?> apply(
    String path,
    ImageEdits current,
    QuickFix fix,
  ) async {
    switch (fix) {
      case QuickFix.blackAndWhite:
        return current.adding(const EffectEdit(EffectKind.blackAndWhite, 1));
      case QuickFix.sepia:
        return current.adding(const EffectEdit(EffectKind.sepia, 1));
      case QuickFix.feelingLucky:
      case QuickFix.autoContrast:
      case QuickFix.autoColor:
        if (!pixelSource.canEdit(path)) {
          return null;
        }
        final source = await pixelSource.load(
          path,
          maxDimension: _measureMaxDimension,
        );
        if (source == null) {
          return null;
        }
        final edited = await renderService.render(source, current.operations);
        final kind = switch (fix) {
          QuickFix.feelingLucky => AutoFixKind.feelingLucky,
          QuickFix.autoContrast => AutoFixKind.autoContrast,
          _ => AutoFixKind.autoColor,
        };
        return current.adding(await renderService.autoFix(edited, kind));
    }
  }
}
