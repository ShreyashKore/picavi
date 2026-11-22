import 'package:flutter/material.dart';

import '../../domain/entities/edit_operation.dart';
import '../models/crop_geometry.dart';

/// Darkens everything outside [rect] and lets the user move it or drag its
/// handles. Sized to exactly cover the image.
class CropOverlay extends StatefulWidget {
  const CropOverlay({
    super.key,
    required this.rect,
    required this.imageSize,
    required this.onChanged,
    this.aspect,
  });

  final NormalizedRect rect;

  /// Pixel size of the image being cropped, for aspect-ratio maths.
  final Size imageSize;

  /// Width ÷ height to keep, or null for a free crop.
  final double? aspect;
  final ValueChanged<NormalizedRect> onChanged;

  @override
  State<CropOverlay> createState() => _CropOverlayState();
}

class _CropOverlayState extends State<CropOverlay> {
  static const double _handleSize = 22;

  NormalizedRect? _dragStart;
  Offset _dragDelta = Offset.zero;

  void _startDrag() {
    _dragStart = widget.rect;
    _dragDelta = Offset.zero;
  }

  void _updateDrag(CropHandle handle, DragUpdateDetails details, Size size) {
    final start = _dragStart;
    if (start == null) {
      return;
    }
    _dragDelta += details.delta;
    widget.onChanged(
      dragCrop(
        start,
        handle,
        _dragDelta.dx / size.width,
        _dragDelta.dy / size.height,
        imageSize: widget.imageSize,
        aspect: widget.aspect,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final size = constraints.biggest;
        final rect = Rect.fromLTRB(
          widget.rect.left * size.width,
          widget.rect.top * size.height,
          widget.rect.right * size.width,
          widget.rect.bottom * size.height,
        );
        final handles = widget.aspect == null
            ? CropHandle.values.where((h) => h != CropHandle.move)
            : CropHandle.values.where((h) => h.isCorner);

        Widget dragArea(CropHandle handle, Rect area, MouseCursor cursor) {
          return Positioned.fromRect(
            rect: area,
            child: MouseRegion(
              cursor: cursor,
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onPanStart: (_) => _startDrag(),
                onPanUpdate: (details) => _updateDrag(handle, details, size),
                onPanEnd: (_) => _dragStart = null,
              ),
            ),
          );
        }

        return Stack(
          clipBehavior: Clip.none,
          children: [
            Positioned.fill(
              child: IgnorePointer(
                child: CustomPaint(painter: _CropShadePainter(rect)),
              ),
            ),
            dragArea(CropHandle.move, rect, SystemMouseCursors.move),
            for (final handle in handles)
              dragArea(
                handle,
                Rect.fromCenter(
                  center: _handleCenter(handle, rect),
                  width: _handleSize,
                  height: _handleSize,
                ),
                _cursorFor(handle),
              ),
          ],
        );
      },
    );
  }

  static Offset _handleCenter(CropHandle handle, Rect rect) {
    return switch (handle) {
      CropHandle.topLeft => rect.topLeft,
      CropHandle.top => rect.topCenter,
      CropHandle.topRight => rect.topRight,
      CropHandle.right => rect.centerRight,
      CropHandle.bottomRight => rect.bottomRight,
      CropHandle.bottom => rect.bottomCenter,
      CropHandle.bottomLeft => rect.bottomLeft,
      CropHandle.left => rect.centerLeft,
      CropHandle.move => rect.center,
    };
  }

  static MouseCursor _cursorFor(CropHandle handle) {
    return switch (handle) {
      CropHandle.topLeft ||
      CropHandle.bottomRight => SystemMouseCursors.resizeUpLeftDownRight,
      CropHandle.topRight ||
      CropHandle.bottomLeft => SystemMouseCursors.resizeUpRightDownLeft,
      CropHandle.top || CropHandle.bottom => SystemMouseCursors.resizeUpDown,
      CropHandle.left || CropHandle.right => SystemMouseCursors.resizeLeftRight,
      CropHandle.move => SystemMouseCursors.move,
    };
  }
}

class _CropShadePainter extends CustomPainter {
  const _CropShadePainter(this.rect);

  final Rect rect;

  @override
  void paint(Canvas canvas, Size size) {
    final outside = Path()
      ..fillType = PathFillType.evenOdd
      ..addRect(Offset.zero & size)
      ..addRect(rect);
    canvas.drawPath(outside, Paint()..color = const Color(0xA6000000));

    final line = Paint()
      ..color = Colors.white.withValues(alpha: 0.35)
      ..strokeWidth = 1;
    for (var i = 1; i < 3; i++) {
      final x = rect.left + rect.width * i / 3;
      final y = rect.top + rect.height * i / 3;
      canvas.drawLine(Offset(x, rect.top), Offset(x, rect.bottom), line);
      canvas.drawLine(Offset(rect.left, y), Offset(rect.right, y), line);
    }
    canvas.drawRect(
      rect,
      Paint()
        ..color = Colors.white
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5,
    );

    final corner = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4
      ..strokeCap = StrokeCap.square;
    const length = 14.0;
    for (final (point, dx, dy) in [
      (rect.topLeft, 1.0, 1.0),
      (rect.topRight, -1.0, 1.0),
      (rect.bottomRight, -1.0, -1.0),
      (rect.bottomLeft, 1.0, -1.0),
    ]) {
      canvas.drawLine(point, point + Offset(length * dx, 0), corner);
      canvas.drawLine(point, point + Offset(0, length * dy), corner);
    }
  }

  @override
  bool shouldRepaint(_CropShadePainter oldDelegate) => oldDelegate.rect != rect;
}
