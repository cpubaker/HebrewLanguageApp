import '../models/learning_bundle.dart';
import '../models/learning_word.dart';

class LearningBundleWordUpdate {
  const LearningBundleWordUpdate({
    required this.bundle,
    required this.previousWord,
    required this.didUpdate,
  });

  final LearningBundle bundle;
  final LearningWord? previousWord;
  final bool didUpdate;
}

LearningBundleWordUpdate applyWordUpdate(
  LearningBundle bundle,
  LearningWord updatedWord,
) {
  final wordIndex = bundle.words.indexWhere(
    (word) => word.wordId == updatedWord.wordId,
  );
  if (wordIndex < 0) {
    return LearningBundleWordUpdate(
      bundle: bundle,
      previousWord: null,
      didUpdate: false,
    );
  }

  final updatedWords = List<LearningWord>.from(bundle.words);
  final previousWord = updatedWords[wordIndex];
  updatedWords[wordIndex] = updatedWord;

  return LearningBundleWordUpdate(
    bundle: bundle.copyWith(words: updatedWords),
    previousWord: previousWord,
    didUpdate: true,
  );
}

LearningBundle restoreWordUpdate(
  LearningBundle bundle,
  LearningWord previousWord,
) {
  final wordIndex = bundle.words.indexWhere(
    (word) => word.wordId == previousWord.wordId,
  );
  if (wordIndex < 0) {
    return bundle;
  }

  final restoredWords = List<LearningWord>.from(bundle.words);
  restoredWords[wordIndex] = previousWord;
  return bundle.copyWith(words: restoredWords);
}
