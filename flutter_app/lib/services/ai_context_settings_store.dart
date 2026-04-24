import 'package:shared_preferences/shared_preferences.dart';

abstract interface class AiContextSettingsStore {
  Future<bool> loadEnabled();

  Future<void> saveEnabled(bool enabled);
}

class SharedPreferencesAiContextSettingsStore
    implements AiContextSettingsStore {
  const SharedPreferencesAiContextSettingsStore({
    this.enabledKey = 'ai_word_contexts_enabled_v1',
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
