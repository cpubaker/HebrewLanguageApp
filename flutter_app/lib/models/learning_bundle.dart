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

  LearningBundle copyWith({
    List<LearningWord>? words,
    List<LessonEntry>? guideLessons,
    List<LessonEntry>? verbLessons,
    List<LessonEntry>? readingLessons,
  }) {
    return LearningBundle(
      words: words ?? this.words,
      guideLessons: guideLessons ?? this.guideLessons,
      verbLessons: verbLessons ?? this.verbLessons,
      readingLessons: readingLessons ?? this.readingLessons,
    );
  }
}
