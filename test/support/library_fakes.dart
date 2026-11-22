import 'package:oiv/library/data/repositories/sqlite_catalog_repository.dart';
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
