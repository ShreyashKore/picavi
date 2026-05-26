import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:path/path.dart' as p;

import '../../data/services/native_file_channel_service.dart';
import '../../domain/entities/gallery_image.dart';
import '../../domain/repositories/image_repository.dart';
import '../../domain/services/image_picker_service.dart';
import '../models/viewer_notice.dart';
import '../models/viewer_state.dart';

class ViewerController extends ChangeNotifier {
  ViewerController({
    required ImageRepository imageRepository,
    required ImagePickerService imagePickerService,
    required NativeFileChannelService nativeFileChannelService,
  }) : _imageRepository = imageRepository,
       _imagePickerService = imagePickerService,
       _nativeFileChannelService = nativeFileChannelService;

  static const List<int> _permissionDeniedErrorCodes = [1, 13];

  final ImageRepository _imageRepository;
  final ImagePickerService _imagePickerService;
  final NativeFileChannelService _nativeFileChannelService;

  ViewerState _state = const ViewerState.initial();
  int _noticeCounter = 0;

  ViewerState get state => _state;

  void attachNativeFileHandler(DirectoryAccessTexts directoryAccessTexts) {
    _nativeFileChannelService.setOpenFilesHandler((paths) async {
      await handleOpenPaths(paths, directoryAccessTexts: directoryAccessTexts);
    });
  }

  Future<void> bootstrap({
    required List<String> initialArguments,
    required DirectoryAccessTexts directoryAccessTexts,
  }) async {
    final pendingFiles = await _nativeFileChannelService.consumePendingFiles();
    if (pendingFiles.isNotEmpty) {
      await handleOpenPaths(
        pendingFiles,
        directoryAccessTexts: directoryAccessTexts,
      );
    }

    if (initialArguments.isNotEmpty) {
      await handleOpenPaths(
        initialArguments,
        directoryAccessTexts: directoryAccessTexts,
      );
    }

    _setState(_state.copyWith(isBootstrapping: false));
  }

  Future<void> pickAndOpenImage({
    required ImagePickerTexts pickerTexts,
    required DirectoryAccessTexts directoryAccessTexts,
  }) async {
    final selectedPath = await _imagePickerService.pickImagePath(
      initialDirectory: preferredPickerDirectory(),
      texts: pickerTexts,
    );

    if (selectedPath == null || selectedPath.isEmpty) {
      return;
    }

    await handleOpenPaths([
      selectedPath,
    ], directoryAccessTexts: directoryAccessTexts);
  }

  Future<void> handleOpenPaths(
    Iterable<String> rawPaths, {
    required DirectoryAccessTexts directoryAccessTexts,
  }) async {
    for (final rawPath in rawPaths) {
      final normalizedPath = _imageRepository.normalizeIncomingPath(rawPath);
      if (normalizedPath == null || normalizedPath.isEmpty) {
        continue;
      }

      final entityType = await _imageRepository.entityType(normalizedPath);
      if (entityType == FileSystemEntityType.directory) {
        final images = await _loadImagesFromDirectory(
          normalizedPath,
          directoryAccessTexts: directoryAccessTexts,
        );
        if (images.isNotEmpty) {
          _showGallery(
            images: images,
            selectedIndex: 0,
            currentDirectory: normalizedPath,
          );
          return;
        }
      }

      if (_imageRepository.isSupportedImagePath(normalizedPath)) {
        await _openImagePath(
          normalizedPath,
          directoryAccessTexts: directoryAccessTexts,
        );
        return;
      }
    }
  }

  Future<void> openIndex(int index) async {
    if (!_state.hasImages) {
      return;
    }

    final boundedIndex = index.clamp(0, _state.images.length - 1);
    _setState(_state.copyWith(currentIndex: boundedIndex));
  }

  void selectIndex(int index) {
    if (!_state.hasImages || index == _state.currentIndex) {
      return;
    }

    _setState(_state.copyWith(currentIndex: index));
  }

  void clearNotice() {
    if (_state.notice == null) {
      return;
    }

    _setState(_state.copyWith(clearNotice: true));
  }

  String preferredPickerDirectory() {
    if (_state.currentDirectory != null &&
        _state.currentDirectory!.isNotEmpty) {
      return _state.currentDirectory!;
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

  Future<void> _openImagePath(
    String path, {
    required DirectoryAccessTexts directoryAccessTexts,
  }) async {
    final selectedFile = File(path).absolute;
    if (!await _imageRepository.exists(selectedFile.path)) {
      return;
    }

    final images = await _loadImagesFromDirectory(
      selectedFile.parent.path,
      directoryAccessTexts: directoryAccessTexts,
    );
    final resolvedImages = images.isEmpty
        ? <GalleryImage>[GalleryImage(path: selectedFile.path)]
        : images;
    final selectedIndex = resolvedImages.indexWhere(
      (candidate) =>
          _imageRepository.normalizedPath(candidate.path) ==
          _imageRepository.normalizedPath(selectedFile.path),
    );

    _showGallery(
      images: resolvedImages,
      selectedIndex: selectedIndex < 0 ? 0 : selectedIndex,
      currentDirectory: selectedFile.parent.path,
    );
  }

  Future<List<GalleryImage>> _loadImagesFromDirectory(
    String directoryPath, {
    required DirectoryAccessTexts directoryAccessTexts,
    bool allowPermissionPrompt = true,
  }) async {
    try {
      return await _imageRepository.readImagesFromDirectory(directoryPath);
    } on FileSystemException catch (error) {
      debugPrint(
        'Unable to read image directory $directoryPath: ${error.message}',
      );

      if (Platform.isMacOS &&
          allowPermissionPrompt &&
          _isPermissionDeniedFileSystemError(error)) {
        final authorizedDirectory = await _imagePickerService
            .requestDirectoryAccess(
              initialDirectory: directoryPath,
              texts: directoryAccessTexts,
            );

        if (authorizedDirectory == null || authorizedDirectory.isEmpty) {
          _pushNotice(ViewerNoticeType.folderAccessDenied);
          return const <GalleryImage>[];
        }

        try {
          return await _loadImagesFromDirectory(
            authorizedDirectory,
            directoryAccessTexts: directoryAccessTexts,
            allowPermissionPrompt: false,
          );
        } on FileSystemException {
          _pushNotice(ViewerNoticeType.folderAccessRequestFailed);
          return const <GalleryImage>[];
        }
      }

      return const <GalleryImage>[];
    } catch (error) {
      debugPrint(
        'Unexpected directory scan failure for $directoryPath: $error',
      );
      return const <GalleryImage>[];
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

  void _showGallery({
    required List<GalleryImage> images,
    required int selectedIndex,
    required String currentDirectory,
  }) {
    _setState(
      _state.copyWith(
        images: images,
        currentDirectory: currentDirectory,
        currentIndex: selectedIndex,
      ),
    );
  }

  void _pushNotice(ViewerNoticeType type) {
    _noticeCounter += 1;
    _setState(
      _state.copyWith(
        notice: ViewerNotice(id: _noticeCounter, type: type),
      ),
    );
  }

  void _setState(ViewerState nextState) {
    _state = nextState;
    notifyListeners();
  }

  @override
  void dispose() {
    _nativeFileChannelService.setOpenFilesHandler(null);
    super.dispose();
  }
}
