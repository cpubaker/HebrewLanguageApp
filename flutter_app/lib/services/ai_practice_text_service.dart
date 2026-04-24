import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/generated_practice_text.dart';
import '../models/learning_word.dart';
import 'ai_context_transport.dart';

class AiPracticeTextRequest {
  const AiPracticeTextRequest({
    required this.words,
    this.level = 'adaptive',
    this.mode = 'reading_practice',
    this.maxTexts = 1,
  });

  final List<LearningWord> words;
  final String level;
  final String mode;
  final int maxTexts;

  String get cacheKey {
    final wordIds =
        words
            .map((word) => word.wordId.trim())
            .where((wordId) => wordId.isNotEmpty)
            .toList(growable: false)
          ..sort();
    return '$mode|$level|${wordIds.join(',')}|$maxTexts';
  }
}

abstract interface class AiPracticeTextService {
  Future<List<GeneratedPracticeText>> textsForRequest(
    AiPracticeTextRequest request,
  );
}

class NoopAiPracticeTextService implements AiPracticeTextService {
  const NoopAiPracticeTextService();

  @override
  Future<List<GeneratedPracticeText>> textsForRequest(
    AiPracticeTextRequest request,
  ) async {
    return const <GeneratedPracticeText>[];
  }
}

class CachedAiPracticeTextService implements AiPracticeTextService {
  const CachedAiPracticeTextService({
    required this.cacheStore,
    required this.backendClient,
  });

  final AiPracticeTextCacheStore cacheStore;
  final AiPracticeTextBackendClient backendClient;

  @override
  Future<List<GeneratedPracticeText>> textsForRequest(
    AiPracticeTextRequest request,
  ) async {
    if (request.words.isEmpty) {
      return const <GeneratedPracticeText>[];
    }

    final cache = await cacheStore.load();
    final cachedTexts = cache[request.cacheKey];
    if (cachedTexts != null && cachedTexts.isNotEmpty) {
      return cachedTexts;
    }

    final generatedTexts = await backendClient.generateTexts(request);
    if (generatedTexts.isEmpty) {
      return const <GeneratedPracticeText>[];
    }

    await cacheStore.save(<String, List<GeneratedPracticeText>>{
      ...cache,
      request.cacheKey: generatedTexts,
    });
    return generatedTexts;
  }
}

abstract interface class AiPracticeTextCacheStore {
  Future<Map<String, List<GeneratedPracticeText>>> load();

  Future<void> save(Map<String, List<GeneratedPracticeText>> textsByRequestKey);
}

class SharedPreferencesAiPracticeTextCacheStore
    implements AiPracticeTextCacheStore {
  const SharedPreferencesAiPracticeTextCacheStore({
    this.cacheKey = 'ai_practice_texts_cache_v1',
  });

  final String cacheKey;

  @override
  Future<Map<String, List<GeneratedPracticeText>>> load() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(cacheKey);
    if (raw == null || raw.trim().isEmpty) {
      return const <String, List<GeneratedPracticeText>>{};
    }

    try {
      final decoded = jsonDecode(raw) as Map<String, dynamic>;
      return decoded.map(
        (requestKey, value) => MapEntry(
          requestKey,
          (value as List<dynamic>? ?? const <dynamic>[])
              .whereType<Map<String, dynamic>>()
              .map(GeneratedPracticeText.fromJson)
              .where(_isUsableText)
              .toList(growable: false),
        ),
      );
    } on Object catch (error) {
      debugPrint('Failed to load AI practice text cache: $error');
      return const <String, List<GeneratedPracticeText>>{};
    }
  }

  @override
  Future<void> save(
    Map<String, List<GeneratedPracticeText>> textsByRequestKey,
  ) async {
    final prefs = await SharedPreferences.getInstance();
    final encoded = jsonEncode(
      textsByRequestKey.map(
        (requestKey, texts) => MapEntry(
          requestKey,
          texts
              .where(_isUsableText)
              .map((text) => text.toJson())
              .toList(growable: false),
        ),
      ),
    );
    await prefs.setString(cacheKey, encoded);
  }
}

abstract interface class AiPracticeTextBackendClient {
  Future<List<GeneratedPracticeText>> generateTexts(
    AiPracticeTextRequest request,
  );
}

class NoopAiPracticeTextBackendClient implements AiPracticeTextBackendClient {
  const NoopAiPracticeTextBackendClient();

  @override
  Future<List<GeneratedPracticeText>> generateTexts(
    AiPracticeTextRequest request,
  ) async {
    return const <GeneratedPracticeText>[];
  }
}

class EndpointAiPracticeTextBackendClient
    implements AiPracticeTextBackendClient {
  const EndpointAiPracticeTextBackendClient({
    required this.endpoint,
    this.transport = const AiContextTransport(),
    this.timeout = const Duration(seconds: 25),
    this.promptVersion = 'practice-texts-v1',
  });

  final Uri endpoint;
  final AiContextTransport transport;
  final Duration timeout;
  final String promptVersion;

  @override
  Future<List<GeneratedPracticeText>> generateTexts(
    AiPracticeTextRequest request,
  ) async {
    if (request.words.isEmpty) {
      return const <GeneratedPracticeText>[];
    }

    final payload = <String, dynamic>{
      'prompt_version': promptVersion,
      'target_language': 'uk',
      'level': request.level,
      'mode': request.mode,
      'max_texts': request.maxTexts,
      'words': request.words
          .map((word) {
            return <String, dynamic>{
              'word_id': word.wordId,
              'hebrew': word.hebrew,
              'transcription': word.transcription,
              'translation': word.translation,
              'english': word.english,
            };
          })
          .toList(growable: false),
    };

    final responseBody = await transport.postJson(
      uri: endpoint,
      headers: const <String, String>{'Accept': 'application/json'},
      body: jsonEncode(payload),
      timeout: timeout,
    );

    return _parseResponse(responseBody, request);
  }

  List<GeneratedPracticeText> _parseResponse(
    String responseBody,
    AiPracticeTextRequest request,
  ) {
    final decoded = jsonDecode(responseBody) as Map<String, dynamic>;
    final rawTexts = decoded['texts'] as List<dynamic>? ?? const <dynamic>[];
    final model = decoded['model'] as String?;
    final createdAt = DateTime.now().toUtc().toIso8601String();
    final requestedWordIds = request.words.map((word) => word.wordId).toSet();
    final texts = <GeneratedPracticeText>[];

    for (var index = 0; index < rawTexts.length; index += 1) {
      final rawText = rawTexts[index];
      if (rawText is! Map<String, dynamic>) {
        continue;
      }

      final text = GeneratedPracticeText(
        textId:
            rawText['id'] as String? ??
            'ai_text_${createdAt}_${request.cacheKey.hashCode}_$index',
        title: rawText['title'] as String? ?? '',
        hebrew: rawText['hebrew'] as String? ?? '',
        translation:
            rawText['ukrainian'] as String? ??
            rawText['translation'] as String? ??
            '',
        wordIds: (rawText['word_ids'] as List<dynamic>? ?? const <dynamic>[])
            .whereType<String>()
            .where(requestedWordIds.contains)
            .toList(growable: false),
        isNew: true,
        createdAt: createdAt,
        model: rawText['model'] as String? ?? model,
        promptVersion: rawText['prompt_version'] as String? ?? promptVersion,
      );
      if (_isUsableText(text)) {
        texts.add(text);
      }
    }

    return texts;
  }
}

AiPracticeTextService createDefaultAiPracticeTextService() {
  const endpointValue = String.fromEnvironment('AI_PRACTICE_TEXTS_ENDPOINT');
  final endpoint = Uri.tryParse(endpointValue);
  if (endpoint == null || !endpoint.hasScheme || !endpoint.hasAuthority) {
    return const CachedAiPracticeTextService(
      cacheStore: SharedPreferencesAiPracticeTextCacheStore(),
      backendClient: NoopAiPracticeTextBackendClient(),
    );
  }

  return CachedAiPracticeTextService(
    cacheStore: const SharedPreferencesAiPracticeTextCacheStore(),
    backendClient: EndpointAiPracticeTextBackendClient(endpoint: endpoint),
  );
}

bool _isUsableText(GeneratedPracticeText text) {
  return text.textId.trim().isNotEmpty &&
      text.hebrew.trim().isNotEmpty &&
      text.translation.trim().isNotEmpty;
}
