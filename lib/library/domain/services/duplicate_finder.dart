import '../entities/catalog_image.dart';

/// Finds photos in the library that are byte-for-byte identical.
abstract class DuplicateFinder {
  /// Groups of identical photos (two or more each), largest files first.
  /// [onProgress] gets (files checked, files to check).
  Future<List<List<CatalogImage>>> find({
    void Function(int checked, int total)? onProgress,
  });
}
