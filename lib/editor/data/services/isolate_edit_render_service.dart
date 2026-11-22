import 'dart:isolate';

import '../../domain/entities/edit_operation.dart';
import '../../domain/entities/rgba_image.dart';
import '../../domain/services/edit_render_service.dart';
import '../pipeline/edit_pipeline.dart';

/// Runs the edit pipeline in a background isolate so the UI stays smooth.
class IsolateEditRenderService implements EditRenderService {
  const IsolateEditRenderService();

  @override
  Future<RgbaImage> render(RgbaImage source, List<EditOperation> operations) {
    if (operations.isEmpty) {
      return Future.value(source);
    }
    return Isolate.run(() => applyEdits(source, operations));
  }

  @override
  Future<LevelsEdit> autoFix(RgbaImage image, AutoFixKind kind) {
    return Isolate.run(() => measureAutoFix(image, kind));
  }
}
