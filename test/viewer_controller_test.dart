import 'dart:async';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:oiv/viewer/data/services/native_file_channel_service.dart';
import 'package:oiv/viewer/domain/entities/gallery_image.dart';
import 'package:oiv/viewer/domain/entities/image_sort_order.dart';
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

  group('ViewerController sorting', () {
    test('re-sorts the gallery and keeps the current image selected', () async {
      final fixture = await _openFolder(<String>[
        '/images/a.png',
        '/images/b.png',
        '/images/c.png',
      ], open: '/images/b.png');
      final controller = fixture.controller;

      await controller.setSortOrder(const ImageSortOrder(ascending: false));

      expect(controller.state.images.map((image) => image.path), <String>[
        '/images/c.png',
        '/images/b.png',
        '/images/a.png',
      ]);
      expect(controller.state.currentImage.path, '/images/b.png');
      expect(controller.state.sortOrder.ascending, isFalse);
    });

    test('applies the sort order to folders opened later', () async {
      final fixture = await _openFolder(
        <String>['/images/a.png', '/images/b.png'],
        open: '/images/a.png',
        sortOrder: const ImageSortOrder(ascending: false),
      );

      expect(fixture.controller.state.images.first.path, '/images/b.png');
      expect(fixture.controller.state.currentImage.path, '/images/a.png');
    });
  });

  group('ViewerController folder watching', () {
    test('watches the folder of the opened image', () async {
      final fixture = await _openFolder(<String>[
        '/images/a.png',
      ], open: '/images/a.png');

      expect(fixture.repository.watchedDirectories, <String>['/images']);
    });

    test('adds new files and keeps the current image selected', () async {
      final fixture = await _openFolder(<String>[
        '/images/b.png',
        '/images/c.png',
      ], open: '/images/c.png');

      fixture.repository.setDirectoryImages('/images', <String>[
        '/images/a.png',
        '/images/b.png',
        '/images/c.png',
      ]);
      await fixture.emitFolderChange();

      expect(fixture.controller.state.images, hasLength(3));
      expect(fixture.controller.state.currentImage.path, '/images/c.png');
      expect(fixture.controller.state.currentIndex, 2);
    });

    test(
      'moves to the neighbouring image when the current one is removed',
      () async {
        final fixture = await _openFolder(<String>[
          '/images/a.png',
          '/images/b.png',
          '/images/c.png',
        ], open: '/images/b.png');

        fixture.repository.setDirectoryImages('/images', <String>[
          '/images/a.png',
          '/images/c.png',
        ]);
        await fixture.emitFolderChange();

        expect(fixture.controller.state.currentImage.path, '/images/c.png');
      },
    );

    test('returns to the empty state when every image is removed', () async {
      final fixture = await _openFolder(<String>[
        '/images/a.png',
      ], open: '/images/a.png');

      fixture.repository.setDirectoryImages('/images', const <String>[]);
      await fixture.emitFolderChange();

      expect(fixture.controller.state.hasImages, isFalse);
    });

    test('collapses a burst of changes into one refresh', () async {
      final fixture = await _openFolder(<String>[
        '/images/a.png',
      ], open: '/images/a.png');
      var notifications = 0;
      fixture.controller.addListener(() => notifications += 1);

      fixture.repository.setDirectoryImages('/images', <String>[
        '/images/a.png',
        '/images/b.png',
      ]);
      fixture.repository.watchEvents
        ..add(null)
        ..add(null)
        ..add(null);
      await fixture.emitFolderChange();

      expect(notifications, 1);
      expect(fixture.controller.state.images, hasLength(2));
    });
  });
}

class _FolderFixture {
  _FolderFixture(this.controller, this.repository);

  final ViewerController controller;
  final _FakeImageRepository repository;

  Future<void> emitFolderChange() async {
    repository.watchEvents.add(null);
    // Let the debounce timer fire and the refresh complete.
    await Future<void>.delayed(const Duration(milliseconds: 20));
  }
}

Future<_FolderFixture> _openFolder(
  List<String> paths, {
  required String open,
  ImageSortOrder? sortOrder,
}) async {
  final repository = _FakeImageRepository(
    supportedImages: paths.toSet(),
    directoryImages: <String, List<GalleryImage>>{},
  )..setDirectoryImages('/images', paths);
  final controller = ViewerController(
    imageRepository: repository,
    imagePickerService: _FakeImagePickerService(),
    nativeFileChannelService: _FakeNativeFileChannelService(),
    folderRefreshDebounce: const Duration(milliseconds: 5),
  );
  if (sortOrder != null) {
    await controller.setSortOrder(sortOrder);
  }
  await controller.handleOpenPaths(
    <String>[open],
    directoryAccessTexts: const DirectoryAccessTexts(
      prompt: 'Grant access',
      message: 'Read images in the current folder',
    ),
  );
  return _FolderFixture(controller, repository);
}

class _FakeImageRepository implements ImageRepository {
  _FakeImageRepository({
    required Set<String> supportedImages,
    required Map<String, List<GalleryImage>> directoryImages,
  }) : _supportedImages = supportedImages,
       _directoryImages = directoryImages;

  final Set<String> _supportedImages;
  final Map<String, List<GalleryImage>> _directoryImages;
  final StreamController<void> watchEvents = StreamController<void>.broadcast();
  final List<String> watchedDirectories = <String>[];

  void setDirectoryImages(String directoryPath, List<String> paths) {
    _directoryImages[directoryPath] = paths
        .map((path) => GalleryImage(path: path))
        .toList(growable: false);
  }

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
    String directoryPath, {
    ImageSortOrder sortOrder = const ImageSortOrder(),
  }) async {
    return sortImages(
      _directoryImages[directoryPath] ?? const <GalleryImage>[],
      sortOrder,
    );
  }

  /// Sorts by file name only; enough to observe ordering in tests.
  @override
  Future<List<GalleryImage>> sortImages(
    List<GalleryImage> images,
    ImageSortOrder sortOrder,
  ) async {
    final sorted = List<GalleryImage>.of(images)
      ..sort((left, right) => left.fileName.compareTo(right.fileName));
    return sortOrder.ascending ? sorted : sorted.reversed.toList();
  }

  @override
  Stream<void> watchDirectory(String directoryPath) {
    watchedDirectories.add(directoryPath);
    return watchEvents.stream;
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
