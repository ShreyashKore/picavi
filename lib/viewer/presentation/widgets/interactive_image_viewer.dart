import 'dart:math' as math;

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

import '../../../../core/widgets/app_image.dart';

@immutable
class InteractiveImageViewerValue {
  const InteractiveImageViewerValue({
    this.zoomFactor = 1,
    this.oneToOneZoomFactor = 1,
    this.rotationQuarterTurns = 0,
    this.imageInfo,
    this.isDragging = false,
  });

  final double zoomFactor;
  final double oneToOneZoomFactor;
  final int rotationQuarterTurns;
  final AppImageInfo? imageInfo;
  final bool isDragging;

  double get zoomPercent => zoomFactor * 100;
  double get oneToOnePercent => oneToOneZoomFactor * 100;

  InteractiveImageViewerValue copyWith({
    double? zoomFactor,
    double? oneToOneZoomFactor,
    int? rotationQuarterTurns,
    AppImageInfo? imageInfo,
    bool clearImageInfo = false,
    bool? isDragging,
  }) {
    return InteractiveImageViewerValue(
      zoomFactor: zoomFactor ?? this.zoomFactor,
      oneToOneZoomFactor: oneToOneZoomFactor ?? this.oneToOneZoomFactor,
      rotationQuarterTurns: rotationQuarterTurns ?? this.rotationQuarterTurns,
      imageInfo: clearImageInfo ? null : imageInfo ?? this.imageInfo,
      isDragging: isDragging ?? this.isDragging,
    );
  }
}

class InteractiveImageViewerController extends ChangeNotifier {
  InteractiveImageViewerValue _value = const InteractiveImageViewerValue();
  _InteractiveImageViewerState? _state;

  InteractiveImageViewerValue get value => _value;

  bool get isAttached => _state != null;

  void zoomIn() => _state?._zoomBy(1.2);

  void zoomOut() => _state?._zoomBy(1 / 1.2);

  void zoomToOneToOne() => _state?._zoomToOneToOne();

  void reset() => _state?._resetTransform();

  void rotateLeft() => _state?._rotateBy(-1);

  void rotateRight() => _state?._rotateBy(1);

  void _attach(_InteractiveImageViewerState state) {
    _state = state;
    _updateValue(state._currentValue());
  }

  void _detach(_InteractiveImageViewerState state) {
    if (identical(_state, state)) {
      _state = null;
      _updateValue(const InteractiveImageViewerValue());
    }
  }

  void _updateValue(InteractiveImageViewerValue nextValue) {
    if (_value.zoomFactor == nextValue.zoomFactor &&
        _value.oneToOneZoomFactor == nextValue.oneToOneZoomFactor &&
        _value.rotationQuarterTurns == nextValue.rotationQuarterTurns &&
        _value.imageInfo == nextValue.imageInfo &&
        _value.isDragging == nextValue.isDragging) {
      return;
    }

    _value = nextValue;
    notifyListeners();
  }
}

class InteractiveImageViewer extends StatefulWidget {
  const InteractiveImageViewer({
    super.key,
    required this.image,
    this.controller,
    this.semanticLabel,
    this.loadingBuilder,
    this.errorBuilder,
    this.minZoomFactor,
    this.maxZoomFactor,
  });

  final AppImage image;
  final InteractiveImageViewerController? controller;
  final String? semanticLabel;
  final Widget Function(BuildContext context)? loadingBuilder;
  final Widget Function(BuildContext context, Object error)? errorBuilder;
  final double? minZoomFactor;
  final double? maxZoomFactor;

  @override
  State<InteractiveImageViewer> createState() => _InteractiveImageViewerState();
}

class _InteractiveImageViewerState extends State<InteractiveImageViewer> {
  static const double _defaultMinZoom = 0.25;
  static const double _defaultMaxZoom = 8;

  ImageStream? _imageStream;
  ImageStreamListener? _imageStreamListener;
  AppImageInfo? _imageInfo;
  Object? _lastError;
  double _zoomFactor = 1;
  Offset _offset = Offset.zero;
  int _rotationQuarterTurns = 0;
  bool _isDragging = false;
  Offset? _gestureStartFocalPoint;
  Offset _gestureStartOffset = Offset.zero;
  double _gestureStartZoom = 1;
  Size _viewportSize = Size.zero;

  @override
  void initState() {
    super.initState();
    widget.controller?._attach(this);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _resolveImage();
  }

  @override
  void didUpdateWidget(covariant InteractiveImageViewer oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.controller != widget.controller) {
      oldWidget.controller?._detach(this);
      widget.controller?._attach(this);
    }
    if (oldWidget.image.providerIdentity != widget.image.providerIdentity) {
      _imageInfo = null;
      _lastError = null;
      _resetTransform(notify: false);
      _resolveImage();
    }
  }

  @override
  void dispose() {
    _removeImageListener();
    widget.controller?._detach(this);
    super.dispose();
  }

  void _resolveImage() {
    final oldStream = _imageStream;
    final stream = widget.image.imageProvider.resolve(
      createLocalImageConfiguration(context),
    );
    if (oldStream?.key == stream.key) {
      return;
    }

    _removeImageListener();
    _imageStream = stream;
    _imageStreamListener = ImageStreamListener(
      (imageInfo, _) {
        if (!mounted) {
          return;
        }
        setState(() {
          _lastError = null;
          _imageInfo = AppImageInfo(
            pixelSize: Size(
              imageInfo.image.width.toDouble(),
              imageInfo.image.height.toDouble(),
            ),
          );
          _zoomFactor = _clampedZoom(_zoomFactor);
          _offset = _clampOffset(_offset);
        });
        _notifyController();
      },
      onError: (exception, _) {
        if (!mounted) {
          return;
        }
        setState(() {
          _lastError = exception;
          _imageInfo = null;
        });
        _notifyController();
      },
    );
    stream.addListener(_imageStreamListener!);
  }

  void _removeImageListener() {
    if (_imageStream != null && _imageStreamListener != null) {
      _imageStream!.removeListener(_imageStreamListener!);
    }
    _imageStream = null;
    _imageStreamListener = null;
  }

  InteractiveImageViewerValue _currentValue() {
    return InteractiveImageViewerValue(
      zoomFactor: _zoomFactor,
      oneToOneZoomFactor: _oneToOneZoomFactor,
      rotationQuarterTurns: _rotationQuarterTurns,
      imageInfo: _imageInfo,
      isDragging: _isDragging,
    );
  }

  double get _fitScale {
    final imageSize = _rotatedImagePixelSize;
    if (_viewportSize.isEmpty || imageSize == null) {
      return 1;
    }

    final fitScale = math.min(
      _viewportSize.width / imageSize.width,
      _viewportSize.height / imageSize.height,
    );

    if (fitScale <= 0 || !fitScale.isFinite) {
      return 1;
    }

    return fitScale;
  }

  double get _oneToOneZoomFactor {
    if (_imageInfo == null) {
      return 1;
    }

    final fitScale = _fitScale;
    if (fitScale <= 0 || !fitScale.isFinite) {
      return 1;
    }

    return 1 / fitScale;
  }

  Size? get _rotatedImagePixelSize {
    final imageSize = _imageInfo?.pixelSize;
    if (imageSize == null) {
      return null;
    }

    if (_rotationQuarterTurns.isEven) {
      return imageSize;
    }

    return Size(imageSize.height, imageSize.width);
  }

  double get _minZoomFactor {
    final oneToOneZoom = _oneToOneZoomFactor;
    final requestedMin = widget.minZoomFactor ?? _defaultMinZoom;
    return math.min(requestedMin, oneToOneZoom).clamp(0.05, double.infinity);
  }

  double get _maxZoomFactor {
    final oneToOneZoom = _oneToOneZoomFactor;
    final requestedMax = widget.maxZoomFactor ?? _defaultMaxZoom;
    return math.max(requestedMax, oneToOneZoom * 4);
  }

  double _clampedZoom(double zoomFactor) {
    return zoomFactor.clamp(_minZoomFactor, _maxZoomFactor);
  }

  Offset _clampOffset(Offset candidate) {
    final imageSize = _rotatedImagePixelSize;
    if (_viewportSize.isEmpty || imageSize == null) {
      return Offset.zero;
    }

    final fitScale = _fitScale;
    final displayedSize = Size(
      imageSize.width * fitScale * _zoomFactor,
      imageSize.height * fitScale * _zoomFactor,
    );

    final horizontalLimit = math.max(
      0,
      (displayedSize.width - _viewportSize.width) / 2,
    );
    final verticalLimit = math.max(
      0,
      (displayedSize.height - _viewportSize.height) / 2,
    );

    return Offset(
      candidate.dx.clamp(-horizontalLimit, horizontalLimit).toDouble(),
      candidate.dy.clamp(-verticalLimit, verticalLimit).toDouble(),
    );
  }

  void _notifyController() {
    widget.controller?._updateValue(_currentValue());
  }

  void _resetTransform({bool notify = true}) {
    if (!mounted) {
      return;
    }

    setState(() {
      _zoomFactor = 1;
      _offset = Offset.zero;
      _rotationQuarterTurns = 0;
      _isDragging = false;
    });
    if (notify) {
      _notifyController();
    }
  }

  void _rotateBy(int quarterTurns) {
    if (!mounted) {
      return;
    }

    setState(() {
      _rotationQuarterTurns = (_rotationQuarterTurns + quarterTurns) % 4;
      if (_rotationQuarterTurns < 0) {
        _rotationQuarterTurns += 4;
      }
      _offset = _clampOffset(_offset);
    });
    _notifyController();
  }

  void _zoomToOneToOne() {
    _setZoom(_oneToOneZoomFactor);
  }

  void _zoomBy(double factor, {Offset? focalPoint}) {
    _setZoom(_zoomFactor * factor, focalPoint: focalPoint);
  }

  void _setZoom(double nextZoom, {Offset? focalPoint}) {
    final clampedZoom = _clampedZoom(nextZoom);
    if (!mounted || (_zoomFactor - clampedZoom).abs() < 0.001) {
      return;
    }

    setState(() {
      final previousZoom = _zoomFactor;
      final center = Offset(_viewportSize.width / 2, _viewportSize.height / 2);
      final targetFocalPoint = focalPoint ?? center;
      final normalizedFocalPoint = targetFocalPoint - center;
      final scaleRatio = clampedZoom / previousZoom;
      _zoomFactor = clampedZoom;
      _offset = _clampOffset(
        targetFocalPoint -
            center -
            ((normalizedFocalPoint - _offset) * scaleRatio),
      );
    });
    _notifyController();
  }

  void _handleScaleStart(ScaleStartDetails details) {
    _gestureStartFocalPoint = details.localFocalPoint;
    _gestureStartOffset = _offset;
    _gestureStartZoom = _zoomFactor;
    setState(() {
      _isDragging = true;
    });
    _notifyController();
  }

  void _handleScaleUpdate(ScaleUpdateDetails details) {
    final startFocalPoint = _gestureStartFocalPoint;
    if (startFocalPoint == null) {
      return;
    }

    setState(() {
      final nextZoom = _clampedZoom(_gestureStartZoom * details.scale);
      _zoomFactor = nextZoom;
      final panDelta = details.localFocalPoint - startFocalPoint;
      _offset = _clampOffset(_gestureStartOffset + panDelta);
    });
    _notifyController();
  }

  void _handleScaleEnd(ScaleEndDetails details) {
    setState(() {
      _gestureStartFocalPoint = null;
      _isDragging = false;
      _offset = _clampOffset(_offset);
    });
    _notifyController();
  }

  void _handlePointerSignal(PointerSignalEvent event) {
    if (event is! PointerScrollEvent) {
      return;
    }

    final scrollDelta = event.scrollDelta.dy;
    if (scrollDelta == 0) {
      return;
    }

    final zoomFactor = scrollDelta < 0 ? 1.1 : 1 / 1.1;
    _zoomBy(zoomFactor, focalPoint: event.localPosition);
  }

  @override
  Widget build(BuildContext context) {
    if (_lastError != null) {
      return widget.errorBuilder?.call(context, _lastError!) ??
          const SizedBox.expand();
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final nextViewportSize = constraints.biggest;
        final viewportChanged = _viewportSize != nextViewportSize;
        _viewportSize = nextViewportSize;
        _zoomFactor = _clampedZoom(_zoomFactor);
        _offset = _clampOffset(_offset);
        if (viewportChanged) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted) {
              _notifyController();
            }
          });
        }

        final cursor = _isDragging
            ? SystemMouseCursors.grabbing
            : SystemMouseCursors.grab;

        return FocusableActionDetector(
          mouseCursor: cursor,
          descendantsAreFocusable: false,
          child: Listener(
            onPointerSignal: _handlePointerSignal,
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onScaleStart: _handleScaleStart,
              onScaleUpdate: _handleScaleUpdate,
              onScaleEnd: _handleScaleEnd,
              child: ClipRect(
                child: ColoredBox(
                  color: Colors.transparent,
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      if (_imageInfo == null)
                        widget.loadingBuilder?.call(context) ??
                            const Center(
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                      else
                        Builder(
                          builder: (context) {
                            final imageSize = _imageInfo!.pixelSize;
                            final fittedImageSize = Size(
                              imageSize.width * _fitScale,
                              imageSize.height * _fitScale,
                            );

                            return Transform.translate(
                              offset: _offset,
                              child: Transform.rotate(
                                angle: _rotationQuarterTurns * (math.pi / 2),
                                child: Transform.scale(
                                  scale: _zoomFactor,
                                  child: Center(
                                    child: SizedBox(
                                      width: fittedImageSize.width,
                                      height: fittedImageSize.height,
                                      child: widget.image,
                                    ),
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
