import 'bool_setting_store.dart';

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
  Future<bool> loadEnabled() => _store.load();

  @override
  Future<void> saveEnabled(bool enabled) => _store.save(enabled);

  SharedPreferencesBoolSettingStore get _store =>
      SharedPreferencesBoolSettingStore(key: enabledKey);
}
