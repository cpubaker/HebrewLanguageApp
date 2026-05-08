import 'package:shared_preferences/shared_preferences.dart';

abstract interface class BoolSettingStore {
  Future<bool> load();

  Future<void> save(bool value);
}

class SharedPreferencesBoolSettingStore implements BoolSettingStore {
  const SharedPreferencesBoolSettingStore({
    required this.key,
    this.defaultValue = false,
  });

  final String key;
  final bool defaultValue;

  @override
  Future<bool> load() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(key) ?? defaultValue;
  }

  @override
  Future<void> save(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(key, value);
  }
}
