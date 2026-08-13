import '../models/learning_word.dart';
import 'progress_snapshot.dart';

enum WordsFilter { all, newWords, learned, review }

class IndexedWord {
  const IndexedWord({
    required this.word,
    required this.sortKey,
    required this.searchText,
  });

  factory IndexedWord.fromWord(LearningWord word) {
    final normalizedTranslation = word.translation.trim().toLowerCase();
    final normalizedEnglish = word.english.trim().toLowerCase();
    final normalizedTranscription = word.transcription.trim().toLowerCase();
    final normalizedHebrew = word.hebrew.trim();
    final normalizedWordId = word.wordId.trim().toLowerCase();
    final strippedHebrew = stripHebrewDiacritics(normalizedHebrew);

    return IndexedWord(
      word: word,
      sortKey: normalizedTranslation,
      searchText: [
        normalizedTranslation,
        normalizedEnglish,
        normalizedTranscription,
        normalizedHebrew,
        strippedHebrew,
        normalizedWordId,
      ].where((part) => part.isNotEmpty).join('\n'),
    );
  }

  final LearningWord word;
  final String sortKey;
  final String searchText;
}

List<IndexedWord> buildWordSearchIndex(Iterable<LearningWord> words) {
  return words.map(IndexedWord.fromWord).toList(growable: false)
    ..sort((left, right) => left.sortKey.compareTo(right.sortKey));
}

List<IndexedWord> filterIndexedWords(
  Iterable<IndexedWord> indexedWords,
  String query,
  WordsFilter filter,
) {
  final normalizedQuery = query.trim().toLowerCase();
  return indexedWords
      .where((word) => matchesWordsFilter(word.word, filter))
      .where(
        (word) =>
            normalizedQuery.isEmpty ||
            word.searchText.contains(normalizedQuery),
      )
      .toList(growable: false);
}

bool matchesWordsFilter(LearningWord word, WordsFilter filter) {
  final learningState = classifyWordLearningState(word);

  switch (filter) {
    case WordsFilter.all:
      return true;
    case WordsFilter.newWords:
      return learningState == WordLearningState.unseen;
    case WordsFilter.learned:
      return learningState == WordLearningState.known;
    case WordsFilter.review:
      return learningState == WordLearningState.needsReview;
  }
}

String stripHebrewDiacritics(String value) {
  return value.replaceAll(_hebrewDiacritics, '');
}

final RegExp _hebrewDiacritics = RegExp(r'[\u0591-\u05C7]');
