/// Which folders the library watches, and which it hides.
abstract class LibrarySettingsRepository {
  Future<List<String>> watchedFolders();

  Future<void> setWatchedFolders(List<String> folders);

  Future<Set<String>> hiddenFolders();

  Future<void> setHiddenFolders(Set<String> folders);
}
