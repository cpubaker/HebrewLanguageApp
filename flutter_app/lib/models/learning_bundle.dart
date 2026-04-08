import 'learning_word.dart';

class LessonEntry {
  const LessonEntry({
    required this.assetPath,
    required this.displayName,
    this.lessonId,
    this.sectionId,
    this.sectionLabel,
    this.aliases = const <String>[],
    this.relatedIds = const <String>[],
  });

  final String assetPath;
  final String displayName;
  final String? lessonId;
  final String? sectionId;
  final String? sectionLabel;
  final List<String> aliases;
  final List<String> relatedIds;
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
