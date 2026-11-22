import '../entities/library_query.dart';

/// Brings the catalog in line with what is on disk under the watched
/// folders: new and changed photos are read, missing ones removed.
abstract class LibraryIndexer {
  Stream<IndexProgress> index(List<String> roots);
}
