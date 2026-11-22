import '../../../editor/domain/entities/image_edits.dart';
import '../entities/catalog_image.dart';
import '../entities/library_query.dart';
import '../entities/photo_info.dart';

/// The library's index of photos in watched folders, plus albums. Photos
/// can always be re-indexed from disk; albums live only here.
abstract class CatalogRepository {
  /// Every catalogued photo under [root] (any depth), by path.
  Future<Map<String, CatalogImage>> imagesUnder(String root);

  Future<void> upsert(List<CatalogImage> images);

  Future<void> remove(Iterable<String> paths);

  /// Drops photos that are not under any of [roots].
  Future<void> removeOutside(List<String> roots);

  /// Folders that contain catalogued photos, with their photo counts.
  Future<List<CatalogFolder>> folders(LibraryQuery query);

  Future<List<CatalogImage>> search(LibraryQuery query);

  Future<CatalogImage?> image(String path);

  Future<void> updateInfo(String path, PhotoInfo info);

  Future<void> updateEdits(String path, ImageEdits edits);

  /// Photos with the same size as at least one other photo — the only
  /// candidates for exact duplicates.
  Future<List<CatalogImage>> sameSizeCandidates();

  Future<List<Album>> albums();

  Future<Album> createAlbum(String name);

  Future<void> renameAlbum(int id, String name);

  /// Deletes the album only; its photos stay where they are.
  Future<void> deleteAlbum(int id);

  Future<void> addToAlbum(int id, List<String> paths);

  Future<void> removeFromAlbum(int id, List<String> paths);

  Future<void> close();
}
