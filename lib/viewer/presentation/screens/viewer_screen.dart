import 'dart:async';
import 'dart:io';
import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:desktop_drop/desktop_drop.dart';
import 'package:flutter/services.dart';
import 'package:path/path.dart' as p;
import 'package:window_manager/window_manager.dart';

import '../../../../core/l10n/l10n_extensions.dart';
import '../../../../core/services/app_preferences_service.dart';
import '../../../../core/services/default_viewer_service.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../core/widgets/app_image.dart';
import '../../../editor/data/repositories/sidecar_image_edit_repository.dart';
import '../../../editor/data/services/edited_image_provider.dart';
import '../../../editor/data/services/flutter_image_pixel_source.dart';
import '../../../editor/data/services/raster_image_export_service.dart';
import '../../../editor/data/services/rendering_quick_fix_service.dart';
import '../../../editor/domain/entities/image_edits.dart';
import '../../../editor/domain/services/quick_fix_service.dart';
import '../../../editor/presentation/screens/editor_screen.dart';
import '../../../editor/presentation/widgets/export_options_dialog.dart';
import '../../../library/data/library_services.dart';
import '../../../library/data/repositories/sidecar_photo_info_repository.dart';
import '../../../library/presentation/screens/library_screen.dart';
import '../../data/repositories/file_system_image_repository.dart';
import '../../data/services/desktop_file_operations_service.dart';
import '../../data/services/desktop_image_picker_service.dart';
import '../../data/services/native_file_channel_service.dart';
import '../../data/services/raster_image_transform_service.dart';
import '../../data/services/slideshow_settings_store.dart';
import '../../data/platform_image_formats.dart';
import '../../domain/entities/image_sort_order.dart';
import '../../domain/entities/recent_folder.dart';
import '../../domain/entities/slideshow_settings.dart';
import '../../domain/repositories/image_repository.dart';
import '../../domain/services/image_picker_service.dart';
import '../controllers/viewer_controller.dart';
import '../models/viewer_notice.dart';
import '../models/viewer_state.dart';
import '../widgets/caption_tags_dialog.dart';
import '../widgets/image_info_overlay.dart';
import '../widgets/interactive_image_viewer.dart';
import '../widgets/keyboard_shortcuts_dialog.dart';
import '../widgets/recent_folders_panel.dart';
import '../widgets/rename_image_dialog.dart';
import '../widgets/viewer_actions_menu.dart';
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
    with WidgetsBindingObserver, WindowListener {
  static const double _thumbnailExtent = 72;
  static const double _thumbnailControlsInset = 60;
  static const int _recentFolderPreviewCount = 4;

  final ScrollController _thumbnailScrollController = ScrollController();
  final FocusNode _viewerFocusNode = FocusNode(
    debugLabel: 'viewerKeyboardFocus',
  );
  late final ImageRepository _imageRepository;
  late final ViewerController _controller;
  final SidecarImageEditRepository _editRepository =
      SidecarImageEditRepository();
  static const FlutterImagePixelSource _pixelSource = FlutterImagePixelSource();
  late final DesktopFileOperationsService _fileOperations;
  Future<LibraryServices>? _libraryServices;
  late final AppPreferencesService _appPreferencesService;
  late final DefaultViewerService _defaultViewerService;
  late final InteractiveImageViewerController _imageViewerController;
  Timer? _slideshowTimer;
  SlideshowSequencer? _slideshowSequencer;
  SlideshowSettings _slideshowSettings = const SlideshowSettings();
  late final SlideshowSettingsStore _slideshowSettingsStore;
  bool _isFullScreen = false;
  bool _enteredFullScreenForSlideshow = false;
  bool _isDraggingFiles = false;

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
  bool _restoreLastOpenedImageEnabled = false;
  bool _showRecentFoldersEnabled = false;
  List<RecentFolder> _recentFolders = const <RecentFolder>[];
  String? _lastImagePath;
  DefaultViewerStatus? _defaultViewerStatus;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    windowManager.addListener(this);
    final nativeFileChannelService = NativeFileChannelService();
    _appPreferencesService = AppPreferencesService();
    _imageRepository = FileSystemImageRepository();
    _defaultViewerService = DefaultViewerService(
      nativeFileChannelService: nativeFileChannelService,
    );
    _controller = ViewerController(
      imageRepository: _imageRepository,
      imagePickerService: DesktopImagePickerService(
        nativeChannel: nativeFileChannelService,
      ),
      nativeFileChannelService: nativeFileChannelService,
      fileOperationsService: _fileOperations = DesktopFileOperationsService(
        nativeChannel: nativeFileChannelService,
      ),
      imageTransformService: RasterImageTransformService(),
      editRepository: _editRepository,
      photoInfoRepository: const SidecarPhotoInfoRepository(),
      quickFixService: const RenderingQuickFixService(),
      exportService: const RasterImageExportService(),
      evictImage: (path) => AppImage.evictFile(
        path,
        cacheWidths: const [ViewerThumbnailRail.cacheWidth],
      ),
    )..addListener(_onControllerChanged);
    _imageViewerController = InteractiveImageViewerController()
      ..addListener(_onImageViewerChanged);
    unawaited(_initializeDefaultViewerState());
    unawaited(_refreshRestoreLastOpenedImagePreference());
    unawaited(_refreshRecentFolders());
    unawaited(_restoreSortOrder());
    _slideshowSettingsStore = SlideshowSettingsStore(_appPreferencesService);
    unawaited(_loadSlideshowSettings());
    unawaited(_syncFullScreenState());
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
      _controller
          .bootstrap(
            initialArguments: widget.initialArguments,
            directoryAccessTexts: directoryAccessTexts,
          )
          .then((_) {
            if (mounted && !_controller.state.hasImages) {
              unawaited(_refreshRecentFolders());
            }
          }),
    );
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    windowManager.removeListener(this);
    _stopSlideshow(rebuild: false);
    _imageViewerController
      ..removeListener(_onImageViewerChanged)
      ..dispose();
    _controller
      ..removeListener(_onControllerChanged)
      ..dispose();
    _thumbnailScrollController.dispose();
    _viewerFocusNode.dispose();
    unawaited(_libraryServices?.then((services) => services.close()));
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

  Future<void> _refreshRestoreLastOpenedImagePreference() async {
    final isEnabled = await _appPreferencesService
        .isRestoreLastOpenedImageEnabled();
    if (!mounted) {
      return;
    }

    final shouldRebuild = _restoreLastOpenedImageEnabled != isEnabled;
    _restoreLastOpenedImageEnabled = isEnabled;
    if (shouldRebuild) {
      setState(() {});
    }

    if (!isEnabled) {
      return;
    }

    final state = _controller.state;
    if (state.hasImages) {
      await _persistLastOpenedImagePath(state.currentImage.path);
    }
  }

  Future<void> _restoreSortOrder() async {
    final key = await _appPreferencesService.getImageSortOrderKey();
    if (!mounted || key == null) {
      return;
    }

    await _controller.setSortOrder(ImageSortOrder.fromStorageKey(key));
  }

  Future<void> _changeSortOrder(ImageSortOrder sortOrder) async {
    await _controller.setSortOrder(sortOrder);
    await _appPreferencesService.setImageSortOrderKey(sortOrder.storageKey);
  }

  Future<void> _showKeyboardShortcuts() async {
    await showKeyboardShortcutsDialog(context);
    if (mounted) {
      _viewerFocusNode.requestFocus();
    }
  }

  bool get _isCommandPressed {
    final keyboard = HardwareKeyboard.instance;
    return Platform.isMacOS
        ? keyboard.isMetaPressed
        : keyboard.isControlPressed;
  }

  void _handleThumbnailTap(int index) {
    if (_isCommandPressed) {
      _controller.toggleSelection(index);
    } else if (HardwareKeyboard.instance.isShiftPressed) {
      _controller.selectRange(index);
    } else {
      _controller.clearSelection();
      unawaited(_goToIndex(index));
    }
    _viewerFocusNode.requestFocus();
  }

  void _handleEscape() {
    if (_controller.state.hasSelection) {
      _controller.clearSelection();
      return;
    }
    if (_isPlaying) {
      _stopSlideshow();
      return;
    }
    if (_isFullScreen) {
      unawaited(_setFullScreen(false));
      return;
    }
    _closeApp();
  }

  Future<void> _syncFullScreenState() async {
    try {
      final isFullScreen = await windowManager.isFullScreen();
      if (mounted && isFullScreen != _isFullScreen) {
        setState(() => _isFullScreen = isFullScreen);
      }
    } catch (error) {
      debugPrint('Unable to read full screen state: $error');
    }
  }

  Future<void> _setFullScreen(bool fullScreen) async {
    try {
      await windowManager.setFullScreen(fullScreen);
    } catch (error) {
      debugPrint('Unable to change full screen: $error');
    }
    await _syncFullScreenState();
  }

  void _toggleFullScreen() {
    _enteredFullScreenForSlideshow = false;
    unawaited(_setFullScreen(!_isFullScreen));
  }

  @override
  void onWindowEnterFullScreen() {
    if (mounted) {
      setState(() => _isFullScreen = true);
    }
  }

  @override
  void onWindowLeaveFullScreen() {
    if (mounted) {
      setState(() => _isFullScreen = false);
    }
  }

  Future<void> _openDroppedFiles(List<String> paths) async {
    if (paths.isEmpty) {
      return;
    }
    _stopSlideshow();
    await _controller.handleOpenPaths(
      paths,
      directoryAccessTexts: _directoryAccessTexts,
    );
  }

  Future<void> _handleFileAction(ViewerFileAction action) async {
    final l10n = context.l10n;
    DirectoryAccessTexts destinationTexts(String prompt) =>
        DirectoryAccessTexts(
          prompt: prompt,
          message: l10n.chooseDestinationMessage,
        );

    switch (action) {
      case ViewerFileAction.edit:
        await _openEditor();
      case ViewerFileAction.export:
        await _exportTargets();
      case ViewerFileAction.feelingLucky:
        await _controller.quickFixTargets(QuickFix.feelingLucky);
      case ViewerFileAction.autoContrast:
        await _controller.quickFixTargets(QuickFix.autoContrast);
      case ViewerFileAction.autoColor:
        await _controller.quickFixTargets(QuickFix.autoColor);
      case ViewerFileAction.blackAndWhite:
        await _controller.quickFixTargets(QuickFix.blackAndWhite);
      case ViewerFileAction.sepia:
        await _controller.quickFixTargets(QuickFix.sepia);
      case ViewerFileAction.removeEdits:
        await _controller.removeEditsFromTargets();
      case ViewerFileAction.captionTags:
        await _editCaptionAndTags();
      case ViewerFileAction.hide:
        await _controller.setTargetsHidden(true);
      case ViewerFileAction.unhide:
        await _controller.setTargetsHidden(false);
      case ViewerFileAction.rename:
        await _renameCurrentImage();
      case ViewerFileAction.copyToFolder:
        await _controller.copyTargetsToFolder(
          pickerTexts: destinationTexts(l10n.copyHerePrompt),
        );
      case ViewerFileAction.moveToFolder:
        await _controller.moveTargetsToFolder(
          pickerTexts: destinationTexts(l10n.moveHerePrompt),
        );
      case ViewerFileAction.copyImage:
        await _controller.copyCurrentImageToClipboard();
      case ViewerFileAction.reveal:
        await _controller.revealCurrent();
      case ViewerFileAction.openWith:
        await _controller.openCurrentWith(prompt: l10n.openWithPrompt);
      case ViewerFileAction.moveToTrash:
        await _confirmAndTrash();
    }

    if (mounted) {
      _viewerFocusNode.requestFocus();
    }
  }

  DirectoryAccessTexts get _exportFolderTexts => DirectoryAccessTexts(
    prompt: context.l10n.exportChooseFolder,
    message: context.l10n.chooseDestinationMessage,
  );

  bool get _canEditCurrent {
    final state = _controller.state;
    return state.hasImages && _pixelSource.canEdit(state.currentImage.path);
  }

  Future<void> _openEditor() async {
    if (!_canEditCurrent) {
      return;
    }
    _stopSlideshow();
    final path = _controller.state.currentImage.path;
    final edits = await Navigator.of(context).push<ImageEdits>(
      MaterialPageRoute(
        builder: (context) => EditorScreen(
          path: path,
          repository: _editRepository,
          pixelSource: _pixelSource,
          pickExportDirectory: () => _controller.pickFolder(_exportFolderTexts),
        ),
      ),
    );
    if (edits != null) {
      _controller.setEdits(path, edits);
    }
    if (mounted) {
      _viewerFocusNode.requestFocus();
    }
  }

  Future<void> _openLibrary() async {
    _stopSlideshow();
    LibraryServices services;
    try {
      services = await (_libraryServices ??= LibraryServices.open(
        preferences: _appPreferencesService,
        fileOperations: _fileOperations,
      ));
    } catch (error) {
      debugPrint('Unable to open the library: $error');
      _libraryServices = null;
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(context.l10n.libraryOpenFailed)));
      }
      return;
    }
    if (!mounted) {
      return;
    }
    final path = await Navigator.of(context).push<String>(
      MaterialPageRoute(
        builder: (context) => LibraryScreen(
          services: services,
          pickFolder: () => _controller.pickFolder(
            DirectoryAccessTexts(
              prompt: context.l10n.libraryAddFolder,
              message: context.l10n.libraryPickFolderMessage,
            ),
          ),
        ),
      ),
    );
    if (path != null) {
      await _controller.handleOpenPaths([
        path,
      ], directoryAccessTexts: _directoryAccessTexts);
    } else if (_controller.state.hasImages) {
      // Stars or captions may have changed in the library.
      await _controller.reloadSidecarData();
    }
    if (mounted && _controller.state.hasImages) {
      _viewerFocusNode.requestFocus();
    }
  }

  Future<void> _editCaptionAndTags() async {
    final state = _controller.state;
    if (!state.hasImages) {
      return;
    }
    _stopSlideshow();
    final path = state.currentImage.path;
    final result = await showCaptionTagsDialog(
      context,
      info: state.photoInfoFor(path),
    );
    if (result != null) {
      await _controller.setCaptionAndTags(path, result.$1, result.$2);
    }
    if (mounted) {
      _viewerFocusNode.requestFocus();
    }
  }

  Future<void> _exportTargets() async {
    final count = _controller.state.actionTargets.length;
    if (count == 0) {
      return;
    }
    _stopSlideshow();
    final options = await showExportOptionsDialog(context, imageCount: count);
    if (options == null || !mounted) {
      return;
    }
    await _controller.exportTargets(
      options: options,
      pickerTexts: _exportFolderTexts,
    );
  }

  Future<void> _renameCurrentImage() async {
    final state = _controller.state;
    if (!state.hasImages) {
      return;
    }

    _stopSlideshow();
    await showRenameImageDialog(
      context,
      currentFileName: state.currentImage.fileName,
      onRename: _controller.renameCurrent,
    );
    if (mounted) {
      _viewerFocusNode.requestFocus();
    }
  }

  Future<void> _confirmAndTrash() async {
    final count = _controller.state.actionTargets.length;
    if (count == 0) {
      return;
    }

    _stopSlideshow();
    final l10n = context.l10n;
    final binName = trashNameFor(l10n);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.trashConfirmTitle(count, binName)),
        content: Text(l10n.trashConfirmMessage(binName)),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(l10n.cancelLabel),
          ),
          FilledButton(
            autofocus: true,
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(l10n.moveToTrashAction(count, binName)),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await _controller.trashTargets();
    }
    if (mounted) {
      _viewerFocusNode.requestFocus();
    }
  }

  Future<void> _saveRotation() async {
    final turns = _imageViewerController.value.rotationQuarterTurns;
    if (turns % 4 == 0 || !_controller.state.hasImages) {
      return;
    }
    _stopSlideshow();
    await _controller.saveCurrentRotation(turns);
  }

  void _toggleInfoOverlay() {
    setState(() {
      _showInfoOverlay = !_showInfoOverlay;
    });
  }

  Future<void> _persistLastOpenedImagePath(String imagePath) async {
    if (!_restoreLastOpenedImageEnabled) {
      return;
    }

    await _appPreferencesService.setLastOpenedImagePath(imagePath);
  }

  Future<void> _refreshRecentFolders() async {
    final enabled = await _appPreferencesService.isShowRecentFoldersEnabled();
    if (!mounted) {
      return;
    }

    _showRecentFoldersEnabled = enabled;
    if (!enabled) {
      if (_recentFolders.isNotEmpty) {
        setState(() {
          _recentFolders = const <RecentFolder>[];
        });
      }
      return;
    }

    final paths = await _appPreferencesService.getRecentFolders();
    final folders = <RecentFolder>[];
    final stalePaths = <String>[];

    for (final path in paths) {
      try {
        final entityType = await _imageRepository.entityType(path);
        if (entityType != FileSystemEntityType.directory) {
          stalePaths.add(path);
          continue;
        }

        final images = await _imageRepository.readImagesFromDirectory(path);
        if (images.isEmpty) {
          stalePaths.add(path);
          continue;
        }

        folders.add(
          RecentFolder(
            path: path,
            previewImages: images
                .take(_recentFolderPreviewCount)
                .toList(growable: false),
            imageCount: images.length,
          ),
        );
      } catch (error) {
        // Keep folders we simply couldn't read this time (e.g. a transient
        // permission issue); only entries that are gone are pruned below.
        debugPrint('Unable to load recent folder $path: $error');
      }
    }

    for (final stalePath in stalePaths) {
      await _appPreferencesService.removeRecentFolder(stalePath);
    }

    if (!mounted) {
      return;
    }

    setState(() {
      _recentFolders = folders;
    });
  }

  void _persistRecentFolder(String? directoryPath) {
    if (directoryPath == null || directoryPath.isEmpty) {
      return;
    }

    unawaited(_appPreferencesService.addRecentFolder(directoryPath));
  }

  Future<void> _openRecentFolder(RecentFolder folder) async {
    await _controller.handleOpenPaths([
      folder.path,
    ], directoryAccessTexts: _directoryAccessTexts);
  }

  Future<void> _removeRecentFolder(RecentFolder folder) async {
    await _appPreferencesService.removeRecentFolder(folder.path);
    if (!mounted) {
      return;
    }

    setState(() {
      _recentFolders = _recentFolders
          .where((candidate) => candidate.path != folder.path)
          .toList(growable: false);
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
          appPreferencesService: _appPreferencesService,
          defaultViewerService: _defaultViewerService,
          initialStatus: _defaultViewerStatus,
          slideshowSettingsStore: _slideshowSettingsStore,
        ),
      ),
    );

    await _refreshDefaultViewerStatus();
    await _refreshRestoreLastOpenedImagePreference();
    await _refreshRecentFolders();
    await _loadSlideshowSettings();
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
      unawaited(_persistLastOpenedImagePath(currentImagePath));
      _persistRecentFolder(state.currentDirectory);
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
      unawaited(_persistLastOpenedImagePath(currentImagePath));
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
      ..showSnackBar(SnackBar(content: Text(_localizedNoticeMessage(notice))));
    _controller.clearNotice();
  }

  String _localizedNoticeMessage(ViewerNotice notice) {
    final l10n = context.l10n;
    final binName = trashNameFor(l10n);
    return switch (notice.type) {
      ViewerNoticeType.folderAccessDenied => l10n.folderAccessDenied,
      ViewerNoticeType.folderAccessRequestFailed =>
        l10n.folderAccessRequestFailed,
      ViewerNoticeType.movedToTrash => l10n.movedToTrashNotice(
        notice.count,
        binName,
      ),
      ViewerNoticeType.trashFailed => l10n.trashFailedNotice(
        notice.count,
        binName,
      ),
      ViewerNoticeType.copied => l10n.copiedNotice(notice.count),
      ViewerNoticeType.moved => l10n.movedNotice(notice.count),
      ViewerNoticeType.copyFailed => l10n.copyFailedNotice(notice.count),
      ViewerNoticeType.moveFailed => l10n.moveFailedNotice(notice.count),
      ViewerNoticeType.imageCopiedToClipboard => l10n.imageCopiedNotice,
      ViewerNoticeType.clipboardFailed => l10n.clipboardFailedNotice,
      ViewerNoticeType.revealFailed => l10n.revealFailedNotice,
      ViewerNoticeType.openWithFailed => l10n.openWithFailedNotice,
      ViewerNoticeType.rotationSaved => l10n.rotationSavedNotice,
      ViewerNoticeType.rotationUnsupported => l10n.rotationUnsupportedNotice(
        notice.detail ?? '',
      ),
      ViewerNoticeType.rotationSaveFailed => l10n.rotationSaveFailedNotice,
      ViewerNoticeType.rotationAddedToEdits => l10n.rotationAddedToEditsNotice,
      ViewerNoticeType.exported => l10n.exportedNotice(notice.count),
      ViewerNoticeType.exportFailed => l10n.exportFailedNotice(notice.count),
      ViewerNoticeType.quickFixApplied => l10n.quickFixAppliedNotice(
        notice.count,
      ),
      ViewerNoticeType.quickFixFailed => l10n.quickFixFailedNotice(
        notice.count,
      ),
      ViewerNoticeType.editsRemoved => l10n.editsRemovedNotice(notice.count),
      ViewerNoticeType.photoInfoSaveFailed => l10n.photoInfoSaveFailedNotice,
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

  Future<void> _loadSlideshowSettings() async {
    final settings = await _slideshowSettingsStore.load();
    if (mounted) {
      _slideshowSettings = settings;
    }
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

    final settings = _slideshowSettings;
    setState(() {
      _isPlaying = true;
    });
    _slideshowSequencer = SlideshowSequencer(
      imageCount: state.images.length,
      startIndex: state.currentIndex,
      shuffle: settings.shuffle,
      loop: settings.loop,
    );
    _slideshowTimer?.cancel();
    _slideshowTimer = Timer.periodic(settings.interval, (_) {
      final current = _controller.state;
      final next = _slideshowSequencer?.next(
        currentIndex: current.hasImages ? current.currentIndex : null,
      );
      if (next == null) {
        _stopSlideshow();
        return;
      }
      unawaited(_goToIndex(next));
    });

    if (settings.fullScreen && !_isFullScreen) {
      _enteredFullScreenForSlideshow = true;
      unawaited(_setFullScreen(true));
    }
  }

  void _stopSlideshow({bool rebuild = true}) {
    _slideshowTimer?.cancel();
    _slideshowTimer = null;
    _slideshowSequencer = null;
    if (_enteredFullScreenForSlideshow) {
      _enteredFullScreenForSlideshow = false;
      if (mounted) {
        unawaited(_setFullScreen(false));
      }
    }
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

    if (event.logicalKey == LogicalKeyboardKey.escape) {
      _handleEscape();
      return KeyEventResult.handled;
    }

    final keyboard = HardwareKeyboard.instance;
    if (_isCommandPressed && !keyboard.isAltPressed) {
      final commandAction = _commandShortcutActionFor(event.logicalKey);
      if (commandAction == null) {
        return KeyEventResult.ignored;
      }
      commandAction();
      return KeyEventResult.handled;
    }

    if (keyboard.isMetaPressed ||
        keyboard.isControlPressed ||
        keyboard.isAltPressed) {
      return KeyEventResult.ignored;
    }

    final action = _shortcutActionFor(
      event,
      isShiftPressed: keyboard.isShiftPressed,
    );
    if (action == null) {
      return KeyEventResult.ignored;
    }

    action();
    return KeyEventResult.handled;
  }

  /// Cmd (macOS) / Ctrl (Windows, Linux) shortcuts. Keep in sync with
  /// `keyboard_shortcuts_dialog.dart`.
  VoidCallback? _commandShortcutActionFor(LogicalKeyboardKey key) {
    if (key == LogicalKeyboardKey.keyC) {
      return () => unawaited(_controller.copyCurrentImageToClipboard());
    }
    if (key == LogicalKeyboardKey.keyA) {
      return _controller.selectAll;
    }
    if (key == LogicalKeyboardKey.backspace) {
      return () => unawaited(_confirmAndTrash());
    }
    if (key == LogicalKeyboardKey.keyS) {
      return () => unawaited(_saveRotation());
    }
    return null;
  }

  /// Single-key viewer shortcuts. Keep in sync with
  /// `keyboard_shortcuts_dialog.dart`.
  VoidCallback? _shortcutActionFor(
    KeyEvent event, {
    required bool isShiftPressed,
  }) {
    final key = event.logicalKey;
    final character = event.character;

    if (character == '?' ||
        (key == LogicalKeyboardKey.slash && isShiftPressed)) {
      return () => unawaited(_showKeyboardShortcuts());
    }
    if (key == LogicalKeyboardKey.space) {
      return _toggleSlideshow;
    }
    if (character == '+' ||
        key == LogicalKeyboardKey.equal ||
        key == LogicalKeyboardKey.numpadAdd) {
      return _imageViewerController.zoomIn;
    }
    if (key == LogicalKeyboardKey.minus ||
        key == LogicalKeyboardKey.numpadSubtract) {
      return _imageViewerController.zoomOut;
    }
    if (key == LogicalKeyboardKey.digit1 || key == LogicalKeyboardKey.numpad1) {
      return _imageViewerController.zoomToOneToOne;
    }
    if (key == LogicalKeyboardKey.digit0 || key == LogicalKeyboardKey.numpad0) {
      return _imageViewerController.toggleFitFill;
    }
    if (key == LogicalKeyboardKey.keyF || key == LogicalKeyboardKey.f11) {
      return _toggleFullScreen;
    }
    if (key == LogicalKeyboardKey.keyR) {
      return isShiftPressed
          ? _imageViewerController.rotateLeft
          : _imageViewerController.rotateRight;
    }
    if (key == LogicalKeyboardKey.keyI) {
      return _toggleInfoOverlay;
    }
    if (key == LogicalKeyboardKey.keyE) {
      return () => unawaited(_openEditor());
    }
    if (key == LogicalKeyboardKey.keyS) {
      return () => unawaited(_controller.toggleStarTargets());
    }
    if (key == LogicalKeyboardKey.keyL) {
      return () => unawaited(_openLibrary());
    }
    if (key == LogicalKeyboardKey.delete ||
        key == LogicalKeyboardKey.backspace) {
      return () => unawaited(_confirmAndTrash());
    }
    if (key == LogicalKeyboardKey.f2) {
      return () => unawaited(_renameCurrentImage());
    }

    return null;
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
        if (state.isWorking)
          const Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: LinearProgressIndicator(minHeight: 2),
          ),
        Positioned(
          right: 0,
          top: 0,
          child: _ViewerCloseButton(onPressed: _closeApp),
        ),
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

    return CallbackShortcuts(
      bindings: {
        const SingleActivator(LogicalKeyboardKey.escape): _handleEscape,
      },
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: DropTarget(
          onDragEntered: (_) => setState(() => _isDraggingFiles = true),
          onDragExited: (_) => setState(() => _isDraggingFiles = false),
          onDragDone: (details) {
            setState(() => _isDraggingFiles = false);
            unawaited(
              _openDroppedFiles(
                details.files.map((file) => file.path).toList(),
              ),
            );
          },
          child: Stack(
            fit: StackFit.expand,
            children: [
              if (state.hasImages)
                Focus(
                  focusNode: _viewerFocusNode,
                  autofocus: true,
                  onKeyEvent: _handleKeyEvent,
                  child: content,
                )
              else
                content,
              if (_isDraggingFiles)
                _DropHighlight(label: context.l10n.dropToOpen),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return ViewerEmptyState(
      isBootstrapping: _controller.state.isBootstrapping || _isPickingFile,
      supportedExtensions: platformImageExtensions,
      title: context.l10n.emptyStateTitle,
      description: context.l10n.emptyStateDescription,
      openImageLabel: context.l10n.openImage,
      settingsLabel: context.l10n.settingsTitle,
      tipsText: context.l10n.tipsText,
      onOpenImage: _pickAndOpenImage,
      onOpenSettings: _openSettings,
      libraryLabel: context.l10n.libraryTitle,
      onOpenLibrary: () => unawaited(_openLibrary()),
      recentFolders: _showRecentFoldersEnabled && _recentFolders.isNotEmpty
          ? RecentFoldersPanel(
              folders: _recentFolders,
              title: context.l10n.recentFoldersTitle,
              imageCountLabel: (count) =>
                  context.l10n.recentFolderImageCount(count),
              removeTooltip: context.l10n.recentFolderRemoveTooltip,
              onOpen: (folder) => unawaited(_openRecentFolder(folder)),
              onRemove: (folder) => unawaited(_removeRecentFolder(folder)),
            )
          : null,
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
              image: _currentImageWidget(state),
              semanticLabel: state.currentImage.fileName,
              errorBuilder: (context, error) => Center(
                child: Container(
                  decoration: BoxDecoration(
                    color: AppColors.topOverlay,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.broken_image_outlined, size: 48),
                      SizedBox(height: 12),
                      Text(
                        context.l10n.imageLoadFailed,
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
                caption: state.photoInfoFor(state.currentImage.path).caption,
                tags: state.photoInfoFor(state.currentImage.path).tags,
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
                      onTap: _handleThumbnailTap,
                      selectedPaths: state.selectedPaths,
                      edits: state.edits,
                      starredPaths: {
                        for (final entry in state.photoInfo.entries)
                          if (entry.value.starred) entry.key,
                      },
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
                    onToggleInfo: _toggleInfoOverlay,
                    isFillingWindow: imageViewState.isFillingViewport,
                    onToggleFitFill: _imageViewerController.toggleFitFill,
                    isFullScreen: _isFullScreen,
                    onToggleFullScreen: _toggleFullScreen,
                    onSaveRotation: imageViewState.rotationQuarterTurns % 4 != 0
                        ? () => unawaited(_saveRotation())
                        : null,
                    showInfo: _showInfoOverlay,
                    onEdit: _canEditCurrent
                        ? () => unawaited(_openEditor())
                        : null,
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// The current image, with its edits applied when it has any.
  AppImage _currentImageWidget(ViewerState state) {
    final image = state.currentImage;
    final edits = state.editsFor(image.path);
    if (edits.isEmpty) {
      return AppImage.file(
        image.path,
        revision: image.revision,
        fit: BoxFit.contain,
        filterQuality: FilterQuality.high,
        errorBuilder: (_, _, _) => const SizedBox.expand(),
      );
    }
    return AppImage(
      image: EditedImageProvider(
        image.path,
        edits,
        maxDimension: EditedImageProvider.viewerMaxDimension,
        revision: image.revision,
      ),
      filePath: image.path,
      revision: image.revision,
      fit: BoxFit.contain,
      filterQuality: FilterQuality.high,
      errorBuilder: (_, _, _) => const SizedBox.expand(),
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
      sortOrder: state.sortOrder,
      onSortOrderChanged: (sortOrder) => unawaited(_changeSortOrder(sortOrder)),
      onShowShortcuts: () => unawaited(_showKeyboardShortcuts()),
      actionsMenu: ViewerActionsMenu(
        targetCount: state.actionTargets.length,
        canEdit: _canEditCurrent,
        hasEdits: state.actionTargets.any(
          (path) => state.editsFor(path).isNotEmpty,
        ),
        allHidden: state.actionTargets.every(
          (path) => state.photoInfoFor(path).hidden,
        ),
        onSelected: (action) => unawaited(_handleFileAction(action)),
      ),
      selectionCount: state.selectedPaths.length,
      onClearSelection: _controller.clearSelection,
      isStarred: state.photoInfoFor(state.currentImage.path).starred,
      onToggleStar: () => unawaited(_controller.toggleStarTargets()),
      onOpenLibrary: () => unawaited(_openLibrary()),
    );
  }

  void _closeApp() {
    windowManager.close();
  }
}

class _ViewerCloseButton extends StatelessWidget {
  const _ViewerCloseButton({required this.onPressed});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: onPressed,
        child: SizedBox(
          width: 48,
          height: 48,
          child: Stack(
            children: [
              CustomPaint(
                size: const Size(48, 48),
                painter: _QuarterCirclePainter(),
              ),
              Positioned(
                right: 8,
                top: 8,
                child: Icon(
                  Icons.close,
                  size: 18,
                  color: Colors.white.withValues(alpha: 0.4),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _QuarterCirclePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withValues(alpha: 0.22)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2;

    canvas.drawArc(
      Rect.fromLTWH(-size.width, -size.height, size.width * 2, size.height * 2),
      -pi / 2,
      pi / 2,
      false,
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
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

class _DropHighlight extends StatelessWidget {
  const _DropHighlight({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;
    return IgnorePointer(
      child: Container(
        margin: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: primary.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: primary, width: 2),
        ),
        alignment: Alignment.center,
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: AppColors.topOverlay,
            borderRadius: BorderRadius.circular(14),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.file_download_outlined, color: primary),
                const SizedBox(width: 10),
                Text(label, style: Theme.of(context).textTheme.titleMedium),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
