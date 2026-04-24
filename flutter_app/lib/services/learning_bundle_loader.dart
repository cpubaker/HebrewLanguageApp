import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import '../models/learning_bundle.dart';
import '../models/learning_context.dart';
import '../models/learning_word.dart';

abstract class LearningBundleLoader {
  Future<LearningBundle> load();
}

abstract class LazyLearningBundleLoader {
  Future<LearningBundle> loadSummary();

  Future<LearningBundle> loadWithFullWordContexts();
}

extension LazyLearningBundleLoaderFallback on LearningBundleLoader {
  Future<LearningBundle> loadLazySummary() {
    final loader = this;
    if (loader is LazyLearningBundleLoader) {
      return (loader as LazyLearningBundleLoader).loadSummary();
    }

    return load();
  }

  Future<LearningBundle> loadLazyWithFullWordContexts() {
    final loader = this;
    if (loader is LazyLearningBundleLoader) {
      return (loader as LazyLearningBundleLoader).loadWithFullWordContexts();
    }

    return load();
  }
}

class AssetLearningBundleLoader
    implements LearningBundleLoader, LazyLearningBundleLoader {
  AssetLearningBundleLoader({AssetBundle? assetBundle})
    : assetBundle = assetBundle ?? rootBundle;

  static const String _wordsAsset = 'assets/learning/input/hebrew_words.json';
  static const String _guideMetadataAsset =
      'assets/learning/input/guide_metadata.json';
  static const String _lessonCatalogAsset =
      'assets/learning/input/lesson_catalog.json';
  static const String _contextSentencesAsset =
      'assets/learning/input/contexts/sentences.json';
  static const String _wordContextLinksAsset =
      'assets/learning/input/contexts/word_context_links.json';
  static const String _guidePrefix = 'assets/learning/input/guide/';
  static const String _verbsPrefix = 'assets/learning/input/verbs/';
  static const String _readingPrefix = 'assets/learning/input/reading/';

  final AssetBundle assetBundle;
  Future<LearningBundle>? _summaryFuture;
  Future<LearningBundle>? _fullWordContextsFuture;

  @override
  Future<LearningBundle> load() async {
    return loadWithFullWordContexts();
  }

  @override
  Future<LearningBundle> loadSummary() {
    return _summaryFuture ??= _load(includeFullWordContexts: false);
  }

  @override
  Future<LearningBundle> loadWithFullWordContexts() {
    return _fullWordContextsFuture ??= _load(includeFullWordContexts: true);
  }

  Future<LearningBundle> _load({required bool includeFullWordContexts}) async {
    final wordsJson = await assetBundle.loadString(_wordsAsset);
    final baseWords = (jsonDecode(wordsJson) as List<dynamic>)
        .cast<Map<String, dynamic>>()
        .map(LearningWord.fromJson)
        .toList(growable: false);
    final contextsByWordId = await _loadContextsByWordId(
      includeFullWordContexts: includeFullWordContexts,
    );
    final guideMetadata = await _loadGuideMetadata();
    final words = baseWords
        .map(
          (word) => word.copyWith(
            contexts:
                contextsByWordId[word.wordId] ?? const <LearningContext>[],
          ),
        )
        .toList(growable: false);

    final lessonCatalog = await _loadLessonCatalog();
    final assetPaths = lessonCatalog.isEmpty
        ? (await AssetManifest.loadFromAssetBundle(assetBundle)).listAssets()
        : const <String>[];

    return LearningBundle(
      words: words,
      guideLessons: _buildLessonEntries(
        assetPaths,
        _guidePrefix,
        lessonCatalog['guide'],
        guideMetadata: guideMetadata,
      ),
      verbLessons: _buildLessonEntries(
        assetPaths,
        _verbsPrefix,
        lessonCatalog['verbs'],
      ),
      readingLessons: _buildLessonEntries(
        assetPaths,
        _readingPrefix,
        lessonCatalog['reading'],
      ),
      hasFullWordContexts: includeFullWordContexts,
    );
  }

  Future<Map<String, List<LearningContext>>> _loadContextsByWordId({
    required bool includeFullWordContexts,
  }) async {
    try {
      final wordContextLinks = await _loadWordContextLinks();
      final contextsById = includeFullWordContexts
          ? await _loadContextsById()
          : const <String, LearningContext>{};

      return wordContextLinks.map(
        (wordId, contextIds) => MapEntry(
          wordId,
          contextIds
              .map((contextId) {
                return contextsById[contextId] ??
                    LearningContext(
                      contextId: contextId,
                      hebrew: '',
                      translation: '',
                    );
              })
              .toList(growable: false),
        ),
      );
    } on FlutterError {
      return const <String, List<LearningContext>>{};
    }
  }

  Future<Map<String, List<String>>> _loadWordContextLinks() async {
    final wordContextLinksJson = await assetBundle.loadString(
      _wordContextLinksAsset,
    );

    return (jsonDecode(wordContextLinksJson) as Map<String, dynamic>).map(
      (key, value) => MapEntry(
        key,
        (value as List<dynamic>).whereType<String>().toList(growable: false),
      ),
    );
  }

  Future<Map<String, LearningContext>> _loadContextsById() async {
    final contextSentencesJson = await assetBundle.loadString(
      _contextSentencesAsset,
    );
    final contextSentences = (jsonDecode(contextSentencesJson) as List<dynamic>)
        .cast<Map<String, dynamic>>()
        .map(LearningContext.fromJson)
        .toList(growable: false);

    return <String, LearningContext>{
      for (final context in contextSentences)
        if (context.contextId.isNotEmpty) context.contextId: context,
    };
  }

  List<LessonEntry> _buildLessonEntries(
    List<String> assetPaths,
    String prefix,
    List<String>? catalogRelativePaths, {
    _GuideMetadata? guideMetadata,
  }) {
    final filteredPaths = <String>{
      ...assetPaths.where(
        (path) =>
            path.startsWith(prefix) &&
            path.endsWith('.md') &&
            !_isInstructionFile(path),
      ),
      ...?catalogRelativePaths
          ?.map(
            (relativePath) =>
                '$prefix${relativePath.replaceAll('\\', '/').replaceFirst(RegExp(r'^/+'), '')}',
          )
          .where(
            (path) =>
                path.startsWith(prefix) &&
                path.endsWith('.md') &&
                !_isInstructionFile(path),
          ),
    }.toList();

    final lessons = filteredPaths
        .map((path) {
          final metadataEntry = guideMetadata?.lessonForPath(path);
          final lessonId = metadataEntry?.lessonId ?? _lessonIdForPath(path);
          final sectionId = metadataEntry?.sectionId;
          final sectionLabel = sectionId == null
              ? null
              : guideMetadata?.sectionLabelFor(sectionId);

          return LessonEntry(
            assetPath: path,
            displayName: _displayNameForPath(
              path,
              titleOverride: metadataEntry?.title,
              orderOverride: metadataEntry?.sortOrder,
            ),
            sortOrder: metadataEntry?.sortOrder,
            lessonId: lessonId,
            sectionId: sectionId,
            sectionLabel: sectionLabel,
            aliases: metadataEntry?.aliases ?? const <String>[],
            relatedIds: metadataEntry?.relatedIds ?? const <String>[],
          );
        })
        .toList(growable: false);

    lessons.sort(_compareLessonEntries);
    return lessons;
  }

  Future<_GuideMetadata> _loadGuideMetadata() async {
    try {
      final rawMetadata = await assetBundle.loadString(_guideMetadataAsset);
      final decodedMetadata = jsonDecode(rawMetadata);
      if (decodedMetadata is! Map<String, dynamic>) {
        return const _GuideMetadata.empty();
      }

      final sections =
          ((decodedMetadata['sections'] as Map<String, dynamic>?) ??
                  const <String, dynamic>{})
              .map((key, value) => MapEntry(key, value.toString()));
      final lessons =
          ((decodedMetadata['lessons'] as Map<String, dynamic>?) ??
                  const <String, dynamic>{})
              .map(
                (filename, value) =>
                    MapEntry(filename, _GuideMetadataEntry.fromJson(value)),
              );

      return _GuideMetadata(sections: sections, lessons: lessons);
    } on FlutterError {
      return const _GuideMetadata.empty();
    } on FormatException {
      return const _GuideMetadata.empty();
    }
  }

  Future<Map<String, List<String>>> _loadLessonCatalog() async {
    try {
      final rawCatalog = await assetBundle.loadString(_lessonCatalogAsset);
      final decodedCatalog = jsonDecode(rawCatalog);
      if (decodedCatalog is! Map<String, dynamic>) {
        return const <String, List<String>>{};
      }

      return decodedCatalog.map(
        (section, entries) => MapEntry(
          section,
          (entries as List<dynamic>).whereType<String>().toList(
            growable: false,
          ),
        ),
      );
    } on FlutterError {
      return const <String, List<String>>{};
    } on FormatException {
      return const <String, List<String>>{};
    }
  }

  bool _isInstructionFile(String path) {
    return path.toLowerCase().endsWith('/agents.md');
  }

  int _compareLessonPaths(String left, String right) {
    final leftName = left.split('/').last;
    final rightName = right.split('/').last;
    final leftPrefix = _numericPrefix(leftName);
    final rightPrefix = _numericPrefix(rightName);

    if (leftPrefix != null && rightPrefix != null) {
      final prefixComparison = leftPrefix.compareTo(rightPrefix);
      if (prefixComparison != 0) {
        return prefixComparison;
      }
    }

    return left.compareTo(right);
  }

  int _compareLessonEntries(LessonEntry left, LessonEntry right) {
    final leftOrder = left.sortOrder;
    final rightOrder = right.sortOrder;

    if (leftOrder != null && rightOrder != null) {
      final orderComparison = leftOrder.compareTo(rightOrder);
      if (orderComparison != 0) {
        return orderComparison;
      }
    } else if (leftOrder != null) {
      return -1;
    } else if (rightOrder != null) {
      return 1;
    }

    return _compareLessonPaths(left.assetPath, right.assetPath);
  }

  int? _numericPrefix(String filename) {
    final match = RegExp(r'^(\d+)').firstMatch(filename);
    return match == null ? null : int.tryParse(match.group(1)!);
  }

  String _displayNameForPath(
    String path, {
    String? titleOverride,
    int? orderOverride,
  }) {
    final filename = path.split('/').last;
    final resolvedTitle = titleOverride?.trim().isNotEmpty == true
        ? titleOverride!.trim()
        : () {
            final withoutExtension = filename.replaceFirst(
              RegExp(r'\.md$'),
              '',
            );
            final withoutPrefix = withoutExtension.replaceFirst(
              RegExp(r'^\d+[_-]*'),
              '',
            );
            return withoutPrefix
                .split(RegExp(r'[_-]+'))
                .where((part) => part.isNotEmpty)
                .map((part) => '${part[0].toUpperCase()}${part.substring(1)}')
                .join(' ');
          }();
    final numericPrefix = orderOverride ?? _numericPrefix(filename);

    if (numericPrefix == null) {
      return resolvedTitle;
    }

    final paddedPrefix = numericPrefix.toString().padLeft(2, '0');
    return '$paddedPrefix $resolvedTitle';
  }

  String _lessonIdForPath(String path) {
    final filename = path.split('/').last;
    final withoutExtension = filename.replaceFirst(RegExp(r'\.md$'), '');
    return withoutExtension.replaceFirst(RegExp(r'^\d+[_-]*'), '');
  }
}

class _GuideMetadata {
  const _GuideMetadata({required this.sections, required this.lessons});

  const _GuideMetadata.empty()
    : sections = const <String, String>{},
      lessons = const <String, _GuideMetadataEntry>{};

  final Map<String, String> sections;
  final Map<String, _GuideMetadataEntry> lessons;

  _GuideMetadataEntry? lessonForPath(String assetPath) {
    final filename = assetPath.split('/').last;
    return lessons[filename];
  }

  String? sectionLabelFor(String sectionId) {
    return sections[sectionId];
  }
}

class _GuideMetadataEntry {
  const _GuideMetadataEntry({
    this.sortOrder,
    this.lessonId,
    this.title,
    this.sectionId,
    this.aliases = const <String>[],
    this.relatedIds = const <String>[],
  });

  final int? sortOrder;
  final String? lessonId;
  final String? title;
  final String? sectionId;
  final List<String> aliases;
  final List<String> relatedIds;

  factory _GuideMetadataEntry.fromJson(dynamic value) {
    if (value is! Map<String, dynamic>) {
      return const _GuideMetadataEntry();
    }

    return _GuideMetadataEntry(
      sortOrder: _parseSortOrder(value['order']),
      lessonId: value['id']?.toString(),
      title: value['title']?.toString(),
      sectionId: value['section']?.toString(),
      aliases: (value['aliases'] as List<dynamic>? ?? const <dynamic>[])
          .map((item) => item.toString())
          .where((item) => item.trim().isNotEmpty)
          .toList(growable: false),
      relatedIds: (value['related_ids'] as List<dynamic>? ?? const <dynamic>[])
          .map((item) => item.toString())
          .where((item) => item.trim().isNotEmpty)
          .toList(growable: false),
    );
  }

  static int? _parseSortOrder(dynamic value) {
    if (value is int) {
      return value;
    }
    if (value is num) {
      return value.toInt();
    }
    if (value is String) {
      return int.tryParse(value.trim());
    }
    return null;
  }
}
