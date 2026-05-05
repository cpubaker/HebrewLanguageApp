import 'package:shared_preferences/shared_preferences.dart';

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
  Future<bool> loadAutoHideBottomNavOnScroll() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(autoHideBottomNavKey) ?? true;
  }

  @override
  Future<void> saveAutoHideBottomNavOnScroll(bool enabled) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(autoHideBottomNavKey, enabled);
  }
}
