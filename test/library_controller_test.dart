import 'package:flutter_test/flutter_test.dart';
import 'package:oiv/library/domain/entities/library_query.dart';
import 'package:oiv/library/domain/entities/photo_info.dart';
import 'package:oiv/library/presentation/controllers/library_controller.dart';
import 'package:oiv/library/presentation/models/folder_tree.dart';
import 'package:oiv/library/presentation/models/library_state.dart';
import 'package:oiv/library/domain/entities/catalog_image.dart';

import 'support/editor_fakes.dart';
import 'support/library_fakes.dart';

void main() {
  late LibraryFixture fixture;
  late InMemoryPhotoInfoRepository info;

  final photos = [
    catalogPhoto('/pics/goa/beach.jpg', taken: DateTime(2019, 7, 14)),
    catalogPhoto('/pics/goa/fort.jpg', taken: DateTime(2019, 7, 20)),
    catalogPhoto('/pics/home/cat.jpg', taken: DateTime(2021, 3, 1)),
    catalogPhoto('/other/x.jpg'),
  ];

  Future<LibraryController> open({List<String> roots = const ['/pics']}) async {
    fixture = LibraryFixture(photos, roots: roots);
    info = InMemoryPhotoInfoRepository();
    final controller = LibraryController(
      catalog: fixture.catalog,
      indexer: fixture.indexer,
      settings: fixture.settings,
      photoInfo: info,
      fileOperations: fixture.files,
      duplicateFinder: fixture.duplicates,
    );
    addTearDown(controller.dispose);
    await controller.open();
    await pumpEventQueue();
    return controller;
  }

  List<String> names(LibraryController controller) => [
    for (final image in controller.state.images) image.name,
  ];

  test('opens with nothing to show until a folder is added', () async {
    final controller = await open(roots: const []);

    expect(controller.state.hasRoots, isFalse);
    expect(controller.state.images, isEmpty);
    expect(fixture.indexer.runs, 0);

    await controller.addRoot('/pics/');
    await pumpEventQueue();

    expect(fixture.settings.roots, ['/pics']);
    expect(names(controller), ['cat.jpg', 'fort.jpg', 'beach.jpg']);
  });

  test('folders, starred and search narrow the grid', () async {
    final controller = await open();

    await controller.showFolder('/pics/goa');
    expect(names(controller), ['beach.jpg', 'fort.jpg']);
    expect(controller.state.groupsByMonth, isFalse);

    controller.select('/pics/goa/beach.jpg');
    await controller.toggleStarSelection();
    expect(info.stored['/pics/goa/beach.jpg']?.starred, isTrue);

    await controller.showStarred();
    expect(names(controller), ['beach.jpg']);
    expect(controller.state.selection, isEmpty);

    await controller.showAllPhotos();
    await controller.setSearchText('2021');
    expect(names(controller), ['cat.jpg']);
  });

  test('selection: click, toggle, range and select all', () async {
    final controller = await open();
    final paths = [for (final image in controller.state.images) image.path];

    controller.select(paths[0]);
    controller.selectRange(paths[2]);
    expect(controller.state.selection, paths.toSet());

    controller.toggleSelection(paths[1]);
    expect(controller.state.selectedInOrder, [paths[0], paths[2]]);

    controller.clearSelection();
    controller.selectAll();
    expect(controller.state.selection, hasLength(3));
  });

  test('hiding photos and folders, and showing hidden ones again', () async {
    final controller = await open();

    controller.select('/pics/home/cat.jpg');
    await controller.setSelectionHidden(true);
    expect(names(controller), ['fort.jpg', 'beach.jpg']);
    expect(info.stored['/pics/home/cat.jpg'], const PhotoInfo(hidden: true));

    await controller.setFolderHidden('/pics/goa', true);
    expect(controller.state.images, isEmpty);
    expect(fixture.settings.hidden, {'/pics/goa'});

    await controller.setShowHidden(true);
    expect(names(controller), hasLength(3));
  });

  test('albums: create with the selection, add, remove, delete', () async {
    final controller = await open();
    controller.select('/pics/goa/fort.jpg');

    final album = await controller.createAlbum('  Goa trip ');
    expect(album.name, 'Goa trip');
    expect(controller.state.albums.single.imageCount, 1);

    controller.select('/pics/home/cat.jpg');
    await controller.addSelectionToAlbum(album.id);
    await controller.showAlbum(album.id);
    expect(names(controller), ['fort.jpg', 'cat.jpg']);
    expect(controller.state.notice?.type, LibraryNoticeType.addedToAlbum);

    controller.select('/pics/goa/fort.jpg');
    await controller.removeSelectionFromAlbum();
    expect(names(controller), ['cat.jpg']);

    await controller.deleteAlbum(album.id);
    expect(controller.state.albums, isEmpty);
    expect(controller.state.source, LibrarySource.allPhotos);
    expect(names(controller), hasLength(3));
  });

  test('removing a root drops its photos and leaves its folder', () async {
    final controller = await open(roots: const ['/pics', '/other']);
    await controller.showFolder('/pics/goa');

    await controller.removeRoot('/pics');
    await pumpEventQueue();

    expect(controller.state.source, LibrarySource.allPhotos);
    expect(names(controller), ['x.jpg']);
  });

  test('moving duplicates to the trash drops them from the catalog', () async {
    final controller = await open();
    fixture.files.failing = {'/pics/goa/fort.jpg'};

    final trashed = await controller.moveToTrash([
      '/pics/goa/beach.jpg',
      '/pics/goa/fort.jpg',
    ]);

    expect(trashed, ['/pics/goa/beach.jpg']);
    expect(names(controller), ['cat.jpg', 'fort.jpg']);
    expect(controller.state.notice?.type, LibraryNoticeType.trashFailed);
    expect(await fixture.catalog.search(const LibraryQuery()), hasLength(2));
  });

  test('folder tree nests sub-folders under their root', () {
    final tree = buildFolderTree(
      ['/pics'],
      const [
        CatalogFolder(path: '/pics/2019/goa', imageCount: 2),
        CatalogFolder(path: '/pics/home', imageCount: 1),
        CatalogFolder(path: '/pics', imageCount: 4),
      ],
      {'/pics/home'},
    );

    expect(
      [
        for (final node in tree)
          (node.name, node.depth, node.imageCount, node.isHidden),
      ],
      [
        ('/pics', 0, 4, false),
        ('2019', 1, 0, false),
        ('goa', 2, 2, false),
        ('home', 1, 1, true),
      ],
    );
  });
}
