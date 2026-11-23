import 'dart:math' as math;
import 'dart:ui' show lerpDouble;

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

import '../../../../core/widgets/app_image.dart';

const _viewerTranslationTransformKey = ValueKey<String>(
  'interactive_image_viewer.translation_transform',
);
const _viewerRotationTransformKey = ValueKey<String>(
  'interactive_image_viewer.rotation_transform',
);
const _viewerScaleTransformKey = ValueKey<String>(
  'interactive_image_viewer.scale_transform',
);

@immutable
class InteractiveImageViewerValue {
  const InteractiveImageViewerValue({
    this.zoomFactor = 1,
    this.oneToOneZoomFactor = 1,
    this.fillZoomFactor = 1,
    this.rotationQuarterTurns = 0,
    this.imageInfo,
    this.isDragging = false,
  });

  final double zoomFactor;
  final double oneToOneZoomFactor;

  /// Zoom at which the image covers the whole viewport (may crop).
  final double fillZoomFactor;
  final int rotationQuarterTurns;
  final AppImageInfo? imageInfo;
  final bool isDragging;

  double get zoomPercent => zoomFactor * 100;
  double get oneToOnePercent => oneToOneZoomFactor * 100;

  /// True when the image is zoomed to (about) fill the viewport and that
  /// differs from fitting it.
  bool get isFillingViewport =>
      (fillZoomFactor - 1).abs() > 0.01 &&
      (zoomFactor - fillZoomFactor).abs() < 0.01;

  InteractiveImageViewerValue copyWith({
    double? zoomFactor,
    double? oneToOneZoomFactor,
    double? fillZoomFactor,
    int? rotationQuarterTurns,
    AppImageInfo? imageInfo,
    bool clearImageInfo = false,
    bool? isDragging,
  }) {
    return InteractiveImageViewerValue(
      zoomFactor: zoomFactor ?? this.zoomFactor,
      oneToOneZoomFactor: oneToOneZoomFactor ?? this.oneToOneZoomFactor,
      fillZoomFactor: fillZoomFactor ?? this.fillZoomFactor,
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

  /// Zooms so the image covers the whole viewport.
  void zoomToFill() => _state?._zoomToFill();

  /// Switches between fitting the whole image and filling the viewport.
  void toggleFitFill() {
    if (_value.isFillingViewport) {
      reset();
    } else {
      zoomToFill();
    }
  }

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
        _value.fillZoomFactor == nextValue.fillZoomFactor &&
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
    this.imagePadding = EdgeInsets.zero,
    this.overlayBuilder,
  });

  final AppImage image;
  final InteractiveImageViewerController? controller;
  final String? semanticLabel;
  final Widget Function(BuildContext context)? loadingBuilder;
  final Widget Function(BuildContext context, Object error)? errorBuilder;
  final double? minZoomFactor;
  final double? maxZoomFactor;
  final EdgeInsetsGeometry imagePadding;

  /// Builds a layer drawn on top of the image, sized to the image as fitted
  /// in the viewport and moved with it by zoom, pan and rotation (e.g. Live
  /// Text). It is not part of the image cross-fade.
  final Widget Function(BuildContext context, Size fittedImageSize)?
  overlayBuilder;

  @override
  State<InteractiveImageViewer> createState() => _InteractiveImageViewerState();
}

class _InteractiveImageViewerState extends State<InteractiveImageViewer>
    with TickerProviderStateMixin {
  static const double _defaultMinZoom = 0.25;
  static const double _defaultMaxZoom = 8;
  static const Duration _zoomAnimationDuration = Duration(milliseconds: 180);
  static const Duration _rotationAnimationDuration = Duration(
    milliseconds: 260,
  );
  static const Duration _resetAnimationDuration = Duration(milliseconds: 240);
  static const Duration _imageTransitionDuration = Duration(milliseconds: 220);

  late AppImage _displayedImage;
  AppImageInfo? _imageInfo;
  Object? _lastError;
  int _imageResolveToken = 0;
  bool _resetWhenNextImageResolves = false;
  double _zoomFactor = 1;
  Offset _offset = Offset.zero;
  double _rotationAngle = 0;
  int _rotationQuarterTurns = 0;
  bool _isDragging = false;
  Offset? _gestureStartFocalPoint;
  Offset _gestureStartOffset = Offset.zero;
  double _gestureStartZoom = 1;
  Size _viewportSize = Size.zero;
  late final AnimationController _transformAnimationController =
      AnimationController(vsync: this)
        ..addListener(_handleTransformAnimation)
        ..addStatusListener(_handleTransformAnimationStatus);
  Curve _transformAnimationCurve = Curves.linear;
  double _animationStartZoom = 1;
  double _animationEndZoom = 1;
  Offset _animationStartOffset = Offset.zero;
  Offset _animationEndOffset = Offset.zero;
  double _animationStartAngle = 0;
  double _animationEndAngle = 0;

  @override
  void initState() {
    super.initState();
    _displayedImage = widget.image;
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
      _lastError = null;
      final isSameFileReloaded =
          oldWidget.image.filePath != null &&
          oldWidget.image.filePath == widget.image.filePath;
      if (isSameFileReloaded) {
        // The file was rewritten (e.g. its rotation saved): keep the current
        // view until the new pixels arrive, then reset without animating so
        // the image doesn't visibly spin back first.
        _resetWhenNextImageResolves = true;
      } else {
        _animateResetTransform(notify: false);
      }
      _resolveImage();
    }
  }

  @override
  void dispose() {
    _transformAnimationController.dispose();
    widget.controller?._detach(this);
    super.dispose();
  }

  Future<void> _resolveImage() async {
    final currentToken = ++_imageResolveToken;
    final nextImage = widget.image;

    try {
      final imageInfo = await nextImage.resolveInfo(context);
      if (!mounted || currentToken != _imageResolveToken) {
        return;
      }

      setState(() {
        _applyPendingInstantReset();
        _lastError = null;
        _displayedImage = nextImage;
        _imageInfo = imageInfo;
        _zoomFactor = _clampedZoom(_zoomFactor);
        _offset = _clampOffset(_offset);
      });
      _notifyController();
    } catch (exception) {
      if (!mounted || currentToken != _imageResolveToken) {
        return;
      }

      setState(() {
        _applyPendingInstantReset();
        _lastError = exception;
        _displayedImage = nextImage;
        _imageInfo = null;
      });
      _notifyController();
    }
  }

  void _applyPendingInstantReset() {
    if (!_resetWhenNextImageResolves) {
      return;
    }
    _resetWhenNextImageResolves = false;
    _transformAnimationController.stop();
    _gestureStartFocalPoint = null;
    _isDragging = false;
    _zoomFactor = 1;
    _offset = Offset.zero;
    _rotationAngle = 0;
    _rotationQuarterTurns = 0;
  }

  InteractiveImageViewerValue _currentValue() {
    return InteractiveImageViewerValue(
      zoomFactor: _zoomFactor,
      oneToOneZoomFactor: _oneToOneZoomFactor,
      fillZoomFactor: _fillZoomFactor,
      rotationQuarterTurns: _rotationQuarterTurns,
      imageInfo: _imageInfo,
      isDragging: _isDragging,
    );
  }

  AppImageInfo? get _layoutImageInfo {
    if (_imageInfo != null) {
      return _imageInfo;
    }

    if (_displayedImage.isSvg && !_viewportSize.isEmpty) {
      return AppImageInfo(pixelSize: _viewportSize, isVector: true);
    }

    return null;
  }

  Size? _rotatedImageBoundsForAngle(double angle) {
    final imageSize = _layoutImageInfo?.pixelSize;
    if (imageSize == null) {
      return null;
    }

    final normalizedAngle = angle % (2 * math.pi);
    final sinTheta = math.sin(normalizedAngle).abs();
    final cosTheta = math.cos(normalizedAngle).abs();

    return Size(
      imageSize.width * cosTheta + imageSize.height * sinTheta,
      imageSize.width * sinTheta + imageSize.height * cosTheta,
    );
  }

  double _fitScaleForAngle(double angle) {
    final imageSize = _rotatedImageBoundsForAngle(angle);
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

  double get _fitScale => _fitScaleForAngle(_rotationAngle);

  double get _oneToOneZoomFactor {
    if (_layoutImageInfo == null) {
      return 1;
    }

    final fitScale = _fitScaleForAngle(_rotationAngle);
    if (fitScale <= 0 || !fitScale.isFinite) {
      return 1;
    }

    return 1 / fitScale;
  }

  /// Zoom (relative to fit) at which the rotated image covers the viewport.
  double get _fillZoomFactor {
    final imageSize = _rotatedImageBoundsForAngle(_rotationAngle);
    if (_viewportSize.isEmpty || imageSize == null) {
      return 1;
    }

    final fillScale = math.max(
      _viewportSize.width / imageSize.width,
      _viewportSize.height / imageSize.height,
    );
    final fitScale = _fitScale;
    if (fitScale <= 0 || !fitScale.isFinite || !fillScale.isFinite) {
      return 1;
    }

    return fillScale / fitScale;
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

  Offset _clampOffset(
    Offset candidate, {
    double? zoomFactor,
    double? rotationAngle,
  }) {
    final effectiveAngle = rotationAngle ?? _rotationAngle;
    final effectiveZoom = zoomFactor ?? _zoomFactor;
    final imageSize = _rotatedImageBoundsForAngle(effectiveAngle);
    if (_viewportSize.isEmpty || imageSize == null) {
      return Offset.zero;
    }

    final fitScale = _fitScaleForAngle(effectiveAngle);
    final displayedSize = Size(
      imageSize.width * fitScale * effectiveZoom,
      imageSize.height * fitScale * effectiveZoom,
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

  /// Publishes the final zoom/rotation once an animation lands, so listeners
  /// (zoom %, fit/fill state) don't keep the pre-animation values.
  void _handleTransformAnimationStatus(AnimationStatus status) {
    if (status == AnimationStatus.completed && mounted) {
      _notifyController();
    }
  }

  void _handleTransformAnimation() {
    if (!mounted) {
      return;
    }

    final progress = _transformAnimationCurve.transform(
      _transformAnimationController.value,
    );

    setState(() {
      final nextAngle =
          lerpDouble(_animationStartAngle, _animationEndAngle, progress) ??
          _animationEndAngle;
      final nextZoom =
          lerpDouble(_animationStartZoom, _animationEndZoom, progress) ??
          _animationEndZoom;
      final desiredOffset =
          Offset.lerp(_animationStartOffset, _animationEndOffset, progress) ??
          _animationEndOffset;

      _rotationAngle = nextAngle;
      _zoomFactor = _clampedZoom(nextZoom);
      _offset = _clampOffset(
        desiredOffset,
        zoomFactor: _zoomFactor,
        rotationAngle: _rotationAngle,
      );
    });
  }

  void _animateTransformTo({
    required double zoomFactor,
    required Offset offset,
    required double rotationAngle,
    required Duration duration,
    required Curve curve,
    bool notify = true,
  }) {
    final targetZoom = _clampedZoom(zoomFactor);
    final targetOffset = _clampOffset(
      offset,
      zoomFactor: targetZoom,
      rotationAngle: rotationAngle,
    );
    final shouldAnimate =
        (_zoomFactor - targetZoom).abs() >= 0.001 ||
        (_offset - targetOffset).distance >= 0.5 ||
        (_rotationAngle - rotationAngle).abs() >= 0.001;

    if (!mounted) {
      return;
    }

    _transformAnimationController.stop();

    if (!shouldAnimate) {
      setState(() {
        _zoomFactor = targetZoom;
        _offset = targetOffset;
        _rotationAngle = rotationAngle;
      });
      if (notify) {
        _notifyController();
      }
      return;
    }

    _transformAnimationCurve = curve;
    _animationStartZoom = _zoomFactor;
    _animationEndZoom = targetZoom;
    _animationStartOffset = _offset;
    _animationEndOffset = targetOffset;
    _animationStartAngle = _rotationAngle;
    _animationEndAngle = rotationAngle;
    _transformAnimationController.duration = duration;
    _transformAnimationController.forward(from: 0);

    if (notify) {
      _notifyController();
    }
  }

  double _nearestEquivalentAngle({
    required double fromAngle,
    required int targetQuarterTurns,
  }) {
    final baseAngle = targetQuarterTurns * (math.pi / 2);
    final fullTurn = 2 * math.pi;
    final turns = ((fromAngle - baseAngle) / fullTurn).roundToDouble();
    return baseAngle + (turns * fullTurn);
  }

  void _animateResetTransform({bool notify = true}) {
    if (!mounted) {
      return;
    }

    _gestureStartFocalPoint = null;
    _rotationQuarterTurns = 0;
    _isDragging = false;

    _animateTransformTo(
      zoomFactor: 1,
      offset: Offset.zero,
      rotationAngle: _nearestEquivalentAngle(
        fromAngle: _rotationAngle,
        targetQuarterTurns: 0,
      ),
      duration: _resetAnimationDuration,
      curve: Curves.easeOutCubic,
      notify: notify,
    );
  }

  void _resetTransform({bool notify = true}) {
    _animateResetTransform(notify: notify);
  }

  void _rotateBy(int quarterTurns) {
    if (!mounted) {
      return;
    }

    _gestureStartFocalPoint = null;
    _isDragging = false;
    _rotationQuarterTurns = (_rotationQuarterTurns + quarterTurns) % 4;
    if (_rotationQuarterTurns < 0) {
      _rotationQuarterTurns += 4;
    }

    _animateTransformTo(
      zoomFactor: _zoomFactor,
      offset: _offset,
      rotationAngle: _nearestEquivalentAngle(
        fromAngle: _rotationAngle,
        targetQuarterTurns: _rotationQuarterTurns,
      ),
      duration: _rotationAnimationDuration,
      curve: Curves.easeInOutCubic,
    );
  }

  void _zoomToOneToOne() {
    _setZoom(_oneToOneZoomFactor);
  }

  void _zoomToFill() {
    _setZoom(_fillZoomFactor);
  }

  void _zoomBy(
    double factor, {
    Offset? focalPoint,
    bool animate = true,
    Duration duration = _zoomAnimationDuration,
    Curve curve = Curves.easeOutCubic,
  }) {
    _setZoom(
      _zoomFactor * factor,
      focalPoint: focalPoint,
      animate: animate,
      duration: duration,
      curve: curve,
    );
  }

  void _setZoom(
    double nextZoom, {
    Offset? focalPoint,
    bool animate = true,
    Duration duration = _zoomAnimationDuration,
    Curve curve = Curves.easeOutCubic,
  }) {
    final clampedZoom = _clampedZoom(nextZoom);
    if (!mounted || (_zoomFactor - clampedZoom).abs() < 0.001) {
      return;
    }

    final previousZoom = _zoomFactor;
    final center = Offset(_viewportSize.width / 2, _viewportSize.height / 2);
    final targetFocalPoint = focalPoint ?? center;
    final normalizedFocalPoint = targetFocalPoint - center;
    final scaleRatio = clampedZoom / previousZoom;
    final nextOffset = _clampOffset(
      targetFocalPoint -
          center -
          ((normalizedFocalPoint - _offset) * scaleRatio),
      zoomFactor: clampedZoom,
      rotationAngle: _rotationAngle,
    );

    if (!animate) {
      _transformAnimationController.stop();
      setState(() {
        _zoomFactor = clampedZoom;
        _offset = nextOffset;
      });
      _notifyController();
      return;
    }

    _animateTransformTo(
      zoomFactor: clampedZoom,
      offset: nextOffset,
      rotationAngle: _rotationAngle,
      duration: duration,
      curve: curve,
    );
  }

  void _handleScaleStart(ScaleStartDetails details) {
    _transformAnimationController.stop();
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
      _offset = _clampOffset(
        _gestureStartOffset + panDelta,
        zoomFactor: nextZoom,
        rotationAngle: _rotationAngle,
      );
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
    _zoomBy(
      zoomFactor,
      focalPoint: event.localPosition,
      duration: const Duration(milliseconds: 120),
    );
  }

  Widget _buildAnimatedDisplayedImage(Size fittedImageSize) {
    return AnimatedSwitcher(
      duration: _imageTransitionDuration,
      switchInCurve: Curves.easeOutCubic,
      switchOutCurve: Curves.easeInCubic,
      layoutBuilder: (currentChild, previousChildren) {
        return Stack(
          alignment: Alignment.center,
          children: [...previousChildren, ?currentChild],
        );
      },
      transitionBuilder: (child, animation) {
        final fadeAnimation = CurvedAnimation(
          parent: animation,
          curve: Curves.easeOutCubic,
          reverseCurve: Curves.easeInCubic,
        );
        final scaleAnimation = Tween<double>(begin: 0.985, end: 1).animate(
          CurvedAnimation(parent: animation, curve: Curves.easeOutCubic),
        );

        return FadeTransition(
          opacity: fadeAnimation,
          child: ScaleTransition(scale: scaleAnimation, child: child),
        );
      },
      child: SizedBox(
        key: ValueKey<Object>(_displayedImage.providerIdentity),
        width: fittedImageSize.width,
        height: fittedImageSize.height,
        child: AppImage(
          image: _displayedImage.image,
          svgBytesLoader: _displayedImage.svgBytesLoader,
          width: _displayedImage.width,
          height: _displayedImage.height,
          fit: _displayedImage.fit,
          alignment: _displayedImage.alignment,
          repeat: _displayedImage.repeat,
          matchTextDirection: _displayedImage.matchTextDirection,
          gaplessPlayback: true,
          isAntiAlias: _displayedImage.isAntiAlias,
          filterQuality: _displayedImage.filterQuality,
          semanticLabel: widget.semanticLabel ?? _displayedImage.semanticLabel,
          excludeFromSemantics: _displayedImage.excludeFromSemantics,
          cacheWidth: _displayedImage.cacheWidth,
          cacheHeight: _displayedImage.cacheHeight,
          frameBuilder: _displayedImage.frameBuilder,
          loadingBuilder: _displayedImage.loadingBuilder,
          errorBuilder: _displayedImage.errorBuilder,
          opacity: _displayedImage.opacity,
          assetName: _displayedImage.assetName,
          filePath: _displayedImage.filePath,
          bundle: _displayedImage.bundle,
          package: _displayedImage.package,
        ),
      ),
    );
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
        _offset = _clampOffset(_offset, rotationAngle: _rotationAngle);
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
                      if (_layoutImageInfo == null)
                        widget.loadingBuilder?.call(context) ??
                            const Center(
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                      else
                        Builder(
                          builder: (context) {
                            final imageSize = _layoutImageInfo!.pixelSize;
                            final fitScale = _fitScale;
                            final fittedImageSize = Size(
                              imageSize.width * fitScale,
                              imageSize.height * fitScale,
                            );

                            return Padding(
                              padding: widget.imagePadding,
                              child: Transform.translate(
                                key: _viewerTranslationTransformKey,
                                offset: _offset,
                                child: Transform.rotate(
                                  key: _viewerRotationTransformKey,
                                  angle: _rotationAngle,
                                  child: Transform.scale(
                                    key: _viewerScaleTransformKey,
                                    scale: _zoomFactor,
                                    child: Center(
                                      child: Stack(
                                        alignment: Alignment.center,
                                        children: [
                                          _buildAnimatedDisplayedImage(
                                            fittedImageSize,
                                          ),
                                          if (widget.overlayBuilder
                                              case final overlayBuilder?)
                                            // Padding can squeeze the box;
                                            // scale like the image (contain)
                                            // so the overlay stays on it.
                                            SizedBox.fromSize(
                                              size: fittedImageSize,
                                              child: FittedBox(
                                                child: SizedBox.fromSize(
                                                  size: fittedImageSize,
                                                  child: overlayBuilder(
                                                    context,
                                                    fittedImageSize,
                                                  ),
                                                ),
                                              ),
                                            ),
                                        ],
                                      ),
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
