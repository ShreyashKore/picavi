import 'package:shared_preferences/shared_preferences.dart';

class AppPreferencesService {
  static const String _defaultViewerPromptHandledKey =
      'defaultViewerPromptHandled';

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
}
