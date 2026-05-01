import 'package:flutter_test/flutter_test.dart';
import 'package:hebrew_language_flutter/models/learning_bundle.dart';
import 'package:hebrew_language_flutter/models/learning_context.dart';
import 'package:hebrew_language_flutter/models/learning_word.dart';
import 'package:hebrew_language_flutter/services/ai_learning_helpers.dart';
import 'package:hebrew_language_flutter/services/flashcard_session.dart';

void main() {
  test('restores enabled feature only when store and access both allow it', () {
    expect(
      shouldRestoreEnabledFeature(storedEnabled: true, featureEnabled: true),
      isTrue,
    );
    expect(
      shouldRestoreEnabledFeature(storedEnabled: true, featureEnabled: false),
      isFalse,
    );
    expect(
      shouldRestoreEnabledFeature(storedEnabled: false, featureEnabled: true),
      isFalse,
    );
  });

  test('loads AI word contexts only when enabled, accessible, and scoped', () {
    expect(
      shouldLoadAiWordContexts(
        aiWordContextsEnabled: true,
        featureEnabled: true,
        scopeWords: const <LearningWord>[_knownWord],
      ),
      isTrue,
    );
    expect(
      shouldLoadAiWordContexts(
        aiWordContextsEnabled: false,
        featureEnabled: true,
        scopeWords: const <LearningWord>[_knownWord],
      ),
      isFalse,
    );
    expect(
      shouldLoadAiWordContexts(
        aiWordContextsEnabled: true,
        featureEnabled: false,
        scopeWords: const <LearningWord>[_knownWord],
      ),
      isFalse,
    );
    expect(
      shouldLoadAiWordContexts(
        aiWordContextsEnabled: true,
        featureEnabled: true,
        scopeWords: const <LearningWord>[],
      ),
      isFalse,
    );
  });

  test(
    'merges generated contexts before current contexts and skips duplicates',
    () {
      const current = LearningContext(
        contextId: 'ctx_existing',
        hebrew: 'שלום',
        translation: 'hello',
      );
      const duplicate = LearningContext(
        contextId: 'ctx_existing',
        hebrew: 'שלום!',
        translation: 'hello!',
        source: LearningContextSource.aiGenerated,
      );
      const generated = LearningContext(
        contextId: 'ctx_generated',
        hebrew: 'שלום בבית',
        translation: 'hello at home',
        source: LearningContextSource.aiGenerated,
      );

      final merged = mergeWordContexts(
        const <LearningContext>[current],
        const <LearningContext>[duplicate, generated],
      );

      expect(merged, const <LearningContext>[generated, current]);
    },
  );

  test('merges generated contexts into matching bundle words only', () {
    const generated = LearningContext(
      contextId: 'ctx_generated',
      hebrew: 'שלום בבית',
      translation: 'hello at home',
      source: LearningContextSource.aiGenerated,
    );
    const bundle = LearningBundle(
      words: <LearningWord>[_knownWord, _newWord],
      guideLessons: <LessonEntry>[],
      verbLessons: <LessonEntry>[],
      readingLessons: <LessonEntry>[],
    );

    final updated = mergeGeneratedContexts(bundle, const {
      'word_known': <LearningContext>[generated],
    });

    expect(updated.words.first.contexts, const <LearningContext>[generated]);
    expect(updated.words.last, same(_newWord));
  });

  test('AI context scope excludes AI-generated context words', () {
    const aiContextWord = LearningWord(
      wordId: 'word_ai_context',
      hebrew: 'עיר',
      english: 'city',
      transcription: 'ir',
      correct: 0,
      wrong: 1,
      contexts: <LearningContext>[
        LearningContext(
          contextId: 'ctx_ai',
          hebrew: 'עיר גדולה',
          translation: 'big city',
          source: LearningContextSource.aiGenerated,
        ),
      ],
    );
    const bundle = LearningBundle(
      words: <LearningWord>[_knownWord, _reviewWord, aiContextWord],
      guideLessons: <LessonEntry>[],
      verbLessons: <LessonEntry>[],
      readingLessons: <LessonEntry>[],
    );

    expect(
      aiContextScopeWords(bundle, FlashcardDeckMode.needsReview),
      const <LearningWord>[_reviewWord],
    );
  });

  test('AI practice text scope prefers review words, then new words', () {
    expect(
      aiPracticeTextScopeWords(const <LearningWord>[
        _knownWord,
        _newWord,
        _reviewWord,
      ], limit: 2),
      const <LearningWord>[_reviewWord],
    );
    expect(
      aiPracticeTextScopeWords(const <LearningWord>[_knownWord, _newWord]),
      const <LearningWord>[_newWord],
    );
    expect(
      aiPracticeTextScopeWords(const <LearningWord>[_knownWord], limit: 1),
      const <LearningWord>[_knownWord],
    );
  });
}

const _knownWord = LearningWord(
  wordId: 'word_known',
  hebrew: 'שלום',
  english: 'hello',
  transcription: 'shalom',
  correct: 2,
  wrong: 0,
);

const _newWord = LearningWord(
  wordId: 'word_new',
  hebrew: 'בית',
  english: 'house',
  transcription: 'bayit',
  correct: 0,
  wrong: 0,
);

const _reviewWord = LearningWord(
  wordId: 'word_review',
  hebrew: 'מים',
  english: 'water',
  transcription: 'mayim',
  correct: 0,
  wrong: 1,
);
