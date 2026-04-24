String lessonProgressKey({required String assetPath, String? lessonId}) {
  final sanitizedLessonId = lessonId?.trim();
  if (sanitizedLessonId != null && sanitizedLessonId.isNotEmpty) {
    return sanitizedLessonId;
  }

  return lessonProgressKeyFromAssetPath(assetPath);
}

String lessonProgressKeyFromStoredValue(
  String rawValue, {
  Map<String, String> renamedAssetPaths = const <String, String>{},
}) {
  final sanitizedValue = rawValue.trim();
  if (sanitizedValue.isEmpty) {
    return '';
  }

  final canonicalPath = renamedAssetPaths[sanitizedValue] ?? sanitizedValue;
  if (!_looksLikeLessonAssetPath(canonicalPath)) {
    return canonicalPath;
  }

  return lessonProgressKeyFromAssetPath(canonicalPath);
}

String lessonProgressKeyFromAssetPath(String assetPath) {
  final sanitizedPath = assetPath.trim().replaceAll('\\', '/');
  if (sanitizedPath.isEmpty) {
    return '';
  }

  final filename = sanitizedPath.split('/').last;
  final withoutExtension = filename.replaceFirst(RegExp(r'\.md$'), '');
  final withoutNumericPrefix = withoutExtension.replaceFirst(
    RegExp(r'^\d+[_-]*'),
    '',
  );
  final fallbackKey = withoutNumericPrefix.trim();
  return fallbackKey.isEmpty ? sanitizedPath : fallbackKey;
}

bool _looksLikeLessonAssetPath(String value) {
  final normalizedValue = value.replaceAll('\\', '/').toLowerCase();
  return normalizedValue.startsWith('assets/') &&
      normalizedValue.endsWith('.md');
}
