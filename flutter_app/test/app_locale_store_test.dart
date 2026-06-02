import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:hebrew_language_flutter/services/app_locale_store.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues(<String, Object>{});
  });

  test('falls back to Ukrainian when no value is stored', () async {
    const store = SharedPreferencesAppLocaleStore();

    expect(await store.load(), AppLocalePreference.uk);
  });

  test('falls back to Ukrainian when the stored value is unrecognized',
      () async {
    SharedPreferences.setMockInitialValues(<String, Object>{
      'app_locale': 'fr',
    });
    const store = SharedPreferencesAppLocaleStore();

    expect(await store.load(), AppLocalePreference.uk);
  });

  test('saves and loads the chosen locale across instances', () async {
    const store = SharedPreferencesAppLocaleStore();

    await store.save(AppLocalePreference.en);

    expect(await store.load(), AppLocalePreference.en);
  });

  test('honours a custom preference key', () async {
    SharedPreferences.setMockInitialValues(<String, Object>{
      'custom_locale_key': 'en',
    });
    const store = SharedPreferencesAppLocaleStore(
      preferenceKey: 'custom_locale_key',
    );

    expect(await store.load(), AppLocalePreference.en);
  });

  test('next cycles between Ukrainian and English', () {
    expect(AppLocalePreference.uk.next, AppLocalePreference.en);
    expect(AppLocalePreference.en.next, AppLocalePreference.uk);
  });

  test('locale getter returns matching Flutter Locale', () {
    expect(AppLocalePreference.uk.locale, const Locale('uk'));
    expect(AppLocalePreference.en.locale, const Locale('en'));
  });
}
