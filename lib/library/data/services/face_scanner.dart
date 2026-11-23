import '../../domain/entities/catalog_image.dart';
import '../../domain/entities/face.dart';
import '../../domain/entities/library_query.dart';
import '../../domain/repositories/catalog_repository.dart';
import '../../domain/services/face_detector.dart';

/// Looks for faces in library photos that are new or changed since their
/// last scan. Names saved next to the photos are matched back to the faces
/// found, so they survive a rebuilt catalog.
class FaceScanner {
  const FaceScanner(this._catalog, this._detector);

  final CatalogRepository _catalog;
  final FaceDetectorService _detector;

  /// How much a found face must overlap a saved one to take its name.
  static const double matchOverlap = 0.4;

  Stream<IndexProgress> scan() async* {
    final images = await _catalog.search(
      const LibraryQuery(includeHidden: true),
    );
    final scanned = await _catalog.faceScanStamps();
    final todo = [
      for (final image in images)
        if (scanned[image.path] != image.stamp) image,
    ];
    var processed = 0;
    yield IndexProgress(found: todo.length, processed: processed);
    for (final image in todo) {
      final faces = await _detector.detect(image.path) ?? const [];
      await _catalog.replaceFaces(image.path, image.stamp, [
        for (final face in faces) (face, nameFor(face, image)),
      ]);
      processed += 1;
      yield IndexProgress(found: todo.length, processed: processed);
    }
    yield IndexProgress(found: todo.length, processed: processed, done: true);
  }

  /// The saved name whose box best matches [face], if any.
  static String? nameFor(DetectedFace face, CatalogImage image) {
    PersonTag? best;
    var bestOverlap = matchOverlap;
    for (final tag in image.info.people) {
      final overlap = face.box.overlap(tag.box);
      if (overlap >= bestOverlap) {
        bestOverlap = overlap;
        best = tag;
      }
    }
    return best?.name;
  }
}
