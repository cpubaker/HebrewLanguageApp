import 'package:flutter_test/flutter_test.dart';
import 'package:hebrew_language_flutter/models/learning_word.dart';
import 'package:hebrew_language_flutter/services/word_list_filter.dart';

void main() {
  test('builds a translation-sorted search index', () {
    final index = buildWordSearchIndex(<LearningWord>[
      _word(wordId: 'dog', ukrainian: 'собака', english: 'dog'),
      _word(wordId: 'man', ukrainian: 'чоловік', english: 'man'),
      _word(wordId: 'home', ukrainian: 'дім', english: 'home'),
    ]);

    expect(index.map((entry) => entry.word.wordId), <String>[
      'home',
      'dog',
      'man',
    ]);
  });

  test('searches translation, English, transcription, Hebrew, and word id', () {
    final index = buildWordSearchIndex(<LearningWord>[
      _word(
        wordId: 'word_shalom',
        hebrew: 'שָׁלוֹם',
        english: 'peace',
        ukrainian: 'мир',
        transcription: 'shalom',
      ),
      _word(
        wordId: 'word_bayit',
        hebrew: 'בַּיִת',
        english: 'home',
        ukrainian: 'дім',
        transcription: 'bayit',
      ),
    ]);

    expect(_ids(filterIndexedWords(index, 'мир', WordsFilter.all)), [
      'word_shalom',
    ]);
    expect(_ids(filterIndexedWords(index, 'PEACE', WordsFilter.all)), [
      'word_shalom',
    ]);
    expect(_ids(filterIndexedWords(index, 'bayit', WordsFilter.all)), [
      'word_bayit',
    ]);
    expect(_ids(filterIndexedWords(index, 'שלום', WordsFilter.all)), [
      'word_shalom',
    ]);
    expect(_ids(filterIndexedWords(index, 'word_bayit', WordsFilter.all)), [
      'word_bayit',
    ]);
  });

  test('filters indexed words by learning state', () {
    final index = buildWordSearchIndex(<LearningWord>[
      _word(wordId: 'new_word', english: 'beta'),
      _word(
        wordId: 'known_word',
        english: 'alpha',
        correct: 1,
        lastReviewCorrect: true,
      ),
      _word(
        wordId: 'review_word',
        english: 'gamma',
        wrong: 1,
        lastReviewCorrect: false,
      ),
    ]);

    expect(_ids(filterIndexedWords(index, '', WordsFilter.all)), [
      'known_word',
      'new_word',
      'review_word',
    ]);
    expect(_ids(filterIndexedWords(index, '', WordsFilter.newWords)), [
      'new_word',
    ]);
    expect(_ids(filterIndexedWords(index, '', WordsFilter.learned)), [
      'known_word',
    ]);
    expect(_ids(filterIndexedWords(index, '', WordsFilter.review)), [
      'review_word',
    ]);
  });

  test('combines query and state filters', () {
    final index = buildWordSearchIndex(<LearningWord>[
      _word(wordId: 'known_home', english: 'home', correct: 1),
      _word(wordId: 'review_home', english: 'home', wrong: 1),
      _word(wordId: 'review_school', english: 'school', wrong: 1),
    ]);

    expect(_ids(filterIndexedWords(index, 'home', WordsFilter.review)), [
      'review_home',
    ]);
  });
}

LearningWord _word({
  required String wordId,
  String hebrew = '',
  String english = '',
  String ukrainian = '',
  String transcription = '',
  int correct = 0,
  int wrong = 0,
  bool? lastReviewCorrect,
}) {
  return LearningWord(
    wordId: wordId,
    hebrew: hebrew,
    english: english,
    ukrainian: ukrainian,
    transcription: transcription,
    correct: correct,
    wrong: wrong,
    lastReviewCorrect: lastReviewCorrect,
  );
}

List<String> _ids(List<IndexedWord> words) {
  return words.map((entry) => entry.word.wordId).toList(growable: false);
}
