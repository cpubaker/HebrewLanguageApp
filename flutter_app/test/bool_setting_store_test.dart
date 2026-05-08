import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:hebrew_language_flutter/services/bool_setting_store.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues(<String, Object>{});
  });

  test('loads configured default when a setting is missing', () async {
    const store = SharedPreferencesBoolSettingStore(
      key: 'missing_enabled',
      defaultValue: true,
    );

    expect(await store.load(), isTrue);
  });

  test('saves and loads a boolean value by key', () async {
    const store = SharedPreferencesBoolSettingStore(key: 'feature_enabled');

    await store.save(true);

    expect(await store.load(), isTrue);
  });
}
