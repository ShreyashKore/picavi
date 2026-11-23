import 'dart:async';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:oiv/viewer/data/services/native_file_channel_service.dart';
import 'package:oiv/viewer/domain/entities/gallery_image.dart';
import 'package:oiv/viewer/domain/entities/image_sort_order.dart';
import 'package:oiv/viewer/domain/repositories/image_repository.dart';
import 'package:oiv/viewer/domain/services/file_operations_service.dart';
import 'package:oiv/viewer/domain/services/image_picker_service.dart';
import 'package:oiv/viewer/domain/services/image_transform_service.dart';
import 'package:oiv/viewer/presentation/controllers/viewer_controller.dart';
import 'package:oiv/viewer/presentation/models/viewer_notice.dart';
import 'package:path/path.dart' as p;
import 'package:oiv/editor/data/services/rendering_quick_fix_service.dart';
import 'package:oiv/editor/domain/entities/edit_operation.dart';
import 'package:oiv/editor/domain/entities/export_options.dart';
import 'package:oiv/editor/domain/entities/image_edits.dart';
import 'package:oiv/editor/domain/services/quick_fix_service.dart';
import 'package:oiv/library/domain/entities/photo_info.dart';

import 'support/editor_fakes.dart';

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
          fileOperationsService: _FakeFileOperations(),
          imageTransformService: _FakeImageTransforms(),
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
          fileOperationsService: _FakeFileOperations(),
          imageTransformService: _FakeImageTransforms(),
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

  group('ViewerController selection', () {
    const abcd = <String>[
      '/images/a.png',
      '/images/b.png',
      '/images/c.png',
      '/images/d.png',
    ];

    test('first toggle selects the current image too', () async {
      final fixture = await _openFolder(abcd, open: '/images/a.png');

      fixture.controller.toggleSelection(2);

      expect(fixture.controller.state.selectedPaths, <String>{
        '/images/a.png',
        '/images/c.png',
      });

      fixture.controller.toggleSelection(2);
      expect(fixture.controller.state.selectedPaths, <String>{'/images/a.png'});
    });

    test('range selects from the current image, in gallery order', () async {
      final fixture = await _openFolder(abcd, open: '/images/d.png');

      fixture.controller.selectRange(1);

      expect(fixture.controller.state.actionTargets, <String>[
        '/images/b.png',
        '/images/c.png',
        '/images/d.png',
      ]);
    });

    test('actions target the current image without a selection', () async {
      final fixture = await _openFolder(abcd, open: '/images/b.png');

      expect(fixture.controller.state.actionTargets, <String>['/images/b.png']);

      fixture.controller.selectAll();
      expect(fixture.controller.state.actionTargets, abcd);

      fixture.controller.clearSelection();
      expect(fixture.controller.state.hasSelection, isFalse);
    });
  });

  group('ViewerController file actions', () {
    const abcd = <String>[
      '/images/a.png',
      '/images/b.png',
      '/images/c.png',
      '/images/d.png',
    ];

    test('trash removes the image and shows the next one', () async {
      final fixture = await _openFolder(abcd, open: '/images/b.png');

      await fixture.controller.trashTargets();

      expect(fixture.fileOperations.trashed, <String>['/images/b.png']);
      expect(fixture.paths, <String>[
        '/images/a.png',
        '/images/c.png',
        '/images/d.png',
      ]);
      expect(fixture.controller.state.currentImage.path, '/images/c.png');
      expect(
        fixture.controller.state.notice?.type,
        ViewerNoticeType.movedToTrash,
      );
      expect(fixture.controller.state.notice?.count, 1);
    });

    test(
      'trashing a selection keeps the viewer on a surviving image',
      () async {
        final fixture = await _openFolder(abcd, open: '/images/c.png');
        fixture.controller
          ..toggleSelection(0)
          ..toggleSelection(1);

        await fixture.controller.trashTargets();

        expect(fixture.paths, <String>['/images/d.png']);
        expect(fixture.controller.state.currentImage.path, '/images/d.png');
        expect(fixture.controller.state.hasSelection, isFalse);
        expect(fixture.controller.state.notice?.count, 3);
      },
    );

    test('reports images that could not be trashed and keeps them', () async {
      final fixture = await _openFolder(abcd, open: '/images/a.png');
      fixture.fileOperations.failingPaths.add('/images/b.png');
      fixture.controller.selectAll();

      await fixture.controller.trashTargets();

      expect(fixture.paths, <String>['/images/b.png']);
      expect(
        fixture.controller.state.notice?.type,
        ViewerNoticeType.trashFailed,
      );
      expect(fixture.controller.state.notice?.count, 1);
    });

    test('trashing the last image returns to the empty state', () async {
      final fixture = await _openFolder(<String>[
        '/images/a.png',
      ], open: '/images/a.png');

      await fixture.controller.trashTargets();

      expect(fixture.controller.state.hasImages, isFalse);
    });

    test('rename swaps the path in place', () async {
      final fixture = await _openFolder(abcd, open: '/images/b.png');

      final error = await fixture.controller.renameCurrent('beach.png');

      expect(error, isNull);
      expect(fixture.paths[1], '/images/beach.png');
      expect(fixture.controller.state.currentIndex, 1);
    });

    test('rename passes the failure reason back', () async {
      final fixture = await _openFolder(abcd, open: '/images/b.png');
      fixture.fileOperations.renameError = FileOperationError.alreadyExists;

      final error = await fixture.controller.renameCurrent('a.png');

      expect(error, FileOperationError.alreadyExists);
      expect(fixture.paths, abcd);
    });

    test('move to folder removes moved images from the gallery', () async {
      final fixture = await _openFolder(abcd, open: '/images/a.png');
      fixture.picker.directoryToPick = '/elsewhere';
      fixture.controller.selectRange(1);

      await fixture.controller.moveTargetsToFolder(pickerTexts: _texts);

      expect(fixture.paths, <String>['/images/c.png', '/images/d.png']);
      expect(fixture.controller.state.notice?.type, ViewerNoticeType.moved);
      expect(fixture.controller.state.notice?.count, 2);
    });

    test('copy to folder keeps the gallery and reports the count', () async {
      final fixture = await _openFolder(abcd, open: '/images/a.png');
      fixture.picker.directoryToPick = '/elsewhere';
      fixture.controller.selectAll();

      await fixture.controller.copyTargetsToFolder(pickerTexts: _texts);

      expect(fixture.fileOperations.lastCopy, abcd);
      expect(fixture.paths, abcd);
      expect(fixture.controller.state.notice?.type, ViewerNoticeType.copied);
      expect(fixture.controller.state.notice?.count, 4);
    });

    test('cancelling the folder picker does nothing', () async {
      final fixture = await _openFolder(abcd, open: '/images/a.png');

      await fixture.controller.moveTargetsToFolder(pickerTexts: _texts);

      expect(fixture.paths, abcd);
      expect(fixture.controller.state.notice, isNull);
    });

    test('share passes every target and reports failures', () async {
      final fixture = await _openFolder(abcd, open: '/images/a.png');
      fixture.controller.selectRange(1);

      await fixture.controller.shareTargets(const ShareAnchor(0, 0, 10, 10));
      expect(fixture.fileOperations.shared.single, [
        '/images/a.png',
        '/images/b.png',
      ]);
      expect(fixture.controller.state.notice, isNull);

      fixture.fileOperations.failingPaths.add('/images/b.png');
      await fixture.controller.shareTargets(const ShareAnchor(0, 0, 10, 10));
      expect(
        fixture.controller.state.notice?.type,
        ViewerNoticeType.shareFailed,
      );
    });

    test('clipboard and reveal failures surface as notices', () async {
      final fixture = await _openFolder(abcd, open: '/images/a.png');

      await fixture.controller.copyCurrentImageToClipboard();
      expect(
        fixture.controller.state.notice?.type,
        ViewerNoticeType.imageCopiedToClipboard,
      );

      fixture.fileOperations.failingPaths.add('/images/a.png');
      await fixture.controller.revealCurrent();
      expect(
        fixture.controller.state.notice?.type,
        ViewerNoticeType.revealFailed,
      );
    });
  });

  group('ViewerController rotation saving', () {
    const ab = <String>['/images/a.png', '/images/b.webp'];

    test('saves, evicts the cache, then bumps the revision', () async {
      final fixture = await _openFolder(ab, open: '/images/a.png');

      final result = await fixture.controller.saveCurrentRotation(1);

      expect(result, RotationSaveResult.saved);
      expect(fixture.transforms.calls, [('/images/a.png', 1)]);
      expect(fixture.evicted, ['/images/a.png']);
      expect(fixture.controller.state.currentImage.revision, 1);
      expect(fixture.controller.state.images[1].revision, 0);
      expect(
        fixture.controller.state.notice?.type,
        ViewerNoticeType.rotationSaved,
      );
    });

    test('no rotation means nothing to save', () async {
      final fixture = await _openFolder(ab, open: '/images/a.png');

      await fixture.controller.saveCurrentRotation(4);

      expect(fixture.transforms.calls, isEmpty);
      expect(fixture.controller.state.notice, isNull);
    });

    test('names the format when it is unsupported', () async {
      final fixture = await _openFolder(ab, open: '/images/b.webp');
      fixture.transforms.result = RotationSaveResult.unsupportedFormat;

      await fixture.controller.saveCurrentRotation(2);

      expect(
        fixture.controller.state.notice?.type,
        ViewerNoticeType.rotationUnsupported,
      );
      expect(fixture.controller.state.notice?.detail, 'WEBP');
      expect(fixture.evicted, isEmpty);
      expect(fixture.controller.state.currentImage.revision, 0);
    });

    test('reports failures without touching the gallery', () async {
      final fixture = await _openFolder(ab, open: '/images/a.png');
      fixture.transforms.result = RotationSaveResult.failed;

      await fixture.controller.saveCurrentRotation(1);

      expect(
        fixture.controller.state.notice?.type,
        ViewerNoticeType.rotationSaveFailed,
      );
      expect(fixture.controller.state.currentImage.revision, 0);
    });
  });

  group('ViewerController edits', () {
    const abc = <String>['/images/a.png', '/images/b.png', '/images/c.png'];
    const sepia = ImageEdits([EffectEdit(EffectKind.sepia, 1)]);

    test('loads the folder\'s edits when it opens', () async {
      final fixture = await _openFolder(
        abc,
        open: '/images/a.png',
        savedEdits: {'/images/b.png': sepia, '/other/x.png': sepia},
      );
      await pumpEventQueue();

      expect(fixture.controller.state.edits, {'/images/b.png': sepia});
      expect(
        fixture.controller.state.editsFor('/images/a.png'),
        ImageEdits.none,
      );
    });

    test('setEdits records and clears edits', () async {
      final fixture = await _openFolder(abc, open: '/images/a.png');

      fixture.controller.setEdits('/images/a.png', sepia);
      expect(fixture.controller.state.editsFor('/images/a.png'), sepia);

      fixture.controller.setEdits('/images/a.png', ImageEdits.none);
      expect(fixture.controller.state.edits, isEmpty);
    });

    test('rename and move carry edits along; copy duplicates them', () async {
      final fixture = await _openFolder(
        abc,
        open: '/images/a.png',
        savedEdits: {'/images/a.png': sepia, '/images/b.png': sepia},
      );
      await pumpEventQueue();

      await fixture.controller.renameCurrent('beach.png');
      expect(fixture.edits.stored.keys, contains('/images/beach.png'));
      expect(fixture.edits.stored.keys, isNot(contains('/images/a.png')));
      expect(fixture.controller.state.editsFor('/images/beach.png'), sepia);

      fixture.picker.directoryToPick = '/elsewhere';
      await fixture.controller.openIndex(1);
      await fixture.controller.copyTargetsToFolder(pickerTexts: _texts);
      expect(fixture.edits.stored['/elsewhere/b.png'], sepia);
      expect(fixture.edits.stored['/images/b.png'], sepia);

      await fixture.controller.moveTargetsToFolder(pickerTexts: _texts);
      expect(fixture.edits.stored.containsKey('/images/b.png'), isFalse);
      expect(
        fixture.controller.state.edits.containsKey('/images/b.png'),
        isFalse,
      );
    });

    test('rotating an edited image adds the rotation to its edits', () async {
      final fixture = await _openFolder(
        abc,
        open: '/images/a.png',
        savedEdits: {'/images/a.png': sepia},
      );
      await pumpEventQueue();

      final result = await fixture.controller.saveCurrentRotation(3);

      expect(result, RotationSaveResult.saved);
      expect(fixture.transforms.calls, isEmpty);
      expect(
        fixture.edits.stored['/images/a.png']?.operations.last,
        const RotateEdit(3),
      );
      expect(
        fixture.controller.state.notice?.type,
        ViewerNoticeType.rotationAddedToEdits,
      );
    });

    test('quick fixes apply to every target and are saved', () async {
      final fixture = await _openFolder(abc, open: '/images/a.png');
      fixture.controller.selectAll();

      await fixture.controller.quickFixTargets(QuickFix.feelingLucky);

      expect(fixture.edits.stored, hasLength(3));
      expect(
        fixture.edits.stored['/images/c.png']?.operations.single,
        isA<LevelsEdit>().having(
          (e) => e.kind,
          'kind',
          AutoFixKind.feelingLucky,
        ),
      );
      expect(fixture.controller.state.edits, hasLength(3));
      expect(fixture.controller.state.isWorking, isFalse);
      expect(fixture.controller.state.notice?.count, 3);

      await fixture.controller.removeEditsFromTargets();
      expect(fixture.edits.stored, isEmpty);
      expect(
        fixture.controller.state.notice?.type,
        ViewerNoticeType.editsRemoved,
      );
    });

    test('quick fix failures are counted', () async {
      final fixture = await _openFolder(abc, open: '/images/a.png');
      fixture.edits.failSaves = true;

      await fixture.controller.quickFixTargets(QuickFix.sepia);

      expect(
        fixture.controller.state.notice?.type,
        ViewerNoticeType.quickFixFailed,
      );
      expect(fixture.controller.state.edits, isEmpty);
    });

    test('export writes each target with its own edits', () async {
      final fixture = await _openFolder(
        abc,
        open: '/images/a.png',
        savedEdits: {'/images/b.png': sepia},
      );
      await pumpEventQueue();
      fixture.picker.directoryToPick = '/out';
      fixture.controller.selectAll();
      fixture.exporter.failing = {'/images/c.png'};

      await fixture.controller.exportTargets(
        options: const ExportOptions(),
        pickerTexts: _texts,
      );

      expect(fixture.exporter.calls.map((c) => c.$1), abc);
      expect(fixture.exporter.calls[1].$2, sepia);
      expect(fixture.exporter.calls[0].$2, ImageEdits.none);
      expect(
        fixture.controller.state.notice?.type,
        ViewerNoticeType.exportFailed,
      );
      expect(fixture.controller.state.notice?.count, 1);
    });
  });

  group('ViewerController stars, captions and tags', () {
    const abc = <String>['/images/a.png', '/images/b.png', '/images/c.png'];

    test(
      'star toggles, and unstars only when every target is starred',
      () async {
        final fixture = await _openFolder(
          abc,
          open: '/images/a.png',
          savedInfo: {'/images/a.png': const PhotoInfo(starred: true)},
        );
        await pumpEventQueue();
        expect(
          fixture.controller.state.photoInfoFor('/images/a.png').starred,
          isTrue,
        );

        fixture.controller.selectAll();
        await fixture.controller.toggleStarTargets();
        expect(
          fixture.info.stored.values.where((i) => i.starred),
          hasLength(3),
        );

        await fixture.controller.toggleStarTargets();
        expect(fixture.info.stored, isEmpty);
        expect(fixture.controller.state.photoInfo, isEmpty);
      },
    );

    test('caption, tags and hidden keep each other', () async {
      final fixture = await _openFolder(abc, open: '/images/b.png');

      await fixture.controller.setCaptionAndTags('/images/b.png', ' Sunset ', [
        'beach',
      ]);
      await fixture.controller.setTargetsHidden(true);

      expect(
        fixture.info.stored['/images/b.png'],
        const PhotoInfo(caption: 'Sunset', tags: ['beach'], hidden: true),
      );
    });

    test('info follows a rename', () async {
      final fixture = await _openFolder(
        abc,
        open: '/images/a.png',
        savedInfo: {'/images/a.png': const PhotoInfo(starred: true)},
      );
      await pumpEventQueue();

      await fixture.controller.renameCurrent('z.png');

      expect(fixture.info.stored.keys, ['/images/z.png']);
      expect(
        fixture.controller.state.photoInfoFor('/images/z.png').starred,
        isTrue,
      );
    });

    test('a failed save is reported and nothing changes', () async {
      final fixture = await _openFolder(abc, open: '/images/a.png');
      fixture.info.failSaves = true;

      await fixture.controller.toggleStarTargets();

      expect(fixture.controller.state.photoInfo, isEmpty);
      expect(
        fixture.controller.state.notice?.type,
        ViewerNoticeType.photoInfoSaveFailed,
      );
    });
  });
}

const DirectoryAccessTexts _texts = DirectoryAccessTexts(
  prompt: 'Move here',
  message: 'Choose a folder',
);

class _FolderFixture {
  _FolderFixture(
    this.controller,
    this.repository,
    this.fileOperations,
    this.picker,
    this.transforms,
    this.evicted,
    this.edits,
    this.exporter,
    this.info,
  );

  final ViewerController controller;
  final _FakeImageRepository repository;
  final _FakeFileOperations fileOperations;
  final _FakeImagePickerService picker;
  final _FakeImageTransforms transforms;
  final List<String> evicted;
  final InMemoryImageEditRepository edits;
  final FakeExportService exporter;
  final InMemoryPhotoInfoRepository info;

  List<String> get paths =>
      controller.state.images.map((image) => image.path).toList();

  /// Emits a folder change and waits for the debounced refresh to land,
  /// plus a short grace period to catch any extra (unwanted) refresh.
  Future<void> emitFolderChange() async {
    final refreshed = Completer<void>();
    void onChange() {
      if (!refreshed.isCompleted) {
        refreshed.complete();
      }
    }

    controller.addListener(onChange);
    repository.watchEvents.add(null);
    await refreshed.future.timeout(
      const Duration(seconds: 2),
      onTimeout: () {},
    );
    controller.removeListener(onChange);
    await Future<void>.delayed(const Duration(milliseconds: 30));
  }
}

Future<_FolderFixture> _openFolder(
  List<String> paths, {
  required String open,
  ImageSortOrder? sortOrder,
  Map<String, ImageEdits> savedEdits = const {},
  Map<String, PhotoInfo> savedInfo = const {},
}) async {
  final info = InMemoryPhotoInfoRepository()..stored.addAll(savedInfo);
  final edits = InMemoryImageEditRepository()..stored.addAll(savedEdits);
  final exporter = FakeExportService();
  final picker = _FakeImagePickerService();
  final fileOperations = _FakeFileOperations();
  final transforms = _FakeImageTransforms();
  final evicted = <String>[];
  final repository = _FakeImageRepository(
    supportedImages: paths.toSet(),
    directoryImages: <String, List<GalleryImage>>{},
  )..setDirectoryImages('/images', paths);
  final controller = ViewerController(
    imageRepository: repository,
    imagePickerService: picker,
    nativeFileChannelService: _FakeNativeFileChannelService(),
    fileOperationsService: fileOperations,
    imageTransformService: transforms,
    editRepository: edits,
    photoInfoRepository: info,
    quickFixService: RenderingQuickFixService(
      pixelSource: FakePixelSource(),
      renderService: SyncRenderService(),
    ),
    exportService: exporter,
    evictImage: (path) async => evicted.add(path),
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
  return _FolderFixture(
    controller,
    repository,
    fileOperations,
    picker,
    transforms,
    evicted,
    edits,
    exporter,
    info,
  );
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
  String? directoryToPick;

  @override
  Future<String?> pickDirectory({
    required String initialDirectory,
    required DirectoryAccessTexts texts,
  }) async {
    return directoryToPick;
  }

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

class _FakeFileOperations implements FileOperationsService {
  final List<List<String>> shared = <List<String>>[];

  @override
  bool get canShare => true;

  @override
  Future<bool> share(List<String> paths, ShareAnchor anchor) async {
    shared.add(paths);
    return !paths.any(failingPaths.contains);
  }

  final Set<String> failingPaths = <String>{};
  final List<String> trashed = <String>[];
  FileOperationError? renameError;
  List<String>? lastCopy;

  @override
  Future<bool> moveToTrash(String path) async {
    if (failingPaths.contains(path)) {
      return false;
    }
    trashed.add(path);
    return true;
  }

  @override
  Future<String> rename(String path, String newFileName) async {
    if (renameError != null) {
      throw FileOperationException(renameError!);
    }
    return '/images/$newFileName';
  }

  @override
  Future<Map<String, String>> copyTo(
    List<String> paths,
    String destination,
  ) async {
    lastCopy = paths;
    return {
      for (final path in paths)
        if (!failingPaths.contains(path))
          path: p.join(destination, p.basename(path)),
    };
  }

  @override
  Future<Map<String, String>> moveTo(
    List<String> paths,
    String destination,
  ) async {
    return {
      for (final path in paths)
        if (!failingPaths.contains(path))
          path: p.join(destination, p.basename(path)),
    };
  }

  @override
  Future<bool> reveal(String path) async => !failingPaths.contains(path);

  @override
  Future<bool> copyImageToClipboard(String path) async =>
      !failingPaths.contains(path);

  @override
  Future<bool> openWith(String path, {required String prompt}) async =>
      !failingPaths.contains(path);
}

class _FakeImageTransforms implements ImageTransformService {
  RotationSaveResult result = RotationSaveResult.saved;
  final List<(String, int)> calls = <(String, int)>[];

  @override
  bool canSaveRotation(String path) => true;

  @override
  Future<RotationSaveResult> saveRotation(String path, int turns) async {
    calls.add((path, turns));
    return result;
  }
}
