import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

abstract interface class ThemeModeStore {
  Future<ThemeMode> load();

  Future<void> save(ThemeMode mode);
}

class SharedPreferencesThemeModeStore implements ThemeModeStore {
  const SharedPreferencesThemeModeStore({
    this.preferenceKey = 'app_theme_mode',
  });

  final String preferenceKey;

  @override
  Future<ThemeMode> load() async {
    final prefs = await SharedPreferences.getInstance();
    final storedValue = prefs.getString(preferenceKey);

    return switch (storedValue) {
      'dark' => ThemeMode.dark,
      _ => ThemeMode.light,
    };
  }

  @override
  Future<void> save(ThemeMode mode) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(preferenceKey, switch (mode) {
      ThemeMode.dark => 'dark',
      _ => 'light',
    });
  }
}
