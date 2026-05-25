import 'dart:async';
import 'dart:io';
import 'dart:ui';

import 'package:file_selector/file_selector.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:path/path.dart' as p;
import 'package:photo_view/photo_view.dart';
import 'package:photo_view/photo_view_gallery.dart';
import 'package:window_manager/window_manager.dart';

const Set<String> _supportedImageExtensions = {
  '.bmp',
  '.gif',
  '.ico',
  '.jpeg',
  '.jpg',
  '.png',
  '.webp',
};

final XTypeGroup _imageFileGroup = XTypeGroup(
  label: 'Images',
  extensions:
      _supportedImageExtensions
          .map((extension) => extension.replaceFirst('.', ''))
          .toList()
        ..sort(),
  mimeTypes: const [
    'image/bmp',
    'image/gif',
    'image/jpeg',
    'image/png',
    'image/webp',
    'image/x-icon',
  ],
);

Future<void> main(List<String> args) async {
  WidgetsFlutterBinding.ensureInitialized();
  await windowManager.ensureInitialized();

  final windowOptions = WindowOptions(
    size: const Size(1400, 900),
    center: true,
    backgroundColor: Colors.transparent,
    titleBarStyle: TitleBarStyle.hidden,
  );

  windowManager.waitUntilReadyToShow(windowOptions, () async {
    await windowManager.show();
    await windowManager.focus();
  });

  runApp(OivApp(initialArguments: args));
}

class OivApp extends StatelessWidget {
  const OivApp({super.key, this.initialArguments = const []});

  final List<String> initialArguments;

  @override
  Widget build(BuildContext context) {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: const Color(0xFF7C5CFF),
      brightness: Brightness.dark,
    );

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Picavi',
      theme: ThemeData(
        colorScheme: colorScheme,
        brightness: Brightness.dark,
        useMaterial3: true,
        scaffoldBackgroundColor: Colors.transparent,
        visualDensity: VisualDensity.compact,
      ),
      home: OivViewerScreen(initialArguments: initialArguments),
    );
  }
}

class OivViewerScreen extends StatefulWidget {
  const OivViewerScreen({super.key, this.initialArguments = const []});

  final List<String> initialArguments;

  @override
  State<OivViewerScreen> createState() => _OivViewerScreenState();
}

class _OivViewerScreenState extends State<OivViewerScreen> {
  static const MethodChannel _fileOpenChannel = MethodChannel(
    'com.gyanoba.oiv/file_open',
  );
  static const List<int> _permissionDeniedErrorCodes = [1, 13];
  static const double _thumbnailExtent = 96;

  final ScrollController _thumbnailScrollController = ScrollController();
  final FocusNode _viewerFocusNode = FocusNode(
    debugLabel: 'viewerKeyboardFocus',
  );
  late PageController _pageController;

  List<File> _images = const [];
  String? _currentDirectory;
  int _currentIndex = 0;
  bool _enteredFullscreen = false;
  bool _isBootstrapping = true;
  bool _isPickingFile = false;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    _bindNativeFileEvents();
    unawaited(_bootstrapViewer());
  }

  @override
  void dispose() {
    _thumbnailScrollController.dispose();
    _viewerFocusNode.dispose();
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _bootstrapViewer() async {
    await _consumeMacPendingFiles();

    if (!mounted) {
      return;
    }

    await _handleOpenPaths(widget.initialArguments);

    if (mounted) {
      setState(() {
        _isBootstrapping = false;
      });
    }
  }

  void _bindNativeFileEvents() {
    _fileOpenChannel.setMethodCallHandler((call) async {
      if (call.method != 'openFiles') {
        return;
      }

      final dynamic arguments = call.arguments;
      final paths = arguments is List<Object?>
          ? arguments.whereType<String>()
          : const <String>[];
      await _handleOpenPaths(paths);
    });
  }

  Future<void> _consumeMacPendingFiles() async {
    if (!Platform.isMacOS) {
      return;
    }

    try {
      final pendingFiles = await _fileOpenChannel.invokeListMethod<String>(
        'consumePendingFiles',
      );

      if (pendingFiles != null && pendingFiles.isNotEmpty) {
        await _handleOpenPaths(pendingFiles);
      }
    } on MissingPluginException {
      // Desktop channel is only implemented on macOS native runner.
    } on PlatformException {
      // Ignore transient native startup timing issues.
    }
  }

  Future<void> _pickAndOpenImage() async {
    if (_isPickingFile) {
      return;
    }

    try {
      _isPickingFile = true;
      _viewerFocusNode.unfocus();
      FocusManager.instance.primaryFocus?.unfocus();

      await _syncKeyboardStateForNativeDialog();
      await Future<void>.delayed(const Duration(milliseconds: 10));

      final selectedPath = await _pickImagePath();

      await _syncKeyboardStateForNativeDialog();

      if (selectedPath == null || selectedPath.isEmpty) {
        return;
      }

      await _handleOpenPaths([selectedPath]);
    } catch (e) {
      debugPrint('Error picking file: $e');
    } finally {
      _isPickingFile = false;
    }
  }

  Future<String?> _pickImagePath() async {
    if (Platform.isMacOS) {
      return _pickImagePathOnMacOs();
    }

    final selectedFile = await openFile(
      acceptedTypeGroups: [_imageFileGroup],
      initialDirectory: _preferredPickerDirectory(),
      confirmButtonText: 'Open viewer',
    );

    return selectedFile?.path;
  }

  Future<String?> _pickImagePathOnMacOs() async {
    try {
      return await _fileOpenChannel.invokeMethod<String>('pickImageFile', {
        'initialDirectory': _preferredPickerDirectory(),
      });
    } on MissingPluginException {
      return null;
    } on PlatformException catch (error) {
      debugPrint('Native macOS image picker failed: ${error.message}');
      return null;
    }
  }

  String _preferredPickerDirectory() {
    if (_currentDirectory != null && _currentDirectory!.isNotEmpty) {
      return _currentDirectory!;
    }

    final homeDirectory = Platform.environment['HOME'];
    if (homeDirectory != null && homeDirectory.isNotEmpty) {
      final picturesDirectory = p.join(homeDirectory, 'Pictures');
      if (Directory(picturesDirectory).existsSync()) {
        return picturesDirectory;
      }

      return homeDirectory;
    }

    return Directory.current.path;
  }

  Future<void> _syncKeyboardStateForNativeDialog() async {
    try {
      await HardwareKeyboard.instance.syncKeyboardState();
    } catch (_) {
      // Best-effort only. Some embedders may not support keyboard state sync.
    }
  }

  Future<void> _handleOpenPaths(Iterable<String> rawPaths) async {
    for (final rawPath in rawPaths) {
      final normalizedPath = _normalizeIncomingPath(rawPath);
      if (normalizedPath == null || normalizedPath.isEmpty) {
        continue;
      }

      final entityType = await FileSystemEntity.type(normalizedPath);
      if (entityType == FileSystemEntityType.directory) {
        final images = await _readImagesFromDirectory(
          Directory(normalizedPath),
        );
        if (images.isNotEmpty) {
          await _showGallery(
            images: images,
            selectedIndex: 0,
            currentDirectory: normalizedPath,
          );
          return;
        }
      }

      if (_isSupportedImagePath(normalizedPath)) {
        await _openImagePath(normalizedPath);
        return;
      }
    }
  }

  Future<void> _openImagePath(String path) async {
    final selectedFile = File(path).absolute;
    if (!await selectedFile.exists()) {
      return;
    }

    final images = await _readImagesFromDirectory(selectedFile.parent);
    final resolvedImages = images.isEmpty ? <File>[selectedFile] : images;
    final selectedIndex = resolvedImages.indexWhere(
      (candidate) =>
          _normalizedPath(candidate.path) == _normalizedPath(selectedFile.path),
    );

    await _showGallery(
      images: resolvedImages,
      selectedIndex: selectedIndex < 0 ? 0 : selectedIndex,
      currentDirectory: selectedFile.parent.path,
    );
  }

  Future<void> _showGallery({
    required List<File> images,
    required int selectedIndex,
    required String currentDirectory,
  }) async {
    final previousController = _pageController;
    _pageController = PageController(initialPage: selectedIndex);

    if (mounted) {
      setState(() {
        _images = images;
        _currentDirectory = currentDirectory;
        _currentIndex = selectedIndex;
      });
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      previousController.dispose();
      _centerThumbnailOn(selectedIndex, animate: false);
      _viewerFocusNode.requestFocus();
    });

    await _enterFullscreenMode();
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

  Future<List<File>> _readImagesFromDirectory(
    Directory directory, {
    bool allowMacPermissionPrompt = true,
  }) async {
    final images = <File>[];

    try {
      await for (final entity in directory.list(followLinks: false)) {
        if (entity is File && _isSupportedImagePath(entity.path)) {
          images.add(entity.absolute);
        }
      }
    } on FileSystemException catch (error) {
      debugPrint(
        'Unable to read image directory ${directory.path}: ${error.message}',
      );

      if (Platform.isMacOS &&
          allowMacPermissionPrompt &&
          _isPermissionDeniedFileSystemError(error)) {
        final authorizedDirectory = await _authorizeMacDirectoryAccess(
          directory.path,
        );
        if (authorizedDirectory != null && authorizedDirectory.isNotEmpty) {
          return _readImagesFromDirectory(
            Directory(authorizedDirectory),
            allowMacPermissionPrompt: false,
          );
        }
      }

      return const <File>[];
    } catch (error) {
      debugPrint(
        'Unexpected directory scan failure for ${directory.path}: $error',
      );
      return const <File>[];
    }

    images.sort((left, right) {
      final leftName = p.basename(left.path).toLowerCase();
      final rightName = p.basename(right.path).toLowerCase();
      return leftName.compareTo(rightName);
    });

    return images;
  }

  Future<String?> _authorizeMacDirectoryAccess(String directoryPath) async {
    if (!Platform.isMacOS) {
      return null;
    }

    try {
      final grantedPath = await _fileOpenChannel.invokeMethod<String>(
        'authorizeDirectoryAccess',
        {'initialDirectory': directoryPath},
      );

      if (grantedPath == null || grantedPath.isEmpty) {
        _showStatusMessage(
          'Folder access was not granted, so only the selected image can be shown.',
        );
      }

      return grantedPath;
    } on MissingPluginException {
      return null;
    } on PlatformException catch (error) {
      debugPrint('macOS folder authorization failed: ${error.message}');
      _showStatusMessage(
        'Folder access could not be requested. Showing only the selected image.',
      );
      return null;
    }
  }

  bool _isPermissionDeniedFileSystemError(FileSystemException error) {
    final code = error.osError?.errorCode;
    if (code != null && _permissionDeniedErrorCodes.contains(code)) {
      return true;
    }

    final message = error.message.toLowerCase();
    return message.contains('operation not permitted') ||
        message.contains('permission denied');
  }

  void _showStatusMessage(String message) {
    if (!mounted) {
      return;
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) {
        return;
      }

      final messenger = ScaffoldMessenger.maybeOf(context);
      messenger
        ?..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(
            content: Text(message),
            behavior: SnackBarBehavior.floating,
            duration: const Duration(seconds: 4),
          ),
        );
    });
  }

  bool _isSupportedImagePath(String path) {
    return _supportedImageExtensions.contains(p.extension(path).toLowerCase());
  }

  String? _normalizeIncomingPath(String rawPath) {
    final trimmedPath = rawPath.trim();
    if (trimmedPath.isEmpty) {
      return null;
    }

    final uri = Uri.tryParse(trimmedPath);
    if (uri != null && uri.hasScheme && uri.scheme == 'file') {
      return uri.toFilePath();
    }

    return trimmedPath;
  }

  String _normalizedPath(String path) {
    final normalized = p.normalize(path);
    if (Platform.isWindows) {
      return normalized.toLowerCase();
    }

    return normalized;
  }

  Future<void> _goToIndex(int index) async {
    if (_images.isEmpty) {
      return;
    }

    final boundedIndex = index.clamp(0, _images.length - 1);
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
    if (event is! KeyDownEvent || _images.isEmpty) {
      return KeyEventResult.ignored;
    }

    if (event.logicalKey == LogicalKeyboardKey.arrowRight) {
      unawaited(_goToIndex(_currentIndex + 1));
      return KeyEventResult.handled;
    }

    if (event.logicalKey == LogicalKeyboardKey.arrowLeft) {
      unawaited(_goToIndex(_currentIndex - 1));
      return KeyEventResult.handled;
    }

    if (event.logicalKey == LogicalKeyboardKey.home) {
      unawaited(_goToIndex(0));
      return KeyEventResult.handled;
    }

    if (event.logicalKey == LogicalKeyboardKey.end) {
      unawaited(_goToIndex(_images.length - 1));
      return KeyEventResult.handled;
    }

    return KeyEventResult.ignored;
  }

  @override
  Widget build(BuildContext context) {
    final content = Stack(
      fit: StackFit.expand,
      children: [
        _buildBackdrop(),
        Container(color: const Color(0xB3000000)),
        if (_images.isEmpty) _buildEmptyState(context) else _buildGallery(),
        if (_images.isNotEmpty) _buildTopOverlay(context),
      ],
    );

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: _images.isEmpty
          ? content
          : Focus(
              focusNode: _viewerFocusNode,
              autofocus: true,
              onKeyEvent: _handleKeyEvent,
              child: content,
            ),
    );
  }

  Widget _buildBackdrop() {
    if (_images.isEmpty) {
      return DecoratedBox(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF181820), Color(0xFF09090C)],
          ),
        ),
        child: _isBootstrapping
            ? const Center(child: CircularProgressIndicator(strokeWidth: 2))
            : const SizedBox.expand(),
      );
    }

    return ImageFiltered(
      imageFilter: ImageFilter.blur(sigmaX: 28, sigmaY: 28),
      child: Opacity(
        opacity: 0.18,
        child: Image.file(
          _images[_currentIndex],
          fit: BoxFit.cover,
          errorBuilder: (_, _, _) => const SizedBox.expand(),
        ),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    final theme = Theme.of(context);

    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 460),
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: const Color(0xCC14141B),
            borderRadius: BorderRadius.circular(22),
            border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
          ),
          child: Padding(
            padding: const EdgeInsets.all(28),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Picavi desktop viewer',
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  'Open any supported image to launch the dense, fullscreen viewer with gesture zoom and a folder-wide thumbnail rail.',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: Colors.white70,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 18),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children:
                      _supportedImageExtensions
                          .map(
                            (extension) => Chip(
                              label: Text(
                                extension.replaceFirst('.', '').toUpperCase(),
                              ),
                              visualDensity: VisualDensity.compact,
                            ),
                          )
                          .toList()
                        ..sort(
                          (left, right) => (left.label as Text).data!.compareTo(
                            (right.label as Text).data!,
                          ),
                        ),
                ),
                const SizedBox(height: 20),
                FilledButton.icon(
                  onPressed: _pickAndOpenImage,
                  icon: const Icon(Icons.photo_library_outlined),
                  label: const Text('Open image'),
                ),
                const SizedBox(height: 10),
                Text(
                  'Tips: drag with the mouse or trackpad to pan, pinch or scroll to zoom, and use ← / → to move through the folder.',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: Colors.white54,
                    height: 1.35,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildGallery() {
    return SafeArea(
      minimum: const EdgeInsets.fromLTRB(14, 14, 14, 10),
      child: Column(
        children: [
          Expanded(
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: const Color(0x14000000),
                borderRadius: BorderRadius.circular(18),
              ),
              child: PhotoViewGallery.builder(
                pageController: _pageController,
                itemCount: _images.length,
                backgroundDecoration: const BoxDecoration(
                  color: Colors.transparent,
                ),
                scrollPhysics: const BouncingScrollPhysics(),
                loadingBuilder: (_, loadingProgress) => const Center(
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
                builder: (context, index) {
                  return PhotoViewGalleryPageOptions(
                    imageProvider: FileImage(_images[index]),
                    minScale: PhotoViewComputedScale.contained,
                    initialScale: PhotoViewComputedScale.contained,
                    maxScale: PhotoViewComputedScale.covered * 3.6,
                    filterQuality: FilterQuality.high,
                    tightMode: true,
                  );
                },
                onPageChanged: (index) {
                  setState(() {
                    _currentIndex = index;
                  });
                  _centerThumbnailOn(index);
                },
              ),
            ),
          ),
          const SizedBox(height: 10),
          _buildThumbnailRail(),
        ],
      ),
    );
  }

  Widget _buildThumbnailRail() {
    return SizedBox(
      height: _thumbnailExtent,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: const Color(0xB5121218),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
        ),
        child: ListView.builder(
          controller: _thumbnailScrollController,
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          itemCount: _images.length,
          itemBuilder: (context, index) {
            final isSelected = index == _currentIndex;

            return Padding(
              padding: const EdgeInsets.only(right: 8),
              child: InkWell(
                borderRadius: BorderRadius.circular(12),
                onTap: () => unawaited(_goToIndex(index)),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 140),
                  width: _thumbnailExtent - 8,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isSelected
                          ? Theme.of(context).colorScheme.primary
                          : Colors.white.withValues(alpha: 0.05),
                      width: isSelected ? 2 : 1,
                    ),
                    boxShadow: isSelected
                        ? [
                            BoxShadow(
                              color: Theme.of(
                                context,
                              ).colorScheme.primary.withValues(alpha: 0.28),
                              blurRadius: 16,
                            ),
                          ]
                        : const [],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(11),
                    child: Image.file(
                      _images[index],
                      fit: BoxFit.cover,
                      cacheWidth: 220,
                      errorBuilder: (_, _, _) => const ColoredBox(
                        color: Color(0xFF202028),
                        child: Center(
                          child: Icon(Icons.broken_image_outlined, size: 18),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildTopOverlay(BuildContext context) {
    final currentFile = _images[_currentIndex];
    final currentDirectoryName = _currentDirectory == null
        ? 'Folder'
        : p.basename(_currentDirectory!);

    return SafeArea(
      minimum: const EdgeInsets.fromLTRB(16, 12, 16, 0),
      child: Align(
        alignment: Alignment.topCenter,
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: const Color(0x99111117),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.photo_outlined, size: 16),
                const SizedBox(width: 10),
                ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 560),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        p.basename(currentFile.path),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.labelLarge?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '$currentDirectoryName • ${_currentIndex + 1} / ${_images.length}',
                        style: Theme.of(
                          context,
                        ).textTheme.labelSmall?.copyWith(color: Colors.white60),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
