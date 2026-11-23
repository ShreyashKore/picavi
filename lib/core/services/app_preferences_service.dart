import 'dart:io';

import 'package:shared_preferences/shared_preferences.dart';

class AppPreferencesService {
  static const String _defaultViewerPromptHandledKey =
      'defaultViewerPromptHandled';
  static const String _restoreLastOpenedImageEnabledKey =
      'restoreLastOpenedImageEnabled';
  static const String _lastOpenedImagePathKey = 'lastOpenedImagePath';
  static const String _showRecentFoldersEnabledKey = 'showRecentFoldersEnabled';
  static const String _recentFoldersKey = 'recentFolders';
  static const String _imageSortOrderKey = 'imageSortOrder';
  static const String _slideshowIntervalKey = 'slideshowIntervalSeconds';
  static const String _slideshowShuffleKey = 'slideshowShuffle';
  static const String _slideshowLoopKey = 'slideshowLoop';
  static const String _slideshowFullScreenKey = 'slideshowFullScreen';
  static const String _libraryFoldersKey = 'libraryWatchedFolders';
  static const String _libraryHiddenFoldersKey = 'libraryHiddenFolders';
  static const String _importDestinationKey = 'importDestination';

  /// Maximum number of recently opened folders kept in history.
  static const int maxRecentFolders = 10;

  Future<bool> hasHandledDefaultViewerPrompt() async {
    try {
      final preferences = await SharedPreferences.getInstance();
      return preferences.getBool(_defaultViewerPromptHandledKey) ?? false;
    } catch (_) {
      return false;
    }
  }

  Future<void> markDefaultViewerPromptHandled() async {
    try {
      final preferences = await SharedPreferences.getInstance();
      await preferences.setBool(_defaultViewerPromptHandledKey, true);
    } catch (_) {
      // Ignore persistence failures and keep the app usable.
    }
  }

  Future<bool> isRestoreLastOpenedImageEnabled() async {
    try {
      final preferences = await SharedPreferences.getInstance();
      return preferences.getBool(_restoreLastOpenedImageEnabledKey) ?? true;
    } catch (_) {
      return false;
    }
  }

  Future<void> setRestoreLastOpenedImageEnabled(bool enabled) async {
    try {
      final preferences = await SharedPreferences.getInstance();
      await preferences.setBool(_restoreLastOpenedImageEnabledKey, enabled);
      if (!enabled) {
        await preferences.remove(_lastOpenedImagePathKey);
      }
    } catch (_) {
      // Ignore persistence failures and keep the app usable.
    }
  }

  Future<String?> getLastOpenedImagePath() async {
    try {
      final preferences = await SharedPreferences.getInstance();
      final path = preferences.getString(_lastOpenedImagePathKey)?.trim();
      if (path == null || path.isEmpty) {
        return null;
      }

      return path;
    } catch (_) {
      return null;
    }
  }

  Future<void> setLastOpenedImagePath(String path) async {
    final trimmedPath = path.trim();
    if (trimmedPath.isEmpty) {
      return;
    }

    try {
      final preferences = await SharedPreferences.getInstance();
      final restoreEnabled =
          preferences.getBool(_restoreLastOpenedImageEnabledKey) ?? false;
      if (!restoreEnabled) {
        return;
      }

      await preferences.setString(_lastOpenedImagePathKey, trimmedPath);
    } catch (_) {
      // Ignore persistence failures and keep the app usable.
    }
  }

  Future<void> clearLastOpenedImagePath() async {
    try {
      final preferences = await SharedPreferences.getInstance();
      await preferences.remove(_lastOpenedImagePathKey);
    } catch (_) {
      // Ignore persistence failures and keep the app usable.
    }
  }

  Future<bool> isShowRecentFoldersEnabled() async {
    try {
      final preferences = await SharedPreferences.getInstance();
      return preferences.getBool(_showRecentFoldersEnabledKey) ?? true;
    } catch (_) {
      return true;
    }
  }

  Future<void> setShowRecentFoldersEnabled(bool enabled) async {
    try {
      final preferences = await SharedPreferences.getInstance();
      await preferences.setBool(_showRecentFoldersEnabledKey, enabled);
      if (!enabled) {
        await preferences.remove(_recentFoldersKey);
      }
    } catch (_) {
      // Ignore persistence failures and keep the app usable.
    }
  }

  Future<List<String>> getRecentFolders() async {
    try {
      final preferences = await SharedPreferences.getInstance();
      return preferences.getStringList(_recentFoldersKey) ?? const <String>[];
    } catch (_) {
      return const <String>[];
    }
  }

  /// Records [path] as the most recently opened folder, de-duplicating and
  /// capping the history at [maxRecentFolders]. No-op when the feature is
  /// disabled, so history is only collected while the user opts in.
  Future<void> addRecentFolder(String path) async {
    final trimmedPath = path.trim();
    if (trimmedPath.isEmpty) {
      return;
    }

    try {
      final preferences = await SharedPreferences.getInstance();
      final enabled = preferences.getBool(_showRecentFoldersEnabledKey) ?? true;
      if (!enabled) {
        return;
      }

      final existing =
          preferences.getStringList(_recentFoldersKey) ?? const <String>[];
      final updated = <String>[
        trimmedPath,
        ...existing.where((folder) => folder != trimmedPath),
      ];
      if (updated.length > maxRecentFolders) {
        updated.removeRange(maxRecentFolders, updated.length);
      }

      await preferences.setStringList(_recentFoldersKey, updated);
    } catch (_) {
      // Ignore persistence failures and keep the app usable.
    }
  }

  Future<void> removeRecentFolder(String path) async {
    try {
      final preferences = await SharedPreferences.getInstance();
      final existing = preferences.getStringList(_recentFoldersKey);
      if (existing == null || existing.isEmpty) {
        return;
      }

      final updated = existing
          .where((folder) => folder != path)
          .toList(growable: false);
      if (updated.length == existing.length) {
        return;
      }

      await preferences.setStringList(_recentFoldersKey, updated);
    } catch (_) {
      // Ignore persistence failures and keep the app usable.
    }
  }

  /// The persisted gallery sort order, as an opaque key owned by the viewer
  /// feature (see `ImageSortOrder.storageKey`).
  Future<String?> getImageSortOrderKey() async {
    try {
      final preferences = await SharedPreferences.getInstance();
      return preferences.getString(_imageSortOrderKey);
    } catch (_) {
      return null;
    }
  }

  Future<void> setImageSortOrderKey(String key) async {
    try {
      final preferences = await SharedPreferences.getInstance();
      await preferences.setString(_imageSortOrderKey, key);
    } catch (_) {
      // Ignore persistence failures and keep the app usable.
    }
  }

  /// Slideshow preferences. Missing values come back as null so the viewer
  /// feature can apply its own defaults.
  Future<({int? intervalSeconds, bool? shuffle, bool? loop, bool? fullScreen})>
  getSlideshowPreferences() async {
    try {
      final preferences = await SharedPreferences.getInstance();
      return (
        intervalSeconds: preferences.getInt(_slideshowIntervalKey),
        shuffle: preferences.getBool(_slideshowShuffleKey),
        loop: preferences.getBool(_slideshowLoopKey),
        fullScreen: preferences.getBool(_slideshowFullScreenKey),
      );
    } catch (_) {
      return (
        intervalSeconds: null,
        shuffle: null,
        loop: null,
        fullScreen: null,
      );
    }
  }

  Future<void> setSlideshowPreferences({
    required int intervalSeconds,
    required bool shuffle,
    required bool loop,
    required bool fullScreen,
  }) async {
    try {
      final preferences = await SharedPreferences.getInstance();
      await preferences.setInt(_slideshowIntervalKey, intervalSeconds);
      await preferences.setBool(_slideshowShuffleKey, shuffle);
      await preferences.setBool(_slideshowLoopKey, loop);
      await preferences.setBool(_slideshowFullScreenKey, fullScreen);
    } catch (_) {
      // Ignore persistence failures and keep the app usable.
    }
  }

  Future<String?> resolveStartupOpenPath() async {
    try {
      if (!await isRestoreLastOpenedImageEnabled()) {
        return null;
      }

      final path = await getLastOpenedImagePath();
      if (path == null) {
        return null;
      }

      final file = File(path);
      if (await file.exists()) {
        return file.absolute.path;
      }

      final parentDirectory = file.parent;
      if (await parentDirectory.exists()) {
        return parentDirectory.absolute.path;
      }
    } catch (_) {
      // Fall through to a null startup path.
    }

    return null;
  }

  Future<List<String>> getLibraryFolders() =>
      _getStringList(_libraryFoldersKey);

  Future<void> setLibraryFolders(List<String> folders) =>
      _setStringList(_libraryFoldersKey, folders);

  Future<List<String>> getLibraryHiddenFolders() =>
      _getStringList(_libraryHiddenFoldersKey);

  Future<void> setLibraryHiddenFolders(List<String> folders) =>
      _setStringList(_libraryHiddenFoldersKey, folders);

  Future<String?> getImportDestination() async {
    try {
      final preferences = await SharedPreferences.getInstance();
      return preferences.getString(_importDestinationKey);
    } catch (_) {
      return null;
    }
  }

  Future<void> setImportDestination(String folder) async {
    try {
      final preferences = await SharedPreferences.getInstance();
      await preferences.setString(_importDestinationKey, folder);
    } catch (_) {
      // Ignore persistence failures and keep the app usable.
    }
  }

  Future<List<String>> _getStringList(String key) async {
    try {
      final preferences = await SharedPreferences.getInstance();
      return preferences.getStringList(key) ?? const <String>[];
    } catch (_) {
      return const <String>[];
    }
  }

  Future<void> _setStringList(String key, List<String> values) async {
    try {
      final preferences = await SharedPreferences.getInstance();
      await preferences.setStringList(key, values);
    } catch (_) {
      // Ignore persistence failures and keep the app usable.
    }
  }
}
