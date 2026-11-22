import '../../../editor/domain/entities/image_edits.dart';
import 'photo_info.dart';

/// Size and modification time, used to notice that a file changed.
class FileStamp {
  const FileStamp(this.size, this.modifiedMs);

  final int size;
  final int modifiedMs;

  @override
  bool operator ==(Object other) =>
      other is FileStamp &&
      other.size == size &&
      other.modifiedMs == modifiedMs;

  @override
  int get hashCode => Object.hash(size, modifiedMs);
}

/// One photo in the library catalog.
class CatalogImage {
  const CatalogImage({
    required this.path,
    required this.folder,
    required this.name,
    required this.stamp,
    this.taken,
    this.camera,
    this.info = PhotoInfo.none,
    this.edits = ImageEdits.none,
  });

  final String path;
  final String folder;
  final String name;
  final FileStamp stamp;

  /// When the photo was taken (EXIF), if known.
  final DateTime? taken;
  final String? camera;
  final PhotoInfo info;
  final ImageEdits edits;

  DateTime get modified =>
      DateTime.fromMillisecondsSinceEpoch(stamp.modifiedMs);

  /// The date the timeline uses: when it was taken, else when last changed.
  DateTime get date => taken ?? modified;

  CatalogImage copyWith({PhotoInfo? info, ImageEdits? edits}) {
    return CatalogImage(
      path: path,
      folder: folder,
      name: name,
      stamp: stamp,
      taken: taken,
      camera: camera,
      info: info ?? this.info,
      edits: edits ?? this.edits,
    );
  }
}

class CatalogFolder {
  const CatalogFolder({required this.path, required this.imageCount});

  final String path;
  final int imageCount;
}

class Album {
  const Album({
    required this.id,
    required this.name,
    this.imageCount = 0,
    this.coverPath,
  });

  final int id;
  final String name;
  final int imageCount;
  final String? coverPath;
}
