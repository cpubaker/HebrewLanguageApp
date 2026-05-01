import 'package:flutter_test/flutter_test.dart';
import 'package:hebrew_language_flutter/models/learning_bundle.dart';
import 'package:hebrew_language_flutter/models/learning_word.dart';
import 'package:hebrew_language_flutter/services/learning_bundle_word_updates.dart';

void main() {
  test('applies a word update without mutating the original bundle', () {
    const originalWord = LearningWord(
      wordId: 'word_shalom',
      hebrew: 'שלום',
      english: 'hello',
      transcription: 'shalom',
      correct: 1,
      wrong: 0,
    );
    const otherWord = LearningWord(
      wordId: 'word_bayit',
      hebrew: 'בית',
      english: 'house',
      transcription: 'bayit',
      correct: 0,
      wrong: 0,
    );
    const updatedWord = LearningWord(
      wordId: 'word_shalom',
      hebrew: 'שלום',
      english: 'hello',
      transcription: 'shalom',
      correct: 2,
      wrong: 0,
    );
    const bundle = LearningBundle(
      words: <LearningWord>[originalWord, otherWord],
      guideLessons: <LessonEntry>[],
      verbLessons: <LessonEntry>[],
      readingLessons: <LessonEntry>[],
    );

    final update = applyWordUpdate(bundle, updatedWord);

    expect(update.didUpdate, isTrue);
    expect(update.previousWord, originalWord);
    expect(update.bundle.words, <LearningWord>[updatedWord, otherWord]);
    expect(bundle.words, <LearningWord>[originalWord, otherWord]);
  });

  test('returns unchanged bundle when updated word is missing', () {
    const originalWord = LearningWord(
      wordId: 'word_shalom',
      hebrew: 'שלום',
      english: 'hello',
      transcription: 'shalom',
      correct: 1,
      wrong: 0,
    );
    const missingWord = LearningWord(
      wordId: 'word_missing',
      hebrew: 'חסר',
      english: 'missing',
      transcription: 'haser',
      correct: 1,
      wrong: 0,
    );
    const bundle = LearningBundle(
      words: <LearningWord>[originalWord],
      guideLessons: <LessonEntry>[],
      verbLessons: <LessonEntry>[],
      readingLessons: <LessonEntry>[],
    );

    final update = applyWordUpdate(bundle, missingWord);

    expect(update.didUpdate, isFalse);
    expect(update.previousWord, isNull);
    expect(update.bundle, same(bundle));
  });

  test(
    'restores a previous word update without mutating the active bundle',
    () {
      const previousWord = LearningWord(
        wordId: 'word_shalom',
        hebrew: 'שלום',
        english: 'hello',
        transcription: 'shalom',
        correct: 1,
        wrong: 0,
      );
      const activeWord = LearningWord(
        wordId: 'word_shalom',
        hebrew: 'שלום',
        english: 'hello',
        transcription: 'shalom',
        correct: 2,
        wrong: 0,
      );
      const activeBundle = LearningBundle(
        words: <LearningWord>[activeWord],
        guideLessons: <LessonEntry>[],
        verbLessons: <LessonEntry>[],
        readingLessons: <LessonEntry>[],
      );

      final restoredBundle = restoreWordUpdate(activeBundle, previousWord);

      expect(restoredBundle.words, <LearningWord>[previousWord]);
      expect(activeBundle.words, <LearningWord>[activeWord]);
    },
  );

  test('returns unchanged bundle when restored word is missing', () {
    const activeWord = LearningWord(
      wordId: 'word_shalom',
      hebrew: 'שלום',
      english: 'hello',
      transcription: 'shalom',
      correct: 2,
      wrong: 0,
    );
    const previousWord = LearningWord(
      wordId: 'word_missing',
      hebrew: 'חסר',
      english: 'missing',
      transcription: 'haser',
      correct: 1,
      wrong: 0,
    );
    const activeBundle = LearningBundle(
      words: <LearningWord>[activeWord],
      guideLessons: <LessonEntry>[],
      verbLessons: <LessonEntry>[],
      readingLessons: <LessonEntry>[],
    );

    final restoredBundle = restoreWordUpdate(activeBundle, previousWord);

    expect(restoredBundle, same(activeBundle));
  });
}
