import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hebrew_language_flutter/services/lesson_document_loader.dart';

void main() {
  test('extracts glossary entries from lesson markdown bullets', () async {
    final loader = AssetLessonDocumentLoader(
      assetBundle: _FakeAssetBundle('''
# Lesson Title

יוֹסִי קָם בַּבֹּקֶר.

## Основні слова

- יוֹסִי - Йосі
- קָם - встає
- not-a-glossary item
'''),
    );

    final document = await loader.load('assets/lesson.md');

    expect(document.title, 'Lesson Title');
    expect(document.glossary, <String, String>{
      'יוֹסִי': 'Йосі',
      'קָם': 'встає',
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
