import 'bool_setting_store.dart';

abstract interface class AppShellSettingsStore {
  Future<bool> loadAutoHideBottomNavOnScroll();

  Future<void> saveAutoHideBottomNavOnScroll(bool enabled);
}

class SharedPreferencesAppShellSettingsStore implements AppShellSettingsStore {
  const SharedPreferencesAppShellSettingsStore({
    this.autoHideBottomNavKey = 'app_shell_auto_hide_bottom_nav_on_scroll_v1',
  });

  final String autoHideBottomNavKey;

  @override
  Future<bool> loadAutoHideBottomNavOnScroll() => _store.load();

  @override
  Future<void> saveAutoHideBottomNavOnScroll(bool enabled) =>
      _store.save(enabled);

  SharedPreferencesBoolSettingStore get _store =>
      SharedPreferencesBoolSettingStore(
        key: autoHideBottomNavKey,
        defaultValue: true,
      );
}
