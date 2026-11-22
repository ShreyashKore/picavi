/// What to list from the catalog.
class LibraryQuery {
  const LibraryQuery({
    this.text = '',
    this.folder,
    this.albumId,
    this.starredOnly = false,
    this.includeHidden = false,
    this.hiddenFolders = const <String>{},
  });

  /// Words that must all appear in the name, folder, camera, caption, tags
  /// or date (`2019`, `2019-07`).
  final String text;

  /// Only photos directly in this folder.
  final String? folder;

  /// Only photos in this album, in album order.
  final int? albumId;
  final bool starredOnly;

  /// Also list photos (and folders) that were hidden.
  final bool includeHidden;
  final Set<String> hiddenFolders;

  List<String> get words => text
      .toLowerCase()
      .split(RegExp(r'\s+'))
      .where((word) => word.isNotEmpty)
      .toList();
}

/// How far a library scan has got.
class IndexProgress {
  const IndexProgress({
    required this.found,
    required this.processed,
    this.done = false,
  });

  final int found;
  final int processed;
  final bool done;
}
