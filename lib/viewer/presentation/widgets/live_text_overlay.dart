import 'dart:math' as math;

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

import '../../domain/entities/recognized_text.dart';
import '../controllers/live_text_controller.dart';

/// Selectable text drawn over an image, sized to the image as displayed.
///
/// Only the recognized words take pointer input, so dragging elsewhere still
/// pans the image. Over a word the cursor becomes an I-beam; dragging selects
/// words, a double-click selects a word and a triple-click a line.
class LiveTextOverlay extends StatefulWidget {
  const LiveTextOverlay({
    super.key,
    required this.controller,
    this.selectionColor,
  });

  final LiveTextController controller;

  /// Highlight for selected words; defaults to the theme's primary color.
  final Color? selectionColor;

  @override
  State<LiveTextOverlay> createState() => _LiveTextOverlayState();
}

class _LiveTextOverlayState extends State<LiveTextOverlay> {
  static const Duration _multiClickInterval = Duration(milliseconds: 400);
  static const double _multiClickSlop = 6;

  _WordGeometry? _geometry;
  bool _isSelecting = false;
  bool _didDrag = false;
  int? _anchorWord;
  int _clickCount = 0;
  Duration? _lastDownTime;
  Offset? _lastDownPosition;

  _WordGeometry _geometryFor(Size size) {
    final text = widget.controller.text;
    final current = _geometry;
    if (current != null &&
        current.size == size &&
        identical(current.text, text)) {
      return current;
    }
    return _geometry = _WordGeometry(text, widget.controller.words, size);
  }

  void _handleBackgroundPointerDown(PointerDownEvent event) {
    if (event.buttons != kPrimaryButton || !widget.controller.hasSelection) {
      return;
    }
    final geometry = _geometry;
    if (geometry == null || geometry.wordAt(event.localPosition) == null) {
      widget.controller.clearSelection();
    }
  }

  void _handleSelectStart(PointerDownEvent event) {
    final geometry = _geometry;
    final word = geometry?.wordAt(event.localPosition);
    if (geometry == null || word == null) {
      return;
    }

    final lastTime = _lastDownTime;
    final lastPosition = _lastDownPosition;
    final isRepeat =
        lastTime != null &&
        lastPosition != null &&
        event.timeStamp - lastTime <= _multiClickInterval &&
        (event.localPosition - lastPosition).distance <= _multiClickSlop;
    _clickCount = isRepeat ? math.min(_clickCount + 1, 3) : 1;
    _lastDownTime = event.timeStamp;
    _lastDownPosition = event.localPosition;

    _anchorWord = word;
    _didDrag = false;
    setState(() => _isSelecting = true);

    switch (_clickCount) {
      case 2:
        widget.controller.selectWord(word);
      case 3:
        widget.controller.selectLine(word);
      default:
        widget.controller.clearSelection();
    }
  }

  void _handleSelectUpdate(PointerMoveEvent event) {
    final anchor = _anchorWord;
    final geometry = _geometry;
    if (anchor == null || geometry == null) {
      return;
    }
    final extent = geometry.nearestWord(event.localPosition);
    if (extent == null) {
      return;
    }
    if (!_didDrag && extent == anchor && _clickCount == 1) {
      // Wait until the drag leaves the first word so a click doesn't flash
      // a one-word selection.
      final start = _lastDownPosition;
      if (start != null &&
          (event.localPosition - start).distance < _multiClickSlop) {
        return;
      }
    }
    _didDrag = true;

    final range = widget.controller.selectedRange;
    if (_clickCount == 3 && range != null) {
      // Extend line selections by whole lines.
      final words = widget.controller.words;
      final anchorLine = words[anchor].line;
      final extentLine = words[extent].line;
      final firstLine = math.min(anchorLine, extentLine);
      final lastLine = math.max(anchorLine, extentLine);
      widget.controller.select(
        words.indexWhere((ref) => ref.line == firstLine),
        words.lastIndexWhere((ref) => ref.line == lastLine),
      );
      return;
    }
    widget.controller.select(anchor, extent);
  }

  void _handleSelectEnd() {
    setState(() => _isSelecting = false);
    _anchorWord = null;
  }

  @override
  Widget build(BuildContext context) {
    final selectionColor =
        widget.selectionColor ??
        Theme.of(context).colorScheme.primary.withValues(alpha: 0.38);

    return ListenableBuilder(
      listenable: widget.controller,
      builder: (context, _) {
        if (!widget.controller.hasText) {
          _geometry = null;
          return const SizedBox.expand();
        }

        return LayoutBuilder(
          builder: (context, constraints) {
            final geometry = _geometryFor(constraints.biggest);
            return Listener(
              behavior: HitTestBehavior.translucent,
              onPointerDown: _handleBackgroundPointerDown,
              child: MouseRegion(
                cursor: _isSelecting
                    ? SystemMouseCursors.text
                    : MouseCursor.defer,
                hitTestBehavior: HitTestBehavior.translucent,
                child: RawGestureDetector(
                  gestures: <Type, GestureRecognizerFactory>{
                    _TextSelectGestureRecognizer:
                        GestureRecognizerFactoryWithHandlers<
                          _TextSelectGestureRecognizer
                        >(() => _TextSelectGestureRecognizer(debugOwner: this), (
                          recognizer,
                        ) {
                          recognizer
                            ..onStart = _handleSelectStart
                            ..onUpdate = _handleSelectUpdate
                            ..onEnd = _handleSelectEnd;
                        }),
                  },
                  child: MouseRegion(
                    cursor: SystemMouseCursors.text,
                    hitTestBehavior: HitTestBehavior.deferToChild,
                    child: _WordHitRegion(
                      geometry: geometry,
                      child: CustomPaint(
                        size: constraints.biggest,
                        painter: _SelectionPainter(
                          geometry: geometry,
                          controller: widget.controller,
                          color: selectionColor,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }
}

/// Word outlines in local (displayed image) coordinates.
class _WordGeometry {
  _WordGeometry(this.text, List<LiveTextWordRef> words, this.size)
    : _quads = [
        for (final ref in words)
          _scaleQuad(text!.lines[ref.line].words[ref.word].quad, size),
      ],
      _lines = [for (final ref in words) ref.line];

  final RecognizedText? text;
  final Size size;
  final List<List<Offset>> _quads;
  final List<int> _lines;

  int get length => _quads.length;

  List<Offset> quad(int index) => _quads[index];

  int line(int index) => _lines[index];

  static List<Offset> _scaleQuad(TextQuad quad, Size size) => [
    for (final corner in quad.corners)
      Offset(corner.x * size.width, corner.y * size.height),
  ];

  /// The word under [point], or null.
  int? wordAt(Offset point) {
    for (var index = 0; index < _quads.length; index++) {
      if (_containsPoint(_quads[index], point)) {
        return index;
      }
    }
    return null;
  }

  /// The word under [point], else the closest one.
  int? nearestWord(Offset point) {
    int? nearest;
    var nearestDistance = double.infinity;
    for (var index = 0; index < _quads.length; index++) {
      final quad = _quads[index];
      if (_containsPoint(quad, point)) {
        return index;
      }
      final distance = _distanceToQuad(quad, point);
      if (distance < nearestDistance) {
        nearestDistance = distance;
        nearest = index;
      }
    }
    return nearest;
  }

  static bool _containsPoint(List<Offset> quad, Offset point) {
    // Works for convex quads in either winding order.
    var sign = 0;
    for (var i = 0; i < quad.length; i++) {
      final a = quad[i];
      final b = quad[(i + 1) % quad.length];
      final cross =
          (b.dx - a.dx) * (point.dy - a.dy) - (b.dy - a.dy) * (point.dx - a.dx);
      if (cross == 0) {
        continue;
      }
      final currentSign = cross > 0 ? 1 : -1;
      if (sign == 0) {
        sign = currentSign;
      } else if (sign != currentSign) {
        return false;
      }
    }
    return true;
  }

  static double _distanceToQuad(List<Offset> quad, Offset point) {
    var best = double.infinity;
    for (var i = 0; i < quad.length; i++) {
      best = math.min(
        best,
        _distanceToSegment(point, quad[i], quad[(i + 1) % quad.length]),
      );
    }
    return best;
  }

  static double _distanceToSegment(Offset p, Offset a, Offset b) {
    final ab = b - a;
    final lengthSquared = ab.distanceSquared;
    if (lengthSquared == 0) {
      return (p - a).distance;
    }
    final t =
        (((p.dx - a.dx) * ab.dx + (p.dy - a.dy) * ab.dy) / lengthSquared)
            .clamp(0.0, 1.0);
    return (p - (a + ab * t)).distance;
  }
}

/// Hit-testable only over words, so the rest of the image keeps panning.
class _WordHitRegion extends SingleChildRenderObjectWidget {
  const _WordHitRegion({required this.geometry, super.child});

  final _WordGeometry geometry;

  @override
  _RenderWordHitRegion createRenderObject(BuildContext context) =>
      _RenderWordHitRegion(geometry);

  @override
  void updateRenderObject(
    BuildContext context,
    _RenderWordHitRegion renderObject,
  ) {
    renderObject.geometry = geometry;
  }
}

class _RenderWordHitRegion extends RenderProxyBox {
  _RenderWordHitRegion(this.geometry);

  _WordGeometry geometry;

  @override
  bool hitTest(BoxHitTestResult result, {required Offset position}) {
    if (geometry.wordAt(position) == null) {
      return false;
    }
    result.add(BoxHitTestEntry(this, position));
    return true;
  }
}

/// Accepts as soon as the primary button goes down (only over words, see
/// [_WordHitRegion]), so text selection beats the viewer's pan gesture.
class _TextSelectGestureRecognizer extends OneSequenceGestureRecognizer {
  _TextSelectGestureRecognizer({super.debugOwner});

  ValueChanged<PointerDownEvent>? onStart;
  ValueChanged<PointerMoveEvent>? onUpdate;
  VoidCallback? onEnd;
  bool _isActive = false;

  @override
  bool isPointerAllowed(PointerDownEvent event) =>
      !_isActive &&
      event.buttons == kPrimaryButton &&
      super.isPointerAllowed(event);

  @override
  void addAllowedPointer(PointerDownEvent event) {
    // Starts tracking the pointer.
    super.addAllowedPointer(event);
    _isActive = true;
    resolve(GestureDisposition.accepted);
    onStart?.call(event);
  }

  @override
  void handleEvent(PointerEvent event) {
    if (event is PointerMoveEvent) {
      onUpdate?.call(event);
    } else if (event is PointerUpEvent || event is PointerCancelEvent) {
      stopTrackingPointer(event.pointer);
    }
  }

  @override
  void didStopTrackingLastPointer(int pointer) {
    if (_isActive) {
      _isActive = false;
      onEnd?.call();
    }
  }

  @override
  void rejectGesture(int pointer) {
    stopTrackingPointer(pointer);
  }

  @override
  String get debugDescription => 'live text selection';
}

class _SelectionPainter extends CustomPainter {
  _SelectionPainter({
    required this.geometry,
    required this.controller,
    required this.color,
  }) : super(repaint: controller);

  final _WordGeometry geometry;
  final LiveTextController controller;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final range = controller.selectedRange;
    if (range == null || geometry.length == 0) {
      return;
    }
    final paint = Paint()..color = color;
    final last = math.min(range.$2, geometry.length - 1);

    // One band per line, from the first selected word to the last.
    var start = range.$1;
    while (start <= last) {
      var end = start;
      while (end < last && geometry.line(end + 1) == geometry.line(start)) {
        end++;
      }
      final first = geometry.quad(start);
      final lastQuad = geometry.quad(end);
      final path = Path()
        ..moveTo(first[0].dx, first[0].dy)
        ..lineTo(lastQuad[1].dx, lastQuad[1].dy)
        ..lineTo(lastQuad[2].dx, lastQuad[2].dy)
        ..lineTo(first[3].dx, first[3].dy)
        ..close();
      canvas.drawPath(path, paint);
      start = end + 1;
    }
  }

  @override
  bool shouldRepaint(_SelectionPainter oldDelegate) =>
      !identical(oldDelegate.geometry, geometry) ||
      oldDelegate.color != color ||
      oldDelegate.controller != controller;
}
