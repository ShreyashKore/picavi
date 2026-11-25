import '../../../editor/domain/entities/image_edits.dart';
import '../entities/catalog_image.dart';
import '../entities/face.dart';
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

  // Faces

  /// The file stamp each photo had when its faces were last looked for.
  Future<Map<String, FileStamp>> faceScanStamps();

  /// Replaces the faces of [path] with [faces] (each with a name, if
  /// known) and records that the photo was scanned at [stamp].
  Future<void> replaceFaces(
    String path,
    FileStamp stamp,
    List<(DetectedFace, String?)> faces,
  );

  /// Faces, optionally only of one photo or person, or only unnamed ones.
  /// Fingerprints are loaded only when [withPrints] is set.
  Future<List<CatalogFace>> faces({
    String? path,
    String? name,
    bool unnamedOnly = false,
    bool includeIgnored = false,
    bool withPrints = false,
  });

  /// Names (or, with null, un-names) faces.
  Future<void> nameFaces(List<int> ids, String? name);

  Future<void> setFacesIgnored(List<int> ids, bool ignored);

  /// Everyone who has been named, with a face to show.
  Future<List<PersonSummary>> people();

  Future<void> close();
}
