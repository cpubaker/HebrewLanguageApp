import 'package:flutter/widgets.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum AppLocalePreference {
  uk('uk', Locale('uk')),
  en('en', Locale('en'));

  const AppLocalePreference(this.storageValue, this.locale);

  final String storageValue;
  final Locale locale;

  AppLocalePreference get next {
    return switch (this) {
      AppLocalePreference.uk => AppLocalePreference.en,
      AppLocalePreference.en => AppLocalePreference.uk,
    };
  }

  static AppLocalePreference fromStorageValue(String? value) {
    return switch (value) {
      'en' => AppLocalePreference.en,
      _ => AppLocalePreference.uk,
    };
  }
}

abstract interface class AppLocaleStore {
  Future<AppLocalePreference> load();

  Future<void> save(AppLocalePreference preference);
}

class SharedPreferencesAppLocaleStore implements AppLocaleStore {
  const SharedPreferencesAppLocaleStore({
    this.preferenceKey = 'app_locale',
  });

  final String preferenceKey;

  @override
  Future<AppLocalePreference> load() async {
    final prefs = await SharedPreferences.getInstance();
    final storedValue = prefs.getString(preferenceKey);

    return AppLocalePreference.fromStorageValue(storedValue);
  }

  @override
  Future<void> save(AppLocalePreference preference) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(preferenceKey, preference.storageValue);
  }
}
