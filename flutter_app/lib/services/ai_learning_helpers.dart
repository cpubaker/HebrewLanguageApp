import '../models/learning_bundle.dart';
import '../models/learning_context.dart';
import '../models/learning_word.dart';
import 'flashcard_session.dart';
import 'progress_snapshot.dart';

bool shouldRestoreEnabledFeature({
  required bool storedEnabled,
  required bool featureEnabled,
}) {
  return storedEnabled && featureEnabled;
}

bool shouldLoadAiWordContexts({
  required bool aiWordContextsEnabled,
  required bool featureEnabled,
  required Iterable<LearningWord> scopeWords,
}) {
  return aiWordContextsEnabled && featureEnabled && scopeWords.isNotEmpty;
}

LearningBundle mergeGeneratedContexts(
  LearningBundle bundle,
  Map<String, List<LearningContext>> contextsByWordId,
) {
  return bundle.copyWith(
    words: bundle.words
        .map((word) {
          final generatedContexts = contextsByWordId[word.wordId];
          if (generatedContexts == null || generatedContexts.isEmpty) {
            return word;
          }

          return word.copyWith(
            contexts: mergeWordContexts(word.contexts, generatedContexts),
          );
        })
        .toList(growable: false),
  );
}

List<LearningContext> mergeWordContexts(
  List<LearningContext> currentContexts,
  List<LearningContext> generatedContexts,
) {
  final seenContextIds = currentContexts
      .map((context) => context.contextId)
      .where((contextId) => contextId.trim().isNotEmpty)
      .toSet();
  final uniqueGeneratedContexts = generatedContexts
      .where((context) => seenContextIds.add(context.contextId))
      .toList(growable: false);

  if (uniqueGeneratedContexts.isEmpty) {
    return currentContexts;
  }

  return <LearningContext>[...uniqueGeneratedContexts, ...currentContexts];
}

List<LearningWord> aiContextScopeWords(
  LearningBundle bundle,
  FlashcardDeckMode mode,
) {
  final words = switch (mode) {
    FlashcardDeckMode.allWords => bundle.words,
    FlashcardDeckMode.withContexts => bundle.words,
    FlashcardDeckMode.needsReview =>
      bundle.words
          .where(
            (word) =>
                classifyWordLearningState(word) ==
                WordLearningState.needsReview,
          )
          .toList(growable: false),
  };

  return words
      .where((word) => word.contexts.every((context) => !context.isAiGenerated))
      .toList(growable: false);
}

List<LearningWord> aiPracticeTextScopeWords(
  List<LearningWord> words, {
  int limit = 12,
}) {
  if (words.isEmpty || limit <= 0) {
    return const <LearningWord>[];
  }

  final reviewWords = words
      .where(
        (word) =>
            classifyWordLearningState(word) == WordLearningState.needsReview,
      )
      .toList(growable: false);
  if (reviewWords.isNotEmpty) {
    return reviewWords.take(limit).toList(growable: false);
  }

  final newWords = words
      .where(
        (word) => classifyWordLearningState(word) == WordLearningState.unseen,
      )
      .toList(growable: false);
  if (newWords.isNotEmpty) {
    return newWords.take(limit).toList(growable: false);
  }

  return words.take(limit).toList(growable: false);
}
