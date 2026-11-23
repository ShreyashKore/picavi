import 'catalog_image.dart';

/// Somewhere photos can be imported from: a camera, card or folder.
class ImportSource {
  const ImportSource({required this.path, required this.name});

  final String path;
  final String name;
}

/// A photo found on an import source.
class ImportCandidate {
  const ImportCandidate({
    required this.path,
    required this.stamp,
    this.taken,
    this.alreadyImported = false,
  });

  final String path;
  final FileStamp stamp;
  final DateTime? taken;

  /// A file with the same name and size is already where it would go.
  final bool alreadyImported;

  DateTime get date =>
      taken ?? DateTime.fromMillisecondsSinceEpoch(stamp.modifiedMs);
}

class ImportProgress {
  const ImportProgress({
    required this.copied,
    required this.skipped,
    required this.failed,
    required this.total,
    this.done = false,
  });

  final int copied;
  final int skipped;
  final int failed;
  final int total;
  final bool done;

  int get handled => copied + skipped + failed;
}
