import 'dart:typed_data';

import 'package:image/image.dart' as img;
import 'package:oiv/library/data/repositories/sqlite_catalog_repository.dart';
import 'package:oiv/library/domain/entities/face.dart';
import 'package:oiv/library/domain/services/face_detector.dart';
import 'package:oiv/library/domain/entities/catalog_image.dart';
import 'package:oiv/library/domain/entities/library_query.dart';
import 'package:oiv/library/domain/entities/photo_info.dart';
import 'package:oiv/library/domain/repositories/catalog_repository.dart';
import 'package:oiv/library/domain/repositories/library_settings_repository.dart';
import 'package:oiv/library/domain/services/duplicate_finder.dart';
import 'package:oiv/library/domain/services/library_indexer.dart';
import 'package:oiv/viewer/domain/services/file_operations_service.dart';
import 'package:path/path.dart' as p;

CatalogImage catalogPhoto(
  String path, {
  DateTime? taken,
  PhotoInfo info = PhotoInfo.none,
  int size = 10,
}) => CatalogImage(
  path: path,
  folder: p.dirname(path),
  name: p.basename(path),
  stamp: FileStamp(size, 0),
  taken: taken ?? DateTime(2020, 1, 1),
  info: info,
);

/// "Indexes" by upserting a fixed list of photos that sit under the roots.
class FakeIndexer implements LibraryIndexer {
  FakeIndexer(this.catalog, this.onDisk);

  final CatalogRepository catalog;
  final List<CatalogImage> onDisk;
  int runs = 0;

  @override
  Stream<IndexProgress> index(List<String> roots) async* {
    runs += 1;
    await catalog.removeOutside(roots);
    final under = [
      for (final image in onDisk)
        if (roots.any((root) => p.isWithin(root, image.path))) image,
    ];
    await catalog.upsert(under);
    yield IndexProgress(
      found: under.length,
      processed: under.length,
      done: true,
    );
  }
}

class InMemoryLibrarySettings implements LibrarySettingsRepository {
  List<String> roots = [];
  Set<String> hidden = {};

  @override
  Future<List<String>> watchedFolders() async => roots;

  @override
  Future<void> setWatchedFolders(List<String> folders) async => roots = folders;

  @override
  Future<Set<String>> hiddenFolders() async => hidden;

  @override
  Future<void> setHiddenFolders(Set<String> folders) async => hidden = folders;

  String? destination;

  @override
  Future<String?> importDestination() async => destination;

  @override
  Future<void> setImportDestination(String folder) async =>
      destination = folder;
}

class FakeDuplicateFinder implements DuplicateFinder {
  List<List<CatalogImage>> groups = [];

  @override
  Future<List<List<CatalogImage>>> find({
    void Function(int checked, int total)? onProgress,
  }) async => groups;
}

class TrashOnlyFileOperations implements FileOperationsService {
  final List<String> trashed = [];
  Set<String> failing = {};

  @override
  Future<bool> moveToTrash(String path) async {
    if (failing.contains(path)) {
      return false;
    }
    trashed.add(path);
    return true;
  }

  @override
  Future<bool> reveal(String path) async => true;

  @override
  bool get canShare => false;

  @override
  Future<bool> share(List<String> paths, ShareAnchor anchor) async => false;

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

/// Catalog plus fakes, wired like [LibraryServices].
class LibraryFixture {
  LibraryFixture(List<CatalogImage> onDisk, {List<String> roots = const []})
    : catalog = SqliteCatalogRepository.inMemory() {
    indexer = FakeIndexer(catalog, onDisk);
    settings.roots = roots;
  }

  final SqliteCatalogRepository catalog;
  late final FakeIndexer indexer;
  final InMemoryLibrarySettings settings = InMemoryLibrarySettings();
  final FakeDuplicateFinder duplicates = FakeDuplicateFinder();
  final TrashOnlyFileOperations files = TrashOnlyFileOperations();
}

/// A fingerprint pointing mostly along [axis] (0–7), with a little [noise].
Float32List facePrint(int axis, {double noise = 0}) {
  final values = Float32List(8);
  values[axis] = 1;
  values[(axis + 1) % 8] = noise;
  return values;
}

final Uint8List tinyJpeg = img.encodeJpg(img.Image(width: 8, height: 8));

/// Returns preset faces per path and counts calls.
class FakeFaceDetector implements FaceDetectorService {
  FakeFaceDetector(this.faces, {this.isAvailable = true});

  final Map<String, List<DetectedFace>> faces;

  /// Photos detection fails for.
  final Set<String> failing = {};
  final List<String> calls = [];

  @override
  final bool isAvailable;

  @override
  Future<List<DetectedFace>?> detect(String path) async {
    calls.add(path);
    return failing.contains(path) ? null : faces[path] ?? const [];
  }
}

DetectedFace detectedFace(int axis, {double left = 0.1, double noise = 0}) =>
    DetectedFace(
      box: FaceBox(left, 0.1, 0.2, 0.2),
      crop: tinyJpeg,
      print: facePrint(axis, noise: noise),
    );
