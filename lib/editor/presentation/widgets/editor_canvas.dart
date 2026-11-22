import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../data/pipeline/edit_pipeline.dart' show straightenScale;
import '../../domain/entities/edit_operation.dart';
import '../../domain/entities/rgba_image.dart';
import '../models/editor_state.dart';
import 'crop_overlay.dart';
import 'rgba_image_view.dart';

/// The image being edited, with the active tool's overlay on top.
class EditorCanvas extends StatelessWidget {
  const EditorCanvas({
    super.key,
    required this.state,
    required this.onDraftChanged,
    required this.redEyeRadius,
    this.cropAspect,
  });

  final EditorState state;
  final ValueChanged<EditOperation> onDraftChanged;

  /// Width ÷ height the crop keeps, or null for free.
  final double? cropAspect;

  /// Size of new red-eye spots, relative to the image's shorter side.
  final double redEyeRadius;

  static const EdgeInsets _padding = EdgeInsets.all(28);

  @override
  Widget build(BuildContext context) {
    final tool = state.tool;
    final shown = tool == EditorTool.crop || tool == EditorTool.straighten
        ? state.base
        : state.preview ?? state.base;
    if (shown == null) {
      return const Center(child: CircularProgressIndicator());
    }
    final imageSize = Size(shown.width.toDouble(), shown.height.toDouble());

    return Stack(
      fit: StackFit.expand,
      children: [
        LayoutBuilder(
          builder: (context, constraints) {
            final available = _padding.deflateSize(constraints.biggest);
            if (available.isEmpty) {
              return const SizedBox.shrink();
            }
            final fitted = applyBoxFit(
              BoxFit.contain,
              imageSize,
              available,
            ).destination;
            return Center(
              child: SizedBox.fromSize(
                size: fitted,
                child: _buildFrame(shown.width, shown.height, fitted, shown),
              ),
            );
          },
        ),
        if (state.isRendering || state.isBusy)
          const Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: LinearProgressIndicator(minHeight: 2),
          ),
      ],
    );
  }

  Widget _buildFrame(int width, int height, Size fitted, RgbaImage shown) {
    final image = RgbaImageView(image: shown);
    final draft = state.draft;
    switch (state.tool) {
      case EditorTool.crop:
        return Stack(
          fit: StackFit.expand,
          children: [
            image,
            CropOverlay(
              rect: draft is CropEdit ? draft.rect : NormalizedRect.full,
              imageSize: Size(width.toDouble(), height.toDouble()),
              aspect: cropAspect,
              onChanged: (rect) => onDraftChanged(CropEdit(rect)),
            ),
          ],
        );
      case EditorTool.straighten:
        final radians = draft is StraightenEdit ? draft.radians : 0.0;
        final scale = straightenScale(width, height, radians);
        return Stack(
          fit: StackFit.expand,
          children: [
            ClipRect(
              child: Transform.scale(
                scale: 1 / scale,
                child: Transform.rotate(angle: radians, child: image),
              ),
            ),
            const IgnorePointer(child: CustomPaint(painter: _GridPainter())),
          ],
        );
      case EditorTool.redEye:
        final spots = draft is RedEyeEdit ? draft.spots : const <RedEyeSpot>[];
        return MouseRegion(
          cursor: SystemMouseCursors.precise,
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTapUp: (details) {
              final position = details.localPosition;
              onDraftChanged(
                RedEyeEdit([
                  ...spots,
                  RedEyeSpot(
                    (position.dx / fitted.width).clamp(0, 1),
                    (position.dy / fitted.height).clamp(0, 1),
                    redEyeRadius,
                  ),
                ]),
              );
            },
            child: Stack(
              fit: StackFit.expand,
              children: [
                image,
                IgnorePointer(child: CustomPaint(painter: _SpotPainter(spots))),
              ],
            ),
          ),
        );
      case EditorTool.none:
      case EditorTool.tune:
      case EditorTool.effect:
        return image;
    }
  }
}

class _GridPainter extends CustomPainter {
  const _GridPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withValues(alpha: 0.4)
      ..strokeWidth = 1;
    final step = math.max(24.0, math.min(size.width, size.height) / 8);
    for (var x = step; x < size.width; x += step) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }
    for (var y = step; y < size.height; y += step) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }

  @override
  bool shouldRepaint(_GridPainter oldDelegate) => false;
}

class _SpotPainter extends CustomPainter {
  const _SpotPainter(this.spots);

  final List<RedEyeSpot> spots;

  @override
  void paint(Canvas canvas, Size size) {
    final shortSide = math.min(size.width, size.height);
    final paint = Paint()
      ..color = Colors.white.withValues(alpha: 0.85)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;
    for (final spot in spots) {
      canvas.drawCircle(
        Offset(spot.x * size.width, spot.y * size.height),
        spot.radius * shortSide,
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(_SpotPainter oldDelegate) => oldDelegate.spots != spots;
}
