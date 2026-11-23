import '../../domain/entities/catalog_image.dart';
import '../../domain/entities/library_query.dart';

/// What the grid is showing.
enum LibrarySource { allPhotos, starred, places, folder, album }

enum LibraryNoticeType {
  saveFailed,
  albumCreated,
  addedToAlbum,
  removedFromAlbum,
  movedToTrash,
  trashFailed,
}

class LibraryNotice {
  const LibraryNotice({
    required this.id,
    required this.type,
    this.count = 0,
    this.detail,
  });

  final int id;
  final LibraryNoticeType type;
  final int count;
  final String? detail;
}

class LibraryState {
  const LibraryState({
    this.isLoading = true,
    this.roots = const <String>[],
    this.hiddenFolders = const <String>{},
    this.folders = const <CatalogFolder>[],
    this.albums = const <Album>[],
    this.source = LibrarySource.allPhotos,
    this.folder,
    this.albumId,
    this.searchText = '',
    this.showHidden = false,
    this.images = const <CatalogImage>[],
    this.selection = const <String>{},
    this.anchorPath,
    this.progress,
    this.notice,
  });

  final bool isLoading;

  /// Watched folders.
  final List<String> roots;
  final Set<String> hiddenFolders;
  final List<CatalogFolder> folders;
  final List<Album> albums;

  final LibrarySource source;
  final String? folder;
  final int? albumId;
  final String searchText;
  final bool showHidden;

  /// The photos in the grid, in display order.
  final List<CatalogImage> images;
  final Set<String> selection;

  /// Where a Shift-click range starts.
  final String? anchorPath;

  /// Non-null while the watched folders are being scanned.
  final IndexProgress? progress;
  final LibraryNotice? notice;

  bool get isIndexing => progress != null && !progress!.done;

  bool get hasRoots => roots.isNotEmpty;

  /// Grid shows photos grouped by month (rather than one flat list).
  bool get groupsByMonth =>
      source == LibrarySource.allPhotos || source == LibrarySource.starred;

  Album? get album {
    for (final album in albums) {
      if (album.id == albumId) {
        return album;
      }
    }
    return null;
  }

  List<String> get selectedInOrder => [
    for (final image in images)
      if (selection.contains(image.path)) image.path,
  ];

  LibraryState copyWith({
    bool? isLoading,
    List<String>? roots,
    Set<String>? hiddenFolders,
    List<CatalogFolder>? folders,
    List<Album>? albums,
    LibrarySource? source,
    String? Function()? folder,
    int? Function()? albumId,
    String? searchText,
    bool? showHidden,
    List<CatalogImage>? images,
    Set<String>? selection,
    String? Function()? anchorPath,
    IndexProgress? Function()? progress,
    LibraryNotice? notice,
  }) {
    return LibraryState(
      isLoading: isLoading ?? this.isLoading,
      roots: roots ?? this.roots,
      hiddenFolders: hiddenFolders ?? this.hiddenFolders,
      folders: folders ?? this.folders,
      albums: albums ?? this.albums,
      source: source ?? this.source,
      folder: folder != null ? folder() : this.folder,
      albumId: albumId != null ? albumId() : this.albumId,
      searchText: searchText ?? this.searchText,
      showHidden: showHidden ?? this.showHidden,
      images: images ?? this.images,
      selection: selection ?? this.selection,
      anchorPath: anchorPath != null ? anchorPath() : this.anchorPath,
      progress: progress != null ? progress() : this.progress,
      notice: notice ?? this.notice,
    );
  }
}
