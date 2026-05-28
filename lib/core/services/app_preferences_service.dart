import 'dart:io';

import 'package:shared_preferences/shared_preferences.dart';

class AppPreferencesService {
  static const String _defaultViewerPromptHandledKey =
      'defaultViewerPromptHandled';
  static const String _restoreLastOpenedImageEnabledKey =
      'restoreLastOpenedImageEnabled';
  static const String _lastOpenedImagePathKey = 'lastOpenedImagePath';

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
}
