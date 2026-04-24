import 'package:shared_preferences/shared_preferences.dart';

abstract interface class AiPracticeTextSettingsStore {
  Future<bool> loadEnabled();

  Future<void> saveEnabled(bool enabled);
}

class SharedPreferencesAiPracticeTextSettingsStore
    implements AiPracticeTextSettingsStore {
  const SharedPreferencesAiPracticeTextSettingsStore({
    this.enabledKey = 'ai_practice_texts_enabled_v1',
  });

  final String enabledKey;

  @override
  Future<bool> loadEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(enabledKey) ?? false;
  }

  @override
  Future<void> saveEnabled(bool enabled) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(enabledKey, enabled);
  }
}
