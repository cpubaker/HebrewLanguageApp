import 'package:flutter_test/flutter_test.dart';
import 'package:hebrew_language_flutter/models/learning_context.dart';
import 'package:hebrew_language_flutter/models/learning_word.dart';
import 'package:hebrew_language_flutter/services/ai_context_service.dart';

void main() {
  test(
    'cached service returns cached contexts without backend calls',
    () async {
      final store = _MemoryAiContextCacheStore(<String, List<LearningContext>>{
        'word_book': const <LearningContext>[
          LearningContext(
            contextId: 'ai_book_1',
            hebrew: 'יש ספר על השולחן.',
            translation: 'На столі є книга.',
            source: LearningContextSource.aiGenerated,
            isNew: true,
          ),
        ],
      });
      final backend = _FakeAiContextBackendClient();
      final service = CachedAiContextService(
        cacheStore: store,
        backendClient: backend,
      );

      final contexts = await service.contextsForWords(const <LearningWord>[
        LearningWord(
          wordId: 'word_book',
          hebrew: 'ספר',
          english: 'book',
          transcription: 'sefer',
          correct: 0,
          wrong: 0,
        ),
      ]);

      expect(contexts['word_book']?.single.contextId, 'ai_book_1');
      expect(backend.requestedBatches, isEmpty);
    },
  );

  test('cached service stores generated contexts for missing words', () async {
    final store = _MemoryAiContextCacheStore();
    final backend = _FakeAiContextBackendClient(
      generated: <String, List<LearningContext>>{
        'word_house': const <LearningContext>[
          LearningContext(
            contextId: 'ai_house_1',
            hebrew: 'הבית קרוב.',
            translation: 'Будинок близько.',
            source: LearningContextSource.aiGenerated,
            isNew: true,
          ),
        ],
      },
    );
    final service = CachedAiContextService(
      cacheStore: store,
      backendClient: backend,
    );

    final contexts = await service.contextsForWords(const <LearningWord>[
      LearningWord(
        wordId: 'word_house',
        hebrew: 'בית',
        english: 'house',
        transcription: 'bayit',
        correct: 0,
        wrong: 0,
      ),
    ]);

    expect(contexts['word_house']?.single.contextId, 'ai_house_1');
    expect(store.savedContexts['word_house']?.single.contextId, 'ai_house_1');
    expect(backend.requestedBatches.single.single.wordId, 'word_house');
  });
}

class _MemoryAiContextCacheStore implements AiContextCacheStore {
  _MemoryAiContextCacheStore([
    Map<String, List<LearningContext>> initialContexts =
        const <String, List<LearningContext>>{},
  ]) : savedContexts = Map<String, List<LearningContext>>.from(initialContexts);

  Map<String, List<LearningContext>> savedContexts;

  @override
  Future<Map<String, List<LearningContext>>> load() async {
    return Map<String, List<LearningContext>>.from(savedContexts);
  }

  @override
  Future<void> save(Map<String, List<LearningContext>> contextsByWordId) async {
    savedContexts = Map<String, List<LearningContext>>.from(contextsByWordId);
  }
}

class _FakeAiContextBackendClient implements AiContextBackendClient {
  _FakeAiContextBackendClient({
    this.generated = const <String, List<LearningContext>>{},
  });

  final Map<String, List<LearningContext>> generated;
  final List<List<LearningWord>> requestedBatches = <List<LearningWord>>[];

  @override
  Future<Map<String, List<LearningContext>>> generateContexts(
    List<LearningWord> words,
  ) async {
    requestedBatches.add(words);
    final requestedWordIds = words.map((word) => word.wordId).toSet();
    return <String, List<LearningContext>>{
      for (final entry in generated.entries)
        if (requestedWordIds.contains(entry.key)) entry.key: entry.value,
    };
  }
}
