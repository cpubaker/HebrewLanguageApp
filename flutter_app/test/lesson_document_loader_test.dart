import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hebrew_language_flutter/services/lesson_document_loader.dart';

void main() {
  test(
    'extracts summary, headings, and glossary from lesson markdown',
    () async {
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
      expect(document.body.contains('## Пов’язані теми'), isFalse);
      expect(document.body.contains('- Інша тема'), isFalse);
      expect(document.glossary, <String, String>{
        'יוסי': 'Йосі',
        'קם': 'встає',
      });
    },
  );

  test('loads an English lesson when a localized asset is available', () async {
    final baseLoader = AssetLessonDocumentLoader(
      assetBundle: _MapAssetBundle(<String, String>{
        'assets/learning/input/guide/01_intro.md': '# Український урок',
        'assets/learning/localized/en/guide/01_intro.md': '''
# English lesson

In brief: A short English summary.

## Main model

- אִמָּא - ima - mother

## Related topics

- Another topic
''',
      }),
    );
    final loader = LocalizedLessonDocumentLoader(
      delegate: baseLoader,
      languageCode: 'en',
    );

    final document = await loader.load(
      'assets/learning/input/guide/01_intro.md',
    );

    expect(document.title, 'English lesson');
    expect(document.summary, 'A short English summary.');
    expect(document.headings, ['Main model']);
    expect(document.relatedTopics, ['Another topic']);
    expect(document.glossary, <String, String>{'אִמָּא': 'ima - mother'});
  });

  test('loads an English reading when a localized asset is available', () async {
    final baseLoader = AssetLessonDocumentLoader(
      assetBundle: _MapAssetBundle(<String, String>{
        'assets/learning/input/reading/beginner/01_lesson.md':
            '# Український текст',
        'assets/learning/localized/en/reading/beginner/01_lesson.md':
            '# English reading',
      }),
    );
    final loader = LocalizedLessonDocumentLoader(
      delegate: baseLoader,
      languageCode: 'en',
    );

    final document = await loader.load(
      'assets/learning/input/reading/beginner/01_lesson.md',
    );

    expect(document.title, 'English reading');
  });

  test(
    'falls back to the canonical lesson when no translation exists',
    () async {
      final baseLoader = AssetLessonDocumentLoader(
        assetBundle: _MapAssetBundle(<String, String>{
          'assets/learning/input/guide/04_lesson.md': '# Український урок',
        }),
      );
      final loader = LocalizedLessonDocumentLoader(
        delegate: baseLoader,
        languageCode: 'en',
      );

      final document = await loader.load(
        'assets/learning/input/guide/04_lesson.md',
      );

      expect(document.title, 'Український урок');
    },
  );
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

class _MapAssetBundle extends CachingAssetBundle {
  _MapAssetBundle(this.contents);

  final Map<String, String> contents;

  @override
  Future<String> loadString(String key, {bool cache = true}) async {
    final content = contents[key];
    if (content == null) {
      throw FlutterError('Missing asset: $key');
    }
    return content;
  }

  @override
  Future<ByteData> load(String key) {
    throw UnimplementedError();
  }
}
