/// Which folders the library watches, and which it hides.
abstract class LibrarySettingsRepository {
  Future<List<String>> watchedFolders();

  Future<void> setWatchedFolders(List<String> folders);

  Future<Set<String>> hiddenFolders();

  Future<void> setHiddenFolders(Set<String> folders);

  /// Where imported photos go, or null for the default (Pictures).
  Future<String?> importDestination();

  Future<void> setImportDestination(String folder);
}
