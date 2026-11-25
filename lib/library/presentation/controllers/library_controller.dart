import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:path/path.dart' as p;

import '../../../viewer/domain/services/file_operations_service.dart';
import '../../domain/entities/catalog_image.dart';
import '../../domain/entities/geo_point.dart';
import '../../domain/entities/library_query.dart';
import '../../domain/entities/photo_info.dart';
import '../../domain/repositories/catalog_repository.dart';
import '../../domain/repositories/library_settings_repository.dart';
import '../../domain/repositories/photo_info_repository.dart';
import '../../domain/services/duplicate_finder.dart';
import '../../domain/services/library_indexer.dart';
import '../models/library_state.dart';

/// Drives the library: watched folders, what the grid shows, selection,
/// stars/hiding, albums and duplicates. Stars and the hidden flag are
/// written to the photos' sidecars first, then mirrored into the catalog.
class LibraryController extends ChangeNotifier {
  LibraryController({
    required CatalogRepository catalog,
    required LibraryIndexer indexer,
    required LibrarySettingsRepository settings,
    required PhotoInfoRepository photoInfo,
    required FileOperationsService fileOperations,
    required DuplicateFinder duplicateFinder,
  }) : _catalog = catalog,
       _indexer = indexer,
       _settings = settings,
       _photoInfo = photoInfo,
       _fileOperations = fileOperations,
       _duplicateFinder = duplicateFinder;

  final CatalogRepository _catalog;
  final LibraryIndexer _indexer;
  final LibrarySettingsRepository _settings;
  final PhotoInfoRepository _photoInfo;
  final FileOperationsService _fileOperations;
  final DuplicateFinder _duplicateFinder;

  LibraryState _state = const LibraryState();
  StreamSubscription<IndexProgress>? _indexing;
  int _queryGeneration = 0;
  int _noticeCounter = 0;
  bool _isDisposed = false;

  LibraryState get state => _state;

  /// Loads settings and what is already catalogued, then rescans.
  Future<void> open() async {
    final roots = await _settings.watchedFolders();
    final hidden = await _settings.hiddenFolders();
    _setState(_state.copyWith(roots: roots, hiddenFolders: hidden));
    await refresh();
    _setState(_state.copyWith(isLoading: false));
    reindex();
  }

  // -------------------------------------------------------------------------
  // Watched folders

  Future<void> addRoot(String folder) async {
    final roots = {..._state.roots, p.normalize(folder)}.toList()..sort();
    await _settings.setWatchedFolders(roots);
    _setState(_state.copyWith(roots: roots));
    reindex();
  }

  /// Stops watching [folder]. Its photos leave the library; files and
  /// sidecars are untouched.
  Future<void> removeRoot(String folder) async {
    final roots = [..._state.roots]..remove(folder);
    await _settings.setWatchedFolders(roots);
    final leavingCurrent =
        _state.folder != null &&
        (p.equals(_state.folder!, folder) ||
            p.isWithin(folder, _state.folder!));
    _setState(
      _state.copyWith(
        roots: roots,
        source: leavingCurrent ? LibrarySource.allPhotos : null,
        folder: leavingCurrent ? () => null : null,
      ),
    );
    await _catalog.removeOutside(roots);
    await refresh();
    reindex();
  }

  /// Rescans the watched folders in the background.
  void reindex() {
    unawaited(_indexing?.cancel());
    if (_state.roots.isEmpty) {
      _setState(_state.copyWith(progress: () => null));
      return;
    }
    var lastRefresh = DateTime.now();
    _indexing = _indexer
        .index(_state.roots)
        .listen(
          (progress) {
            _setState(_state.copyWith(progress: () => progress));
            final now = DateTime.now();
            // Show photos as they are found, without re-querying constantly.
            if (progress.done ||
                now.difference(lastRefresh) > const Duration(seconds: 1)) {
              lastRefresh = now;
              unawaited(refresh());
            }
          },
          onError: (Object error) {
            debugPrint('Library scan failed: $error');
            _setState(_state.copyWith(progress: () => null));
          },
          onDone: () => _setState(_state.copyWith(progress: () => null)),
        );
  }

  Future<void> setFolderHidden(String folder, bool hidden) async {
    final next = {..._state.hiddenFolders};
    hidden ? next.add(folder) : next.remove(folder);
    await _settings.setHiddenFolders(next);
    _setState(_state.copyWith(hiddenFolders: next));
    await refresh();
  }

  // -------------------------------------------------------------------------
  // What to show

  Future<void> showAllPhotos() => _show(LibrarySource.allPhotos);

  Future<void> showStarred() => _show(LibrarySource.starred);

  /// Photos with a location, for the map.
  Future<void> showPlaces() => _show(LibrarySource.places);

  /// The People view (it has its own controller).
  Future<void> showPeople() => _show(LibrarySource.people);

  Future<void> showFolder(String folder) =>
      _show(LibrarySource.folder, folder: folder);

  Future<void> showAlbum(int id) => _show(LibrarySource.album, albumId: id);

  Future<void> setSearchText(String text) async {
    if (text == _state.searchText) {
      return;
    }
    _setState(_state.copyWith(searchText: text));
    await refresh();
  }

  Future<void> setShowHidden(bool show) async {
    _setState(_state.copyWith(showHidden: show));
    await refresh();
  }

  Future<void> _show(
    LibrarySource source, {
    String? folder,
    int? albumId,
  }) async {
    _setState(
      _state.copyWith(
        source: source,
        folder: () => folder,
        albumId: () => albumId,
        selection: const <String>{},
        anchorPath: () => null,
      ),
    );
    await refresh();
  }

  LibraryQuery get _query => LibraryQuery(
    text: _state.searchText,
    folder: _state.source == LibrarySource.folder ? _state.folder : null,
    albumId: _state.source == LibrarySource.album ? _state.albumId : null,
    starredOnly: _state.source == LibrarySource.starred,
    onlyWithLocation: _state.source == LibrarySource.places,
    includeHidden: _state.showHidden,
    hiddenFolders: _state.hiddenFolders,
  );

  /// Re-reads folders, albums and the grid from the catalog.
  Future<void> refresh() async {
    final generation = ++_queryGeneration;
    final query = _query;
    final folders = await _catalog.folders(
      LibraryQuery(includeHidden: true, hiddenFolders: _state.hiddenFolders),
    );
    final albums = await _catalog.albums();
    final images = await _catalog.search(query);
    if (_isDisposed || generation != _queryGeneration) {
      return;
    }
    final present = {for (final image in images) image.path};
    final albumGone =
        _state.source == LibrarySource.album &&
        !albums.any((album) => album.id == _state.albumId);
    _setState(
      _state.copyWith(
        folders: folders,
        albums: albums,
        images: images,
        selection: _state.selection.intersection(present),
        source: albumGone ? LibrarySource.allPhotos : null,
        albumId: albumGone ? () => null : null,
      ),
    );
    if (albumGone) {
      await refresh();
    }
  }

  // -------------------------------------------------------------------------
  // Selection

  /// A plain click: select just [path].
  void select(String path) {
    _setState(_state.copyWith(selection: {path}, anchorPath: () => path));
  }

  /// Cmd/Ctrl-click.
  void toggleSelection(String path) {
    final next = {..._state.selection};
    next.contains(path) ? next.remove(path) : next.add(path);
    _setState(_state.copyWith(selection: next, anchorPath: () => path));
  }

  /// Shift-click: everything between the last clicked photo and [path].
  void selectRange(String path) {
    final paths = [for (final image in _state.images) image.path];
    final anchor = paths.indexOf(_state.anchorPath ?? path);
    final target = paths.indexOf(path);
    if (target < 0) {
      return;
    }
    final from = anchor < 0 ? target : anchor;
    final range = paths.sublist(
      from < target ? from : target,
      (from < target ? target : from) + 1,
    );
    _setState(_state.copyWith(selection: {..._state.selection, ...range}));
  }

  void selectAll() {
    _setState(
      _state.copyWith(
        selection: {for (final image in _state.images) image.path},
      ),
    );
  }

  void clearSelection() {
    _setState(_state.copyWith(selection: const <String>{}));
  }

  // -------------------------------------------------------------------------
  // Stars and hiding

  /// Stars the selection; if it is all starred already, unstars it.
  Future<void> toggleStarSelection() async {
    final selected = _selectedImages;
    if (selected.isEmpty) {
      return;
    }
    final star = !selected.every((image) => image.info.starred);
    await _updateInfo(selected, (info) => info.copyWith(starred: star));
  }

  /// Sets where the selected photos were taken; null removes a location
  /// set by hand (the camera's GPS, if any, shows again).
  Future<void> setSelectionLocation(GeoPoint? location) async {
    await _updateInfo(
      _selectedImages,
      (info) => info.copyWith(location: () => location),
    );
  }

  Future<void> setSelectionHidden(bool hidden) async {
    await _updateInfo(_selectedImages, (info) => info.copyWith(hidden: hidden));
  }

  List<CatalogImage> get _selectedImages => [
    for (final image in _state.images)
      if (_state.selection.contains(image.path)) image,
  ];

  Future<void> _updateInfo(
    List<CatalogImage> images,
    PhotoInfo Function(PhotoInfo info) change,
  ) async {
    var failed = false;
    for (final image in images) {
      final info = change(image.info);
      if (await _photoInfo.save(image.path, info)) {
        await _catalog.updateInfo(image.path, info);
      } else {
        failed = true;
      }
    }
    if (failed) {
      _notify(LibraryNoticeType.saveFailed);
    }
    await refresh();
  }

  // -------------------------------------------------------------------------
  // Albums

  /// Creates an album, adding the selection to it if there is one.
  Future<Album> createAlbum(String name) async {
    final album = await _catalog.createAlbum(name.trim());
    final selected = _state.selectedInOrder;
    if (selected.isNotEmpty) {
      await _catalog.addToAlbum(album.id, selected);
    }
    _notify(LibraryNoticeType.albumCreated, detail: album.name);
    await refresh();
    return album;
  }

  Future<void> addSelectionToAlbum(int albumId) async {
    final selected = _state.selectedInOrder;
    if (selected.isEmpty) {
      return;
    }
    await _catalog.addToAlbum(albumId, selected);
    _notify(LibraryNoticeType.addedToAlbum, count: selected.length);
    await refresh();
  }

  Future<void> removeSelectionFromAlbum() async {
    final albumId = _state.albumId;
    final selected = _state.selectedInOrder;
    if (_state.source != LibrarySource.album ||
        albumId == null ||
        selected.isEmpty) {
      return;
    }
    await _catalog.removeFromAlbum(albumId, selected);
    _notify(LibraryNoticeType.removedFromAlbum, count: selected.length);
    await refresh();
  }

  Future<void> renameAlbum(int id, String name) async {
    await _catalog.renameAlbum(id, name.trim());
    await refresh();
  }

  /// Deletes the album; its photos are not touched.
  Future<void> deleteAlbum(int id) async {
    await _catalog.deleteAlbum(id);
    await refresh();
  }

  bool get canShare => _fileOperations.canShare;

  /// Opens the system share menu for the selection.
  Future<bool> shareSelection(ShareAnchor anchor) async {
    final selected = _state.selectedInOrder;
    if (selected.isEmpty || !canShare) {
      return false;
    }
    return _fileOperations.share(selected, anchor);
  }

  // -------------------------------------------------------------------------
  // Duplicates

  Future<List<List<CatalogImage>>> findDuplicates({
    void Function(int checked, int total)? onProgress,
  }) {
    return _duplicateFinder.find(onProgress: onProgress);
  }

  /// Moves [paths] to the system Trash (never deletes) and drops them from
  /// the catalog. Returns the paths that were moved.
  Future<List<String>> moveToTrash(List<String> paths) async {
    final trashed = <String>[];
    for (final path in paths) {
      if (await _fileOperations.moveToTrash(path)) {
        trashed.add(path);
      }
    }
    await _catalog.remove(trashed);
    if (trashed.length < paths.length) {
      _notify(
        LibraryNoticeType.trashFailed,
        count: paths.length - trashed.length,
      );
    } else if (trashed.isNotEmpty) {
      _notify(LibraryNoticeType.movedToTrash, count: trashed.length);
    }
    await refresh();
    return trashed;
  }

  // -------------------------------------------------------------------------

  void _notify(LibraryNoticeType type, {int count = 0, String? detail}) {
    _noticeCounter += 1;
    _setState(
      _state.copyWith(
        notice: LibraryNotice(
          id: _noticeCounter,
          type: type,
          count: count,
          detail: detail,
        ),
      ),
    );
  }

  void _setState(LibraryState state) {
    if (_isDisposed) {
      return;
    }
    _state = state;
    notifyListeners();
  }

  @override
  void dispose() {
    _isDisposed = true;
    unawaited(_indexing?.cancel());
    super.dispose();
  }
}
