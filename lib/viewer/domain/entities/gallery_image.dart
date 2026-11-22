import 'dart:io';

import 'package:path/path.dart' as p;

class GalleryImage {
  const GalleryImage({required this.path, this.revision = 0});

  final String path;

  /// Bumped when the file is rewritten in place (e.g. a saved rotation), so
  /// widgets know to reload it even though the path is unchanged.
  final int revision;

  String get fileName => p.basename(path);

  File get asFile => File(path);

  GalleryImage nextRevision() =>
      GalleryImage(path: path, revision: revision + 1);
}
