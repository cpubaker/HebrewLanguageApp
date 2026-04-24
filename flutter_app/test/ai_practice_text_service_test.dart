import 'package:flutter_test/flutter_test.dart';
import 'package:hebrew_language_flutter/models/generated_practice_text.dart';
import 'package:hebrew_language_flutter/models/learning_word.dart';
import 'package:hebrew_language_flutter/services/ai_practice_text_service.dart';

void main() {
  test('cached service returns cached texts without backend calls', () async {
    const word = LearningWord(
      wordId: 'word_book',
      hebrew: 'ספר',
      english: 'book',
      transcription: 'sefer',
      correct: 0,
      wrong: 0,
    );
    final request = AiPracticeTextRequest(words: const <LearningWord>[word]);
    final store = _MemoryAiPracticeTextCacheStore(
      <String, List<GeneratedPracticeText>>{
        request.cacheKey: const <GeneratedPracticeText>[
          GeneratedPracticeText(
            textId: 'ai_text_1',
            title: 'ספר חדש',
            hebrew: 'אני קורא ספר חדש.',
            translation: 'Я читаю нову книгу.',
            wordIds: <String>['word_book'],
          ),
        ],
      },
    );
    final backend = _FakeAiPracticeTextBackendClient();
    final service = CachedAiPracticeTextService(
      cacheStore: store,
      backendClient: backend,
    );

    final texts = await service.textsForRequest(request);

    expect(texts.single.textId, 'ai_text_1');
    expect(backend.requestedRequests, isEmpty);
  });

  test('cached service stores generated texts for missing requests', () async {
    const word = LearningWord(
      wordId: 'word_house',
      hebrew: 'בית',
      english: 'house',
      transcription: 'bayit',
      correct: 0,
      wrong: 0,
    );
    final request = AiPracticeTextRequest(words: const <LearningWord>[word]);
    final store = _MemoryAiPracticeTextCacheStore();
    final backend = _FakeAiPracticeTextBackendClient(
      generated: const <GeneratedPracticeText>[
        GeneratedPracticeText(
          textId: 'ai_text_house',
          title: 'בית קרוב',
          hebrew: 'הבית קרוב לבית הספר.',
          translation: 'Будинок близько до школи.',
          wordIds: <String>['word_house'],
        ),
      ],
    );
    final service = CachedAiPracticeTextService(
      cacheStore: store,
      backendClient: backend,
    );

    final texts = await service.textsForRequest(request);

    expect(texts.single.textId, 'ai_text_house');
    expect(store.savedTexts[request.cacheKey]?.single.textId, 'ai_text_house');
    expect(backend.requestedRequests.single.cacheKey, request.cacheKey);
  });
}

class _MemoryAiPracticeTextCacheStore implements AiPracticeTextCacheStore {
  _MemoryAiPracticeTextCacheStore([
    Map<String, List<GeneratedPracticeText>> initialTexts =
        const <String, List<GeneratedPracticeText>>{},
  ]) : savedTexts = Map<String, List<GeneratedPracticeText>>.from(initialTexts);

  Map<String, List<GeneratedPracticeText>> savedTexts;

  @override
  Future<Map<String, List<GeneratedPracticeText>>> load() async {
    return Map<String, List<GeneratedPracticeText>>.from(savedTexts);
  }

  @override
  Future<void> save(
    Map<String, List<GeneratedPracticeText>> textsByRequestKey,
  ) async {
    savedTexts = Map<String, List<GeneratedPracticeText>>.from(
      textsByRequestKey,
    );
  }
}

class _FakeAiPracticeTextBackendClient implements AiPracticeTextBackendClient {
  _FakeAiPracticeTextBackendClient({
    this.generated = const <GeneratedPracticeText>[],
  });

  final List<GeneratedPracticeText> generated;
  final List<AiPracticeTextRequest> requestedRequests =
      <AiPracticeTextRequest>[];

  @override
  Future<List<GeneratedPracticeText>> generateTexts(
    AiPracticeTextRequest request,
  ) async {
    requestedRequests.add(request);
    return generated;
  }
}
