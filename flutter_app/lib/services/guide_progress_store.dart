import 'package:shared_preferences/shared_preferences.dart';

abstract class GuideProgressStore {
  Future<Set<String>> loadReadLessons();

  Future<void> setLessonRead(String assetPath, bool isRead);
}

class SharedPreferencesGuideProgressStore implements GuideProgressStore {
  static const String _storageKey = 'guide_read_lessons_v1';

  @override
  Future<Set<String>> loadReadLessons() async {
    final prefs = await SharedPreferences.getInstance();
    final storedLessons = prefs.getStringList(_storageKey) ?? const <String>[];
    return storedLessons.where((path) => path.trim().isNotEmpty).toSet();
  }

  @override
  Future<void> setLessonRead(String assetPath, bool isRead) async {
    final prefs = await SharedPreferences.getInstance();
    final storedLessons = (prefs.getStringList(_storageKey) ?? const <String>[])
        .where((path) => path.trim().isNotEmpty)
        .toSet();

    if (isRead) {
      storedLessons.add(assetPath);
    } else {
      storedLessons.remove(assetPath);
    }

    await prefs.setStringList(_storageKey, storedLessons.toList()..sort());
  }
}
