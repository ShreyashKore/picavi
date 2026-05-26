import 'dart:async';
import 'dart:ui';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:path/path.dart' as p;
import 'package:window_manager/window_manager.dart';

import '../../../../core/l10n/l10n_extensions.dart';
import '../../../../core/theme/app_colors.dart';
import '../../data/repositories/file_system_image_repository.dart';
import '../../data/services/desktop_image_picker_service.dart';
import '../../data/services/native_file_channel_service.dart';
import '../../domain/constants/supported_image_extensions.dart';
import '../../domain/services/image_picker_service.dart';
import '../controllers/viewer_controller.dart';
import '../models/viewer_notice.dart';
import '../models/viewer_state.dart';
import '../widgets/viewer_empty_state.dart';
import '../widgets/viewer_gallery.dart';
import '../widgets/viewer_thumbnail_rail.dart';
import '../widgets/viewer_top_overlay.dart';

class ViewerScreen extends StatefulWidget {
  const ViewerScreen({super.key, this.initialArguments = const []});

  final List<String> initialArguments;

  @override
  State<ViewerScreen> createState() => _ViewerScreenState();
}

class _ViewerScreenState extends State<ViewerScreen> {
  static const double _thumbnailExtent = 96;

  final ScrollController _thumbnailScrollController = ScrollController();
  final FocusNode _viewerFocusNode = FocusNode(
    debugLabel: 'viewerKeyboardFocus',
  );
  late final PageController _pageController;
  late final ViewerController _controller;

  List<String> _lastGalleryPaths = const <String>[];
  int _lastSyncedIndex = 0;
  int? _lastNoticeId;
  bool _didBootstrap = false;
  bool _isPickingFile = false;
  bool _enteredFullscreen = false;

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
    _pageController = PageController();
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
    _controller
      ..removeListener(_onControllerChanged)
      ..dispose();
    _thumbnailScrollController.dispose();
    _viewerFocusNode.dispose();
    _pageController.dispose();
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

    if (!listEquals(_lastGalleryPaths, galleryPaths)) {
      _lastGalleryPaths = galleryPaths;
      _lastSyncedIndex = state.currentIndex;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted || !state.hasImages) {
          return;
        }

        if (_pageController.hasClients) {
          _pageController.jumpToPage(state.currentIndex);
        }
        _centerThumbnailOn(state.currentIndex, animate: false);
        _viewerFocusNode.requestFocus();
      });
      unawaited(_enterFullscreenMode());
      return;
    }

    if (_lastSyncedIndex != state.currentIndex) {
      _lastSyncedIndex = state.currentIndex;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted || !state.hasImages) {
          return;
        }

        _centerThumbnailOn(state.currentIndex);
      });
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

  Future<void> _enterFullscreenMode() async {
    try {
      if (_enteredFullscreen && await windowManager.isFullScreen()) {
        return;
      }

      await windowManager.setFullScreen(true);
      _enteredFullscreen = true;
    } catch (_) {
      _enteredFullscreen = false;
    }
  }

  Future<void> _goToIndex(int index) async {
    final state = _controller.state;
    if (!state.hasImages) {
      return;
    }

    final boundedIndex = index.clamp(0, state.images.length - 1);
    await _pageController.animateToPage(
      boundedIndex,
      duration: const Duration(milliseconds: 180),
      curve: Curves.easeOutCubic,
    );
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
      unawaited(_goToIndex(state.currentIndex + 1));
      return KeyEventResult.handled;
    }

    if (event.logicalKey == LogicalKeyboardKey.arrowLeft) {
      unawaited(_goToIndex(state.currentIndex - 1));
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
        _ViewerBackdrop(state: state),
        Container(color: AppColors.shellOverlay),
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
    return SafeArea(
      minimum: const EdgeInsets.fromLTRB(14, 14, 14, 10),
      child: Column(
        children: [
          Expanded(
            child: ViewerGallery(
              images: state.images,
              pageController: _pageController,
              onPageChanged: _controller.selectIndex,
            ),
          ),
          const SizedBox(height: 10),
          ViewerThumbnailRail(
            images: state.images,
            currentIndex: state.currentIndex,
            thumbnailExtent: _thumbnailExtent,
            scrollController: _thumbnailScrollController,
            onTap: (index) => unawaited(_goToIndex(index)),
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

class _ViewerBackdrop extends StatelessWidget {
  const _ViewerBackdrop({required this.state});

  final ViewerState state;

  @override
  Widget build(BuildContext context) {
    if (!state.hasImages) {
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

    return ImageFiltered(
      imageFilter: ImageFilter.blur(sigmaX: 28, sigmaY: 28),
      child: Opacity(
        opacity: 0.18,
        child: Image.file(
          state.currentImage.asFile,
          fit: BoxFit.cover,
          errorBuilder: (_, _, _) => const SizedBox.expand(),
        ),
      ),
    );
  }
}
