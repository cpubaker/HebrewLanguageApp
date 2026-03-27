import 'learning_word.dart';

class LessonEntry {
  const LessonEntry({
    required this.assetPath,
    required this.displayName,
  });

  final String assetPath;
  final String displayName;
}

class LearningBundle {
  const LearningBundle({
    required this.words,
    required this.guideLessons,
    required this.verbLessons,
    required this.readingLessons,
  });

  final List<LearningWord> words;
  final List<LessonEntry> guideLessons;
  final List<LessonEntry> verbLessons;
  final List<LessonEntry> readingLessons;
}
