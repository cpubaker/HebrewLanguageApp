import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/learning_context.dart';
import '../models/learning_word.dart';
import 'ai_context_transport.dart';

abstract interface class AiContextService {
  Future<Map<String, List<LearningContext>>> contextsForWords(
    List<LearningWord> words,
  );
}

class NoopAiContextService implements AiContextService {
  const NoopAiContextService();

  @override
  Future<Map<String, List<LearningContext>>> contextsForWords(
    List<LearningWord> words,
  ) async {
    return const <String, List<LearningContext>>{};
  }
}

class CachedAiContextService implements AiContextService {
  const CachedAiContextService({
    required this.cacheStore,
    required this.backendClient,
    this.batchSize = 20,
  });

  final AiContextCacheStore cacheStore;
  final AiContextBackendClient backendClient;
  final int batchSize;

  @override
  Future<Map<String, List<LearningContext>>> contextsForWords(
    List<LearningWord> words,
  ) async {
    if (words.isEmpty) {
      return const <String, List<LearningContext>>{};
    }

    final cache = await cacheStore.load();
    final requestedWordIds = words.map((word) => word.wordId).toSet();
    final result = <String, List<LearningContext>>{
      for (final entry in cache.entries)
        if (requestedWordIds.contains(entry.key)) entry.key: entry.value,
    };

    final missingWords = words
        .where((word) => word.wordId.trim().isNotEmpty)
        .where(
          (word) => (cache[word.wordId] ?? const <LearningContext>[]).isEmpty,
        )
        .take(batchSize)
        .toList(growable: false);
    if (missingWords.isEmpty) {
      return result;
    }

    final generated = await backendClient.generateContexts(missingWords);
    if (generated.isEmpty) {
      return result;
    }

    final updatedCache = <String, List<LearningContext>>{
      ...cache,
      ...generated,
    };
    await cacheStore.save(updatedCache);
    result.addAll(generated);
    return result;
  }
}

abstract interface class AiContextCacheStore {
  Future<Map<String, List<LearningContext>>> load();

  Future<void> save(Map<String, List<LearningContext>> contextsByWordId);
}

class SharedPreferencesAiContextCacheStore implements AiContextCacheStore {
  const SharedPreferencesAiContextCacheStore({
    this.cacheKey = 'ai_word_contexts_cache_v1',
  });

  final String cacheKey;

  @override
  Future<Map<String, List<LearningContext>>> load() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(cacheKey);
    if (raw == null || raw.trim().isEmpty) {
      return const <String, List<LearningContext>>{};
    }

    try {
      final decoded = jsonDecode(raw) as Map<String, dynamic>;
      return decoded.map(
        (wordId, value) => MapEntry(
          wordId,
          (value as List<dynamic>? ?? const <dynamic>[])
              .whereType<Map<String, dynamic>>()
              .map(LearningContext.fromJson)
              .where(_isUsableContext)
              .toList(growable: false),
        ),
      );
    } on Object catch (error) {
      debugPrint('Failed to load AI context cache: $error');
      return const <String, List<LearningContext>>{};
    }
  }

  @override
  Future<void> save(Map<String, List<LearningContext>> contextsByWordId) async {
    final prefs = await SharedPreferences.getInstance();
    final encoded = jsonEncode(
      contextsByWordId.map(
        (wordId, contexts) => MapEntry(
          wordId,
          contexts
              .where(_isUsableContext)
              .map((context) {
                return context.toJson();
              })
              .toList(growable: false),
        ),
      ),
    );
    await prefs.setString(cacheKey, encoded);
  }
}

abstract interface class AiContextBackendClient {
  Future<Map<String, List<LearningContext>>> generateContexts(
    List<LearningWord> words,
  );
}

class NoopAiContextBackendClient implements AiContextBackendClient {
  const NoopAiContextBackendClient();

  @override
  Future<Map<String, List<LearningContext>>> generateContexts(
    List<LearningWord> words,
  ) async {
    return const <String, List<LearningContext>>{};
  }
}

class EndpointAiContextBackendClient implements AiContextBackendClient {
  const EndpointAiContextBackendClient({
    required this.endpoint,
    this.transport = const AiContextTransport(),
    this.timeout = const Duration(seconds: 20),
    this.promptVersion = 'word-contexts-v1',
  });

  final Uri endpoint;
  final AiContextTransport transport;
  final Duration timeout;
  final String promptVersion;

  @override
  Future<Map<String, List<LearningContext>>> generateContexts(
    List<LearningWord> words,
  ) async {
    if (words.isEmpty) {
      return const <String, List<LearningContext>>{};
    }

    final payload = <String, dynamic>{
      'prompt_version': promptVersion,
      'target_language': 'uk',
      'max_contexts_per_word': 1,
      'words': words
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

    return _parseResponse(responseBody, words);
  }

  Map<String, List<LearningContext>> _parseResponse(
    String responseBody,
    List<LearningWord> words,
  ) {
    final wordIds = words.map((word) => word.wordId).toSet();
    final decoded = jsonDecode(responseBody) as Map<String, dynamic>;
    final rawContexts = decoded['contexts'] as List<dynamic>? ?? const [];
    final model = decoded['model'] as String?;
    final createdAt = DateTime.now().toUtc().toIso8601String();
    final contextsByWordId = <String, List<LearningContext>>{};

    for (var index = 0; index < rawContexts.length; index += 1) {
      final rawContext = rawContexts[index];
      if (rawContext is! Map<String, dynamic>) {
        continue;
      }

      final wordId = rawContext['word_id'] as String?;
      if (wordId == null || !wordIds.contains(wordId)) {
        continue;
      }

      final context = LearningContext(
        contextId:
            rawContext['id'] as String? ?? 'ai_${wordId}_${createdAt}_$index',
        hebrew: rawContext['hebrew'] as String? ?? '',
        translation:
            rawContext['ukrainian'] as String? ??
            rawContext['translation'] as String? ??
            '',
        source: LearningContextSource.aiGenerated,
        isNew: true,
        createdAt: createdAt,
        model: rawContext['model'] as String? ?? model,
        promptVersion: rawContext['prompt_version'] as String? ?? promptVersion,
      );
      if (!_isUsableContext(context)) {
        continue;
      }

      contextsByWordId
          .putIfAbsent(wordId, () => <LearningContext>[])
          .add(context);
    }

    return contextsByWordId;
  }
}

AiContextService createDefaultAiContextService() {
  const endpointValue = String.fromEnvironment('AI_CONTEXTS_ENDPOINT');
  final endpoint = Uri.tryParse(endpointValue);
  if (endpoint == null || !endpoint.hasScheme || !endpoint.hasAuthority) {
    return const CachedAiContextService(
      cacheStore: SharedPreferencesAiContextCacheStore(),
      backendClient: NoopAiContextBackendClient(),
    );
  }

  return CachedAiContextService(
    cacheStore: const SharedPreferencesAiContextCacheStore(),
    backendClient: EndpointAiContextBackendClient(endpoint: endpoint),
  );
}

bool _isUsableContext(LearningContext context) {
  return context.contextId.trim().isNotEmpty &&
      context.hebrew.trim().isNotEmpty &&
      context.translation.trim().isNotEmpty;
}
