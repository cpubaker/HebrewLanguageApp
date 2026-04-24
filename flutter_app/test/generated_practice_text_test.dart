import 'package:flutter_test/flutter_test.dart';
import 'package:hebrew_language_flutter/models/generated_practice_text.dart';

void main() {
  test('fromJson reads generated practice text metadata', () {
    final text = GeneratedPracticeText.fromJson(<String, Object?>{
      'id': 'ai_text_1',
      'title': 'יום לימודים',
      'hebrew': 'אני קורא ספר חדש.',
      'translation': 'Я читаю нову книгу.',
      'word_ids': <String>['word_book', 'word_new'],
      'is_new': true,
      'created_at': '2026-04-24T10:00:00Z',
      'model': 'gpt-5-nano',
      'prompt_version': 'practice-texts-v1',
    });

    expect(text.textId, 'ai_text_1');
    expect(text.wordIds, <String>['word_book', 'word_new']);
    expect(text.isNew, isTrue);
    expect(text.createdAt, '2026-04-24T10:00:00Z');
    expect(text.model, 'gpt-5-nano');
    expect(text.promptVersion, 'practice-texts-v1');
  });

  test('toJson preserves generated practice text metadata', () {
    const text = GeneratedPracticeText(
      textId: 'ai_text_1',
      title: 'יום לימודים',
      hebrew: 'אני קורא ספר חדש.',
      translation: 'Я читаю нову книгу.',
      wordIds: <String>['word_book', 'word_new'],
      isNew: true,
      createdAt: '2026-04-24T10:00:00Z',
      model: 'gpt-5-nano',
      promptVersion: 'practice-texts-v1',
    );

    expect(text.toJson(), <String, Object?>{
      'id': 'ai_text_1',
      'title': 'יום לימודים',
      'hebrew': 'אני קורא ספר חדש.',
      'translation': 'Я читаю нову книгу.',
      'word_ids': <String>['word_book', 'word_new'],
      'source': 'ai',
      'is_new': true,
      'created_at': '2026-04-24T10:00:00Z',
      'model': 'gpt-5-nano',
      'prompt_version': 'practice-texts-v1',
    });
  });
}
