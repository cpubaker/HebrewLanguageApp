import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hebrew_language_flutter/services/lesson_document_loader.dart';

void main() {
  test('extracts summary, headings, and glossary from lesson markdown', () async {
    final loader = AssetLessonDocumentLoader(
      assetBundle: _FakeAssetBundle('''
# Lesson Title

Коротко: Short summary for quick lookup.

## Main model

יוסי קם בבוקר.

## Основні слова

- יוסי - Йосі
- קם - встає
- not-a-glossary item

## Пов’язані теми

- Інша тема
'''),
    );

    final document = await loader.load('assets/lesson.md');

    expect(document.title, 'Lesson Title');
    expect(document.summary, 'Short summary for quick lookup.');
    expect(document.headings, ['Main model', 'Основні слова']);
    expect(document.relatedTopics, ['Інша тема']);
    expect(document.glossary, <String, String>{
      'יוסי': 'Йосі',
      'קם': 'встає',
    });
  });
}

class _FakeAssetBundle extends CachingAssetBundle {
  _FakeAssetBundle(this.content);

  final String content;

  @override
  Future<String> loadString(String key, {bool cache = true}) async => content;

  @override
  Future<ByteData> load(String key) {
    throw UnimplementedError();
  }
}
