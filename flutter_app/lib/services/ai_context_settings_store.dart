import 'bool_setting_store.dart';

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
  Future<bool> loadEnabled() => _store.load();

  @override
  Future<void> saveEnabled(bool enabled) => _store.save(enabled);

  SharedPreferencesBoolSettingStore get _store =>
      SharedPreferencesBoolSettingStore(key: enabledKey);
}
