import 'geo_point.dart';

/// What to list from the catalog.
class LibraryQuery {
  const LibraryQuery({
    this.text = '',
    this.folder,
    this.albumId,
    this.starredOnly = false,
    this.includeHidden = false,
    this.hiddenFolders = const <String>{},
    this.onlyWithLocation = false,
    this.bounds,
    this.person,
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

  /// Only photos that have a location (from GPS or set by hand)…
  final bool onlyWithLocation;

  /// …inside this box.
  final GeoBounds? bounds;

  /// Only photos with a face named this.
  final String? person;

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
