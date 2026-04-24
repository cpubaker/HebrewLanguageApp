import 'package:flutter_test/flutter_test.dart';
import 'package:hebrew_language_flutter/models/learning_context.dart';

void main() {
  test('fromJson reads AI context metadata', () {
    final context = LearningContext.fromJson(<String, Object?>{
      'id': 'ai_word_1',
      'hebrew': 'אני לומד עברית.',
      'translation': 'Я вчу іврит.',
      'source': 'ai',
      'is_new': true,
      'created_at': '2026-04-24T10:00:00Z',
      'model': 'gpt-5-nano',
      'prompt_version': 'word-contexts-v1',
    });

    expect(context.contextId, 'ai_word_1');
    expect(context.isAiGenerated, isTrue);
    expect(context.isNew, isTrue);
    expect(context.createdAt, '2026-04-24T10:00:00Z');
    expect(context.model, 'gpt-5-nano');
    expect(context.promptVersion, 'word-contexts-v1');
  });

  test('toJson preserves AI context metadata', () {
    const context = LearningContext(
      contextId: 'ai_word_1',
      hebrew: 'אני לומד עברית.',
      translation: 'Я вчу іврит.',
      source: LearningContextSource.aiGenerated,
      isNew: true,
      createdAt: '2026-04-24T10:00:00Z',
      model: 'gpt-5-nano',
      promptVersion: 'word-contexts-v1',
    );

    expect(context.toJson(), <String, Object?>{
      'id': 'ai_word_1',
      'hebrew': 'אני לומד עברית.',
      'translation': 'Я вчу іврит.',
      'source': 'ai',
      'is_new': true,
      'created_at': '2026-04-24T10:00:00Z',
      'model': 'gpt-5-nano',
      'prompt_version': 'word-contexts-v1',
    });
  });
}
