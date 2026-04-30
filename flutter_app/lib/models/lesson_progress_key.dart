String lessonProgressKey({required String assetPath, String? lessonId}) {
  final sanitizedLessonId = lessonId?.trim();
  if (sanitizedLessonId != null && sanitizedLessonId.isNotEmpty) {
    return sanitizedLessonId;
  }

  return lessonProgressKeyFromAssetPath(assetPath);
}

String lessonProgressKeyFromStoredValue(String rawValue) {
  final sanitizedValue = rawValue.trim();
  if (sanitizedValue.isEmpty) {
    return '';
  }

  if (!_looksLikeLessonAssetPath(sanitizedValue)) {
    return sanitizedValue;
  }

  return lessonProgressKeyFromAssetPath(sanitizedValue);
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
