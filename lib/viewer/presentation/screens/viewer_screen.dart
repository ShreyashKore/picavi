import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:path/path.dart' as p;

import '../../../../core/l10n/l10n_extensions.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../core/widgets/app_image.dart';
import '../../data/repositories/file_system_image_repository.dart';
import '../../data/services/desktop_image_picker_service.dart';
import '../../data/services/native_file_channel_service.dart';
import '../../domain/constants/supported_image_extensions.dart';
import '../../domain/services/image_picker_service.dart';
import '../controllers/viewer_controller.dart';
import '../models/viewer_notice.dart';
import '../models/viewer_state.dart';
import '../widgets/image_info_overlay.dart';
import '../widgets/interactive_image_viewer.dart';
import '../widgets/viewer_empty_state.dart';
import '../widgets/viewer_thumbnail_rail.dart';
import '../widgets/viewer_top_overlay.dart';

class ViewerScreen extends StatefulWidget {
  const ViewerScreen({super.key, this.initialArguments = const []});

  final List<String> initialArguments;

  @override
  State<ViewerScreen> createState() => _ViewerScreenState();
}

class _ViewerScreenState extends State<ViewerScreen> {
  static const double _thumbnailExtent = 72;
  static const double _thumbnailControlsInset = 40;
  static const Duration _slideshowInterval = Duration(seconds: 3);

  final ScrollController _thumbnailScrollController = ScrollController();
  final FocusNode _viewerFocusNode = FocusNode(
    debugLabel: 'viewerKeyboardFocus',
  );
  late final ViewerController _controller;
  late final InteractiveImageViewerController _imageViewerController;
  Timer? _slideshowTimer;

  List<String> _lastGalleryPaths = const <String>[];
  int _lastSyncedIndex = 0;
  int? _lastNoticeId;
  bool _didBootstrap = false;
  bool _isPickingFile = false;
  bool _isPlaying = false;
  bool _showInfoOverlay = false;
  String? _lastImagePath;

  @override
  void initState() {
    super.initState();
    final nativeFileChannelService = NativeFileChannelService();
    _controller = ViewerController(
      imageRepository: FileSystemImageRepository(),
      imagePickerService: DesktopImagePickerService(
        nativeChannel: nativeFileChannelService,
      ),
      nativeFileChannelService: nativeFileChannelService,
    )..addListener(_onControllerChanged);
    _imageViewerController = InteractiveImageViewerController()
      ..addListener(_onImageViewerChanged);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    final directoryAccessTexts = _directoryAccessTexts;
    _controller.attachNativeFileHandler(directoryAccessTexts);

    if (_didBootstrap) {
      return;
    }

    _didBootstrap = true;
    unawaited(
      _controller.bootstrap(
        initialArguments: widget.initialArguments,
        directoryAccessTexts: directoryAccessTexts,
      ),
    );
  }

  @override
  void dispose() {
    _stopSlideshow(rebuild: false);
    _imageViewerController
      ..removeListener(_onImageViewerChanged)
      ..dispose();
    _controller
      ..removeListener(_onControllerChanged)
      ..dispose();
    _thumbnailScrollController.dispose();
    _viewerFocusNode.dispose();
    super.dispose();
  }

  DirectoryAccessTexts get _directoryAccessTexts => DirectoryAccessTexts(
    prompt: context.l10n.nativeGrantFolderAccessPrompt,
    message: context.l10n.nativeGrantFolderAccessMessage,
  );

  ImagePickerTexts get _imagePickerTexts =>
      ImagePickerTexts(openViewerPrompt: context.l10n.nativeOpenViewerPrompt);

  void _onControllerChanged() {
    if (!mounted) {
      return;
    }

    final state = _controller.state;
    _syncPresentationState(state);
    _handleNotice(state.notice);
    setState(() {});
  }

  void _onImageViewerChanged() {
    if (!mounted) {
      return;
    }

    setState(() {});
  }

  Future<void> _pickAndOpenImage() async {
    if (_isPickingFile) {
      return;
    }

    try {
      setState(() {
        _isPickingFile = true;
      });
      _viewerFocusNode.unfocus();
      FocusManager.instance.primaryFocus?.unfocus();

      await _syncKeyboardStateForNativeDialog();
      await Future<void>.delayed(const Duration(milliseconds: 10));

      await _controller.pickAndOpenImage(
        pickerTexts: _imagePickerTexts,
        directoryAccessTexts: _directoryAccessTexts,
      );

      await _syncKeyboardStateForNativeDialog();
    } catch (error) {
      debugPrint('Error picking file: $error');
    } finally {
      if (mounted) {
        setState(() {
          _isPickingFile = false;
        });
      }
    }
  }

  Future<void> _syncKeyboardStateForNativeDialog() async {
    try {
      await HardwareKeyboard.instance.syncKeyboardState();
    } catch (_) {
      // Best-effort only. Some embedders may not support keyboard state sync.
    }
  }

  void _syncPresentationState(ViewerState state) {
    final galleryPaths = state.images
        .map((image) => image.path)
        .toList(growable: false);

    if (!state.hasImages) {
      _lastGalleryPaths = galleryPaths;
      _lastSyncedIndex = 0;
      _lastImagePath = null;
      _showInfoOverlay = false;
      _stopSlideshow(rebuild: false);
      return;
    }

    final currentImagePath = state.currentImage.path;

    if (!listEquals(_lastGalleryPaths, galleryPaths)) {
      _lastGalleryPaths = galleryPaths;
      _lastSyncedIndex = state.currentIndex;
      _lastImagePath = currentImagePath;
      _showInfoOverlay = false;
      _imageViewerController.reset();
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted || !state.hasImages) {
          return;
        }

        _centerThumbnailOn(state.currentIndex, animate: false);
        _viewerFocusNode.requestFocus();
      });
      return;
    }

    if (_lastSyncedIndex != state.currentIndex ||
        _lastImagePath != currentImagePath) {
      _lastSyncedIndex = state.currentIndex;
      _lastImagePath = currentImagePath;
      _imageViewerController.reset();
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted || !state.hasImages) {
          return;
        }

        _centerThumbnailOn(state.currentIndex);
        _viewerFocusNode.requestFocus();
      });
    }

    if (state.images.length < 2) {
      _stopSlideshow(rebuild: false);
    }
  }

  void _handleNotice(ViewerNotice? notice) {
    if (notice == null || notice.id == _lastNoticeId) {
      return;
    }

    _lastNoticeId = notice.id;
    final messenger = ScaffoldMessenger.maybeOf(context);
    messenger
      ?..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(content: Text(_localizedNoticeMessage(notice.type))),
      );
    _controller.clearNotice();
  }

  String _localizedNoticeMessage(ViewerNoticeType type) {
    return switch (type) {
      ViewerNoticeType.folderAccessDenied => context.l10n.folderAccessDenied,
      ViewerNoticeType.folderAccessRequestFailed =>
        context.l10n.folderAccessRequestFailed,
    };
  }

  Future<void> _goToIndex(int index) async {
    final state = _controller.state;
    if (!state.hasImages) {
      return;
    }

    final boundedIndex = index.clamp(0, state.images.length - 1);
    await _controller.openIndex(boundedIndex);
  }

  Future<void> _goToRelativeIndex(int delta) {
    final state = _controller.state;
    if (!state.hasImages) {
      return Future<void>.value();
    }

    final nextIndex = (state.currentIndex + delta) % state.images.length;
    return _goToIndex(
      nextIndex < 0 ? nextIndex + state.images.length : nextIndex,
    );
  }

  void _toggleSlideshow() {
    if (_isPlaying) {
      _stopSlideshow();
      return;
    }

    final state = _controller.state;
    if (!state.hasImages || state.images.length < 2) {
      return;
    }

    setState(() {
      _isPlaying = true;
    });
    _slideshowTimer?.cancel();
    _slideshowTimer = Timer.periodic(_slideshowInterval, (_) {
      unawaited(_goToRelativeIndex(1));
    });
  }

  void _stopSlideshow({bool rebuild = true}) {
    _slideshowTimer?.cancel();
    _slideshowTimer = null;
    if (!_isPlaying) {
      return;
    }

    if (rebuild && mounted) {
      setState(() {
        _isPlaying = false;
      });
    } else {
      _isPlaying = false;
    }
  }

  void _centerThumbnailOn(int index, {bool animate = true}) {
    if (!_thumbnailScrollController.hasClients) {
      return;
    }

    final viewportWidth = _thumbnailScrollController.position.viewportDimension;
    final rawOffset =
        (index * _thumbnailExtent) - ((viewportWidth - _thumbnailExtent) / 2);
    final targetOffset = rawOffset.clamp(
      0.0,
      _thumbnailScrollController.position.maxScrollExtent,
    );

    if (animate) {
      _thumbnailScrollController.animateTo(
        targetOffset,
        duration: const Duration(milliseconds: 180),
        curve: Curves.easeOutCubic,
      );
      return;
    }

    _thumbnailScrollController.jumpTo(targetOffset);
  }

  KeyEventResult _handleKeyEvent(FocusNode node, KeyEvent event) {
    final state = _controller.state;
    if (event is! KeyDownEvent || !state.hasImages) {
      return KeyEventResult.ignored;
    }

    if (event.logicalKey == LogicalKeyboardKey.arrowRight) {
      unawaited(_goToRelativeIndex(1));
      return KeyEventResult.handled;
    }

    if (event.logicalKey == LogicalKeyboardKey.arrowLeft) {
      unawaited(_goToRelativeIndex(-1));
      return KeyEventResult.handled;
    }

    if (event.logicalKey == LogicalKeyboardKey.home) {
      unawaited(_goToIndex(0));
      return KeyEventResult.handled;
    }

    if (event.logicalKey == LogicalKeyboardKey.end) {
      unawaited(_goToIndex(state.images.length - 1));
      return KeyEventResult.handled;
    }

    return KeyEventResult.ignored;
  }

  @override
  Widget build(BuildContext context) {
    final state = _controller.state;
    final content = Stack(
      fit: StackFit.expand,
      children: [
        if (!state.hasImages) ...[
          const _ViewerBackdrop(),
          const ColoredBox(color: AppColors.shellOverlay),
        ],
        if (state.hasImages)
          _buildGalleryContent(state)
        else
          _buildEmptyState(),
        if (state.hasImages) _buildTopOverlay(state),
      ],
    );

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: state.hasImages
          ? Focus(
              focusNode: _viewerFocusNode,
              autofocus: true,
              onKeyEvent: _handleKeyEvent,
              child: content,
            )
          : content,
    );
  }

  Widget _buildEmptyState() {
    return ViewerEmptyState(
      isBootstrapping: _controller.state.isBootstrapping || _isPickingFile,
      supportedExtensions: supportedImageExtensions,
      title: context.l10n.emptyStateTitle,
      description: context.l10n.emptyStateDescription,
      openImageLabel: context.l10n.openImage,
      tipsText: context.l10n.tipsText,
      onOpenImage: _pickAndOpenImage,
    );
  }

  Widget _buildGalleryContent(ViewerState state) {
    final imageViewState = _imageViewerController.value;

    return SafeArea(
      minimum: const EdgeInsets.fromLTRB(14, 14, 14, 10),
      child: Stack(
        children: [
          Positioned.fill(
            child: InteractiveImageViewer(
              controller: _imageViewerController,
              image: AppImage.file(
                state.currentImage.path,
                fit: BoxFit.contain,
                filterQuality: FilterQuality.high,
                errorBuilder: (_, _, _) => const SizedBox.expand(),
              ),
              semanticLabel: state.currentImage.fileName,
              errorBuilder: (context, error) => const ColoredBox(
                color: AppColors.brokenImage,
                child: Center(
                  child: Icon(Icons.broken_image_outlined, size: 28),
                ),
              ),
              imagePadding: EdgeInsets.only(
                top: 20,
                bottom: _thumbnailControlsInset + _thumbnailExtent,
              ),
            ),
          ),

          if (_showInfoOverlay)
            Positioned(
              top: 16,
              right: 16,
              child: ImageInfoOverlay(
                imagePath: state.currentImage.path,
                fileName: state.currentImage.fileName,
                currentIndex: state.currentIndex,
                imageCount: state.images.length,
                viewState: imageViewState,
              ),
            ),

          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            height: _thumbnailControlsInset + _thumbnailExtent,
            child: Stack(
              clipBehavior: Clip.none,
              alignment: Alignment.topCenter,
              children: [
                Positioned.fill(
                  top: _thumbnailControlsInset,
                  child: ViewerThumbnailRail(
                    images: state.images,
                    currentIndex: state.currentIndex,
                    thumbnailExtent: _thumbnailExtent,
                    scrollController: _thumbnailScrollController,
                    onTap: (index) => unawaited(_goToIndex(index)),
                    onScrollImageChange: (delta) =>
                        unawaited(_goToRelativeIndex(delta)),
                    topInset: _thumbnailControlsInset,
                  ),
                ),

                _ViewerControlBar(
                  canNavigate: state.images.length > 1,
                  isPlaying: _isPlaying,
                  onZoomIn: _imageViewerController.zoomIn,
                  onZoomOut: _imageViewerController.zoomOut,
                  onZoomOneToOne: _imageViewerController.zoomToOneToOne,
                  onPrevious: () => unawaited(_goToRelativeIndex(-1)),
                  onTogglePlay: _toggleSlideshow,
                  onNext: () => unawaited(_goToRelativeIndex(1)),
                  onRotateLeft: _imageViewerController.rotateLeft,
                  onRotateRight: _imageViewerController.rotateRight,
                  onToggleInfo: () {
                    setState(() {
                      _showInfoOverlay = !_showInfoOverlay;
                    });
                  },
                  showInfo: _showInfoOverlay,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTopOverlay(ViewerState state) {
    final currentDirectoryName = state.currentDirectory == null
        ? context.l10n.folderFallback
        : p.basename(state.currentDirectory!);

    return ViewerTopOverlay(
      fileName: state.currentImage.fileName,
      positionLabel: context.l10n.viewerPosition(
        currentDirectoryName,
        state.currentIndex + 1,
        state.images.length,
      ),
    );
  }
}

class _ViewerControlBar extends StatelessWidget {
  const _ViewerControlBar({
    required this.canNavigate,
    required this.isPlaying,
    required this.onZoomIn,
    required this.onZoomOut,
    required this.onZoomOneToOne,
    required this.onPrevious,
    required this.onTogglePlay,
    required this.onNext,
    required this.onRotateLeft,
    required this.onRotateRight,
    required this.onToggleInfo,
    required this.showInfo,
  });

  final bool canNavigate;
  final bool isPlaying;
  final VoidCallback onZoomIn;
  final VoidCallback onZoomOut;
  final VoidCallback onZoomOneToOne;
  final VoidCallback onPrevious;
  final VoidCallback onTogglePlay;
  final VoidCallback onNext;
  final VoidCallback onRotateLeft;
  final VoidCallback onRotateRight;
  final VoidCallback onToggleInfo;
  final bool showInfo;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppColors.topOverlay,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x22000000),
            blurRadius: 22,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        child: Wrap(
          spacing: 8,
          runSpacing: 8,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            _ControlGroup(
              children: [
                _ControlButton(
                  tooltip: 'Zoom out',
                  icon: Icons.remove,
                  onPressed: onZoomOut,
                ),
                _ControlButton(
                  tooltip: 'Zoom in',
                  icon: Icons.add,
                  onPressed: onZoomIn,
                ),
                _OneToOneButton(onPressed: onZoomOneToOne),
              ],
            ),
            _PlaybackGroup(
              enabled: canNavigate,
              isPlaying: isPlaying,
              onPrevious: onPrevious,
              onTogglePlay: onTogglePlay,
              onNext: onNext,
            ),
            _ControlGroup(
              children: [
                _ControlButton(
                  tooltip: 'Rotate left',
                  icon: Icons.rotate_90_degrees_ccw_outlined,
                  onPressed: onRotateLeft,
                ),
                _ControlButton(
                  tooltip: 'Rotate right',
                  icon: Icons.rotate_90_degrees_cw_outlined,
                  onPressed: onRotateRight,
                ),
                _ControlButton(
                  tooltip: showInfo ? 'Hide image info' : 'Show image info',
                  icon: showInfo ? Icons.info : Icons.info_outline,
                  onPressed: onToggleInfo,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _ControlGroup extends StatelessWidget {
  const _ControlGroup({required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.04),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
        child: Row(mainAxisSize: MainAxisSize.min, children: children),
      ),
    );
  }
}

class _ControlButton extends StatelessWidget {
  const _ControlButton({
    required this.tooltip,
    required this.icon,
    required this.onPressed,
  });

  final String tooltip;
  final IconData icon;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      tooltip: tooltip,
      onPressed: onPressed,
      icon: Icon(icon, size: 18),
      visualDensity: VisualDensity.compact,
    );
  }
}

class _OneToOneButton extends StatelessWidget {
  const _OneToOneButton({required this.onPressed});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: onPressed,
      style: TextButton.styleFrom(
        minimumSize: const Size(0, 36),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
      ),
      child: const Text('1:1'),
    );
  }
}

class _PlaybackGroup extends StatelessWidget {
  const _PlaybackGroup({
    required this.enabled,
    required this.isPlaying,
    required this.onPrevious,
    required this.onTogglePlay,
    required this.onNext,
  });

  final bool enabled;
  final bool isPlaying;
  final VoidCallback onPrevious;
  final VoidCallback onTogglePlay;
  final VoidCallback onNext;

  @override
  Widget build(BuildContext context) {
    final disabled = !enabled;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.04),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _ControlButton(
              tooltip: 'Previous image',
              icon: Icons.skip_previous_rounded,
              onPressed: disabled ? null : onPrevious,
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 2),
              child: Material(
                color: Theme.of(context).colorScheme.primary,
                shape: const CircleBorder(),
                child: IconButton(
                  tooltip: isPlaying ? 'Pause slideshow' : 'Play slideshow',
                  onPressed: disabled ? null : onTogglePlay,
                  icon: Icon(
                    isPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded,
                    size: 20,
                  ),
                  color: Theme.of(context).colorScheme.onPrimary,
                ),
              ),
            ),
            _ControlButton(
              tooltip: 'Next image',
              icon: Icons.skip_next_rounded,
              onPressed: disabled ? null : onNext,
            ),
          ],
        ),
      ),
    );
  }
}

class _ViewerBackdrop extends StatelessWidget {
  const _ViewerBackdrop();

  @override
  Widget build(BuildContext context) {
    return const DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [AppColors.shellStart, AppColors.shellEnd],
        ),
      ),
      child: SizedBox.expand(),
    );
  }
}
