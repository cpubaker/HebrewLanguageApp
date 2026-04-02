import '../models/learning_bundle.dart';

class ReadingLessonGroup {
  const ReadingLessonGroup({
    required this.levelKey,
    required this.levelLabel,
    required this.lessons,
  });

  final String levelKey;
  final String levelLabel;
  final List<LessonEntry> lessons;
}

const List<String> _readingLevelOrder = [
  'beginner',
  'pre-intermediate',
  'intermediate',
  'upper-intermediate',
  'advanced',
  'proficient',
];

String readingLevelKeyFromAssetPath(String assetPath) {
  final parts = assetPath.split('/');
  final readingIndex = parts.indexOf('reading');
  if (readingIndex == -1 || readingIndex + 1 >= parts.length) {
    return 'reading';
  }

  return parts[readingIndex + 1];
}

String readingLevelLabelFromAssetPath(String assetPath) {
  final rawLevel = readingLevelKeyFromAssetPath(assetPath);
  switch (rawLevel) {
    case 'beginner':
      return 'Початковий';
    case 'pre-intermediate':
      return 'Нижче середнього';
    case 'intermediate':
      return 'Середній';
    case 'upper-intermediate':
      return 'Вище середнього';
    case 'advanced':
      return 'Просунутий';
    case 'proficient':
      return 'Вільний';
    case 'reading':
      return 'Читання';
  }

  return rawLevel
      .split('-')
      .where((part) => part.isNotEmpty)
      .map((part) => '${part[0].toUpperCase()}${part.substring(1)}')
      .join(' ');
}

String readingLessonTitle(LessonEntry lesson) {
  return lesson.displayName.replaceFirst(RegExp(r'^\d+\s+'), '');
}

String readingLessonOrderLabel(LessonEntry lesson) {
  final orderMatch = RegExp(r'^(\d+)').firstMatch(lesson.displayName);
  return orderMatch?.group(1) ?? '*';
}

List<LessonEntry> sortReadingLessons(Iterable<LessonEntry> lessons) {
  final sortedLessons = lessons.toList(growable: false);
  sortedLessons.sort(_compareReadingLessons);
  return sortedLessons;
}

List<ReadingLessonGroup> buildReadingLessonGroups(
  Iterable<LessonEntry> lessons,
) {
  final groupedLessons = <String, List<LessonEntry>>{};

  for (final lesson in sortReadingLessons(lessons)) {
    final levelKey = readingLevelKeyFromAssetPath(lesson.assetPath);
    groupedLessons.putIfAbsent(levelKey, () => <LessonEntry>[]).add(lesson);
  }

  final orderedKeys = groupedLessons.keys.toList(growable: false)
    ..sort(_compareLevelKeys);

  return orderedKeys
      .map(
        (levelKey) => ReadingLessonGroup(
          levelKey: levelKey,
          levelLabel: readingLevelLabelFromAssetPath(
            groupedLessons[levelKey]!.first.assetPath,
          ),
          lessons: List<LessonEntry>.unmodifiable(groupedLessons[levelKey]!),
        ),
      )
      .toList(growable: false);
}

int _compareReadingLessons(LessonEntry left, LessonEntry right) {
  final levelComparison = _compareLevelKeys(
    readingLevelKeyFromAssetPath(left.assetPath),
    readingLevelKeyFromAssetPath(right.assetPath),
  );
  if (levelComparison != 0) {
    return levelComparison;
  }

  final leftOrder = int.tryParse(readingLessonOrderLabel(left));
  final rightOrder = int.tryParse(readingLessonOrderLabel(right));
  if (leftOrder != null && rightOrder != null) {
    final orderComparison = leftOrder.compareTo(rightOrder);
    if (orderComparison != 0) {
      return orderComparison;
    }
  }

  final titleComparison = readingLessonTitle(
    left,
  ).compareTo(readingLessonTitle(right));
  if (titleComparison != 0) {
    return titleComparison;
  }

  return left.assetPath.compareTo(right.assetPath);
}

int _compareLevelKeys(String left, String right) {
  final leftIndex = _readingLevelOrder.indexOf(left);
  final rightIndex = _readingLevelOrder.indexOf(right);

  if (leftIndex != -1 && rightIndex != -1) {
    return leftIndex.compareTo(rightIndex);
  }

  if (leftIndex != -1) {
    return -1;
  }

  if (rightIndex != -1) {
    return 1;
  }

  return left.compareTo(right);
}
