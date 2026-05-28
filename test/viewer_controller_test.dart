import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:oiv/viewer/data/services/native_file_channel_service.dart';
import 'package:oiv/viewer/domain/entities/gallery_image.dart';
import 'package:oiv/viewer/domain/repositories/image_repository.dart';
import 'package:oiv/viewer/domain/services/image_picker_service.dart';
import 'package:oiv/viewer/presentation/controllers/viewer_controller.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('ViewerController.bootstrap', () {
    test(
      'prefers pending OS-opened files over restored startup arguments',
      () async {
        final repository = _FakeImageRepository(
          supportedImages: <String>{
            '/images/explicit.png',
            '/images/restored.png',
          },
          directoryImages: <String, List<GalleryImage>>{
            '/images': const <GalleryImage>[
              GalleryImage(path: '/images/explicit.png'),
              GalleryImage(path: '/images/restored.png'),
            ],
          },
        );

        final controller = ViewerController(
          imageRepository: repository,
          imagePickerService: _FakeImagePickerService(),
          nativeFileChannelService: _FakeNativeFileChannelService(
            pendingFiles: const <String>['/images/explicit.png'],
          ),
        );

        await controller.bootstrap(
          initialArguments: const <String>['/images/restored.png'],
          directoryAccessTexts: const DirectoryAccessTexts(
            prompt: 'Grant access',
            message: 'Read images in the current folder',
          ),
        );

        expect(controller.state.hasImages, isTrue);
        expect(controller.state.currentImage.path, '/images/explicit.png');
        expect(controller.state.currentDirectory, '/images');
        expect(controller.state.isBootstrapping, isFalse);
      },
    );

    test(
      'uses restored startup argument when no pending file is available',
      () async {
        final repository = _FakeImageRepository(
          supportedImages: <String>{'/images/restored.png'},
          directoryImages: <String, List<GalleryImage>>{
            '/images': const <GalleryImage>[
              GalleryImage(path: '/images/restored.png'),
            ],
          },
        );

        final controller = ViewerController(
          imageRepository: repository,
          imagePickerService: _FakeImagePickerService(),
          nativeFileChannelService: _FakeNativeFileChannelService(),
        );

        await controller.bootstrap(
          initialArguments: const <String>['/images/restored.png'],
          directoryAccessTexts: const DirectoryAccessTexts(
            prompt: 'Grant access',
            message: 'Read images in the current folder',
          ),
        );

        expect(controller.state.hasImages, isTrue);
        expect(controller.state.currentImage.path, '/images/restored.png');
        expect(controller.state.currentDirectory, '/images');
        expect(controller.state.isBootstrapping, isFalse);
      },
    );
  });
}

class _FakeImageRepository implements ImageRepository {
  _FakeImageRepository({
    required Set<String> supportedImages,
    required Map<String, List<GalleryImage>> directoryImages,
  }) : _supportedImages = supportedImages,
       _directoryImages = directoryImages;

  final Set<String> _supportedImages;
  final Map<String, List<GalleryImage>> _directoryImages;

  @override
  Future<FileSystemEntityType> entityType(String path) async {
    if (_directoryImages.containsKey(path)) {
      return FileSystemEntityType.directory;
    }

    if (_supportedImages.contains(path)) {
      return FileSystemEntityType.file;
    }

    return FileSystemEntityType.notFound;
  }

  @override
  Future<bool> exists(String path) async => _supportedImages.contains(path);

  @override
  bool isSupportedImagePath(String path) => _supportedImages.contains(path);

  @override
  Future<List<GalleryImage>> readImagesFromDirectory(
    String directoryPath,
  ) async {
    return _directoryImages[directoryPath] ?? const <GalleryImage>[];
  }

  @override
  String? normalizeIncomingPath(String rawPath) => rawPath;

  @override
  String normalizedPath(String path) => path;
}

class _FakeImagePickerService implements ImagePickerService {
  @override
  Future<String?> pickImagePath({
    required String initialDirectory,
    required ImagePickerTexts texts,
  }) async {
    return null;
  }

  @override
  Future<String?> requestDirectoryAccess({
    required String initialDirectory,
    required DirectoryAccessTexts texts,
  }) async {
    return null;
  }
}

class _FakeNativeFileChannelService extends NativeFileChannelService {
  _FakeNativeFileChannelService({this.pendingFiles = const <String>[]});

  final List<String> pendingFiles;

  @override
  Future<List<String>> consumePendingFiles() async => pendingFiles;

  @override
  void setOpenFilesHandler(
    Future<void> Function(List<String> paths)? handler,
  ) {}
}
