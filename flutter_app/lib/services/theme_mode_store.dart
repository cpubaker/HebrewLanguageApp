import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum AppThemePreference {
  light('light'),
  dark('dark'),
  system('system');

  const AppThemePreference(this.storageValue);

  final String storageValue;

  bool get requiresNightMode {
    return switch (this) {
      AppThemePreference.light => false,
      AppThemePreference.dark || AppThemePreference.system => true,
    };
  }

  AppThemePreference get next {
    return switch (this) {
      AppThemePreference.light => AppThemePreference.dark,
      AppThemePreference.dark => AppThemePreference.system,
      AppThemePreference.system => AppThemePreference.light,
    };
  }

  static AppThemePreference fromThemeMode(ThemeMode mode) {
    return switch (mode) {
      ThemeMode.dark => AppThemePreference.dark,
      ThemeMode.system => AppThemePreference.system,
      ThemeMode.light => AppThemePreference.light,
    };
  }

  static AppThemePreference fromStorageValue(String? value) {
    return switch (value) {
      'dark' => AppThemePreference.dark,
      'system' || 'automatic' => AppThemePreference.system,
      _ => AppThemePreference.light,
    };
  }
}

abstract interface class ThemeModeStore {
  Future<AppThemePreference> load();

  Future<void> save(AppThemePreference preference);
}

class SharedPreferencesThemeModeStore implements ThemeModeStore {
  const SharedPreferencesThemeModeStore({
    this.preferenceKey = 'app_theme_mode',
  });

  final String preferenceKey;

  @override
  Future<AppThemePreference> load() async {
    final prefs = await SharedPreferences.getInstance();
    final storedValue = prefs.getString(preferenceKey);

    return AppThemePreference.fromStorageValue(storedValue);
  }

  @override
  Future<void> save(AppThemePreference preference) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(preferenceKey, preference.storageValue);
  }
}
