import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hebrew_language_flutter/services/learning_bundle_loader.dart';

void main() {
  test('summary load keeps full context sentences lazy', () async {
    final assetBundle = _FakeAssetBundle(
      strings: <String, String>{
        'assets/learning/input/hebrew_words.json': jsonEncode(<Object?>[
          <String, Object?>{
            'word_id': 'word_man',
            'hebrew': 'ish',
            'english': 'man',
            'transcription': 'ish',
            'correct': 0,
            'wrong': 0,
          },
        ]),
        'assets/learning/input/contexts/word_context_links.json': jsonEncode(
          <String, Object?>{
            'word_man': <String>['ctx_man_01'],
          },
        ),
        'assets/learning/input/guide_metadata.json': jsonEncode(
          <String, Object?>{
            'sections': <String, Object?>{},
            'lessons': <String, Object?>{},
          },
        ),
        'assets/learning/input/lesson_catalog.json': jsonEncode(
          <String, Object?>{
            'guide': <String>['01_intro.md'],
            'verbs': <String>[],
            'reading': <String>[],
          },
        ),
        'assets/learning/input/contexts/sentences.json': jsonEncode(<Object?>[
          <String, Object?>{
            'id': 'ctx_man_01',
            'hebrew': 'ish holech',
            'translation': 'A man walks',
          },
        ]),
      },
    );
    final loader = AssetLearningBundleLoader(assetBundle: assetBundle);

    final summaryBundle = await loader.loadSummary();

    expect(summaryBundle.hasFullWordContexts, isFalse);
    expect(summaryBundle.words.single.contexts.single.contextId, 'ctx_man_01');
    expect(summaryBundle.words.single.contexts.single.hebrew, isEmpty);
    expect(
      assetBundle.loadedStringKeys,
      isNot(contains('assets/learning/input/contexts/sentences.json')),
    );

    final fullBundle = await loader.loadWithFullWordContexts();

    expect(fullBundle.hasFullWordContexts, isTrue);
    expect(fullBundle.words.single.contexts.single.hebrew, 'ish holech');
    expect(
      assetBundle.loadedStringKeys,
      contains('assets/learning/input/contexts/sentences.json'),
    );
  });
}

class _FakeAssetBundle extends CachingAssetBundle {
  _FakeAssetBundle({required this.strings});

  final Map<String, String> strings;
  final List<String> loadedStringKeys = <String>[];

  @override
  Future<String> loadString(String key, {bool cache = true}) async {
    loadedStringKeys.add(key);
    final value = strings[key];
    if (value == null) {
      throw StateError('Missing fake asset: $key');
    }

    return value;
  }

  @override
  Future<ByteData> load(String key) {
    throw UnimplementedError('Binary assets are not used in this test.');
  }
}
