import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:path/path.dart' as p;

import '../../../../core/l10n/l10n_extensions.dart';
import '../../../../core/services/app_preferences_service.dart';
import '../../../../core/services/default_viewer_service.dart';
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
import '../widgets/viewer_control_bar.dart';
import '../widgets/viewer_empty_state.dart';
import '../widgets/viewer_thumbnail_rail.dart';
import '../widgets/viewer_top_overlay.dart';
import 'settings_screen.dart';

class ViewerScreen extends StatefulWidget {
  const ViewerScreen({super.key, this.initialArguments = const []});

  final List<String> initialArguments;

  @override
  State<ViewerScreen> createState() => _ViewerScreenState();
}

class _ViewerScreenState extends State<ViewerScreen>
    with WidgetsBindingObserver {
  static const double _thumbnailExtent = 72;
  static const double _thumbnailControlsInset = 60;
  static const Duration _slideshowInterval = Duration(seconds: 3);

  final ScrollController _thumbnailScrollController = ScrollController();
  final FocusNode _viewerFocusNode = FocusNode(
    debugLabel: 'viewerKeyboardFocus',
  );
  late final ViewerController _controller;
  late final AppPreferencesService _appPreferencesService;
  late final DefaultViewerService _defaultViewerService;
  late final InteractiveImageViewerController _imageViewerController;
  Timer? _slideshowTimer;

  List<String> _lastGalleryPaths = const <String>[];
  int _lastSyncedIndex = 0;
  int? _lastNoticeId;
  bool _didBootstrap = false;
  bool _isPickingFile = false;
  bool _isPlaying = false;
  bool _isUpdatingDefaultViewer = false;
  bool _showInfoOverlay = false;
  bool _defaultViewerPromptHandled = false;
  bool _suppressDefaultViewerHintUntilRestart = false;
  String? _lastImagePath;
  DefaultViewerStatus? _defaultViewerStatus;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    final nativeFileChannelService = NativeFileChannelService();
    _appPreferencesService = AppPreferencesService();
    _defaultViewerService = DefaultViewerService(
      nativeFileChannelService: nativeFileChannelService,
    );
    _controller = ViewerController(
      imageRepository: FileSystemImageRepository(),
      imagePickerService: DesktopImagePickerService(
        nativeChannel: nativeFileChannelService,
      ),
      nativeFileChannelService: nativeFileChannelService,
    )..addListener(_onControllerChanged);
    _imageViewerController = InteractiveImageViewerController()
      ..addListener(_onImageViewerChanged);
    unawaited(_initializeDefaultViewerState());
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      unawaited(_refreshDefaultViewerStatus());
    }
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
    WidgetsBinding.instance.removeObserver(this);
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

  Future<void> _initializeDefaultViewerState() async {
    final status = await _defaultViewerService.getStatus();
    final promptHandled = await _appPreferencesService
        .hasHandledDefaultViewerPrompt();
    if (!mounted) {
      return;
    }

    setState(() {
      _defaultViewerStatus = status;
      _defaultViewerPromptHandled = promptHandled;
    });

    if (!status.isSupported || promptHandled) {
      return;
    }

    await _appPreferencesService.markDefaultViewerPromptHandled();
    if (!mounted) {
      return;
    }

    setState(() {
      _defaultViewerPromptHandled = true;
      _suppressDefaultViewerHintUntilRestart = true;
    });

    if (status.isDefault) {
      return;
    }

    await Future<void>.delayed(Duration.zero);
    if (!mounted) {
      return;
    }

    final shouldSetDefault = await _showDefaultViewerPrompt();
    if (shouldSetDefault == true) {
      await _requestDefaultViewerUpdate();
    }
  }

  Future<void> _refreshDefaultViewerStatus() async {
    final status = await _defaultViewerService.getStatus();
    if (!mounted) {
      return;
    }

    setState(() {
      _defaultViewerStatus = status;
    });
  }

  Future<bool?> _showDefaultViewerPrompt() {
    final actionLabel = _defaultViewerActionLabel(_defaultViewerStatus);
    return showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(context.l10n.defaultViewerPromptTitle),
        content: Text(context.l10n.defaultViewerPromptMessage),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(context.l10n.notNowLabel),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(actionLabel),
          ),
        ],
      ),
    );
  }

  Future<void> _requestDefaultViewerUpdate() async {
    if (_isUpdatingDefaultViewer) {
      return;
    }

    final status = _defaultViewerStatus;
    if (status == null || !status.isSupported) {
      return;
    }

    setState(() {
      _isUpdatingDefaultViewer = true;
    });

    final result = await _defaultViewerService.requestSetAsDefault();
    final refreshedStatus = await _defaultViewerService.getStatus();
    if (!mounted) {
      return;
    }

    setState(() {
      _isUpdatingDefaultViewer = false;
      _defaultViewerStatus = refreshedStatus;
    });

    final messenger = ScaffoldMessenger.maybeOf(context);
    messenger
      ?..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(content: Text(_defaultViewerResultMessage(result.outcome))),
      );
  }

  Future<void> _openSettings() async {
    await Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (context) => SettingsScreen(
          defaultViewerService: _defaultViewerService,
          initialStatus: _defaultViewerStatus,
        ),
      ),
    );

    await _refreshDefaultViewerStatus();
  }

  String _defaultViewerActionLabel(DefaultViewerStatus? status) {
    if (status?.actionType == DefaultViewerActionType.guided) {
      return context.l10n.defaultViewerActionOpenSystemSettings;
    }

    return context.l10n.defaultViewerActionSet;
  }

  String _defaultViewerResultMessage(DefaultViewerRequestOutcome outcome) {
    return switch (outcome) {
      DefaultViewerRequestOutcome.success =>
        context.l10n.defaultViewerSetSuccess,
      DefaultViewerRequestOutcome.launchedSystemSettings =>
        context.l10n.defaultViewerFlowOpened,
      DefaultViewerRequestOutcome.failed => context.l10n.defaultViewerSetFailed,
      DefaultViewerRequestOutcome.unsupported =>
        context.l10n.defaultViewerUnsupported,
    };
  }

  bool get _showDefaultViewerHint {
    final status = _defaultViewerStatus;
    return _defaultViewerPromptHandled &&
        !_suppressDefaultViewerHintUntilRestart &&
        status != null &&
        status.needsAttention;
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
        if (_showDefaultViewerHint)
          Positioned(
            right: 18,
            bottom: state.hasImages ? 148 : 18,
            child: _DefaultViewerHintTile(
              message: context.l10n.defaultViewerHintTitle,
              actionLabel: _defaultViewerActionLabel(_defaultViewerStatus),
              settingsLabel: context.l10n.settingsTitle,
              onSetDefault: _requestDefaultViewerUpdate,
              onOpenSettings: _openSettings,
            ),
          ),
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
      settingsLabel: context.l10n.settingsTitle,
      tipsText: context.l10n.tipsText,
      onOpenImage: _pickAndOpenImage,
      onOpenSettings: _openSettings,
    );
  }

  Widget _buildGalleryContent(ViewerState state) {
    final imageViewState = _imageViewerController.value;
    final showThumbnailRail = state.images.length > 1 && !_isPlaying;
    final showControls = !_isPlaying;

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
              errorBuilder: (context, error) => ColoredBox(
                color: AppColors.brokenImage,
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.broken_image_outlined, size: 48),
                      SizedBox(height: 12),
                      Text(
                        'Failed to load image',
                        style: TextStyle(fontSize: 16, color: Colors.white70),
                      ),
                      Text(
                        '$error',
                        style: TextStyle(fontSize: 10, color: Colors.white54),
                      ),
                    ],
                  ),
                ),
              ),
              imagePadding: EdgeInsets.only(
                top: 20,
                bottom: !showControls ? 20 : _thumbnailExtent,
                left: 20,
                right: 20,
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
                if (showThumbnailRail)
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

                if (showControls)
                  ViewerControlBar(
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
      settingsTooltip: context.l10n.settingsTitle,
      onOpenSettings: _openSettings,
    );
  }
}

class _DefaultViewerHintTile extends StatelessWidget {
  const _DefaultViewerHintTile({
    required this.message,
    required this.actionLabel,
    required this.settingsLabel,
    required this.onSetDefault,
    required this.onOpenSettings,
  });

  final String message;
  final String actionLabel;
  final String settingsLabel;
  final VoidCallback onSetDefault;
  final VoidCallback onOpenSettings;

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 340),
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: AppColors.topOverlay,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
        ),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(12, 10, 12, 8),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.info_outline, size: 16),
                  const SizedBox(width: 8),
                  Flexible(
                    child: Text(
                      message,
                      style: Theme.of(context).textTheme.labelLarge,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Wrap(
                spacing: 6,
                children: [
                  TextButton(onPressed: onSetDefault, child: Text(actionLabel)),
                  TextButton(
                    onPressed: onOpenSettings,
                    child: Text(settingsLabel),
                  ),
                ],
              ),
            ],
          ),
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
