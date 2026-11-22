import '../../../core/services/app_preferences_service.dart';
import '../../domain/entities/slideshow_settings.dart';

/// Loads and saves [SlideshowSettings] through [AppPreferencesService].
class SlideshowSettingsStore {
  const SlideshowSettingsStore(this._preferences);

  final AppPreferencesService _preferences;

  Future<SlideshowSettings> load() async {
    const defaults = SlideshowSettings();
    final stored = await _preferences.getSlideshowPreferences();
    final interval = stored.intervalSeconds;
    return SlideshowSettings(
      intervalSeconds:
          interval != null &&
              SlideshowSettings.intervalChoices.contains(interval)
          ? interval
          : defaults.intervalSeconds,
      shuffle: stored.shuffle ?? defaults.shuffle,
      loop: stored.loop ?? defaults.loop,
      fullScreen: stored.fullScreen ?? defaults.fullScreen,
    );
  }

  Future<void> save(SlideshowSettings settings) {
    return _preferences.setSlideshowPreferences(
      intervalSeconds: settings.intervalSeconds,
      shuffle: settings.shuffle,
      loop: settings.loop,
      fullScreen: settings.fullScreen,
    );
  }
}
