import 'dart:io';

import 'package:path/path.dart' as p;

class GalleryImage {
  const GalleryImage({required this.path});

  final String path;

  String get fileName => p.basename(path);

  File get asFile => File(path);
}
