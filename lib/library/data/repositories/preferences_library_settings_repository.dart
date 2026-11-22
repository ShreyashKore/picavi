import '../../../core/services/app_preferences_service.dart';
import '../../domain/repositories/library_settings_repository.dart';

class PreferencesLibrarySettingsRepository
    implements LibrarySettingsRepository {
  const PreferencesLibrarySettingsRepository(this._preferences);

  final AppPreferencesService _preferences;

  @override
  Future<List<String>> watchedFolders() => _preferences.getLibraryFolders();

  @override
  Future<void> setWatchedFolders(List<String> folders) =>
      _preferences.setLibraryFolders(folders);

  @override
  Future<Set<String>> hiddenFolders() async =>
      (await _preferences.getLibraryHiddenFolders()).toSet();

  @override
  Future<void> setHiddenFolders(Set<String> folders) =>
      _preferences.setLibraryHiddenFolders(folders.toList()..sort());
}
