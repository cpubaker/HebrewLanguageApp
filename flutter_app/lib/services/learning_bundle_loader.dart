import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import '../models/learning_bundle.dart';
import '../models/learning_context.dart';
import '../models/learning_word.dart';

abstract class LearningBundleLoader {
  Future<LearningBundle> load();
}

class AssetLearningBundleLoader implements LearningBundleLoader {
  AssetLearningBundleLoader({
    AssetBundle? assetBundle,
  }) : assetBundle = assetBundle ?? rootBundle;

  static const String _wordsAsset =
      'assets/learning/input/hebrew_words.json';
  static const String _contextSentencesAsset =
      'assets/learning/input/contexts/sentences.json';
  static const String _wordContextLinksAsset =
      'assets/learning/input/contexts/word_context_links.json';
  static const String _guidePrefix = 'assets/learning/input/guide/';
  static const String _verbsPrefix = 'assets/learning/input/verbs/';
  static const String _readingPrefix = 'assets/learning/input/reading/';

  final AssetBundle assetBundle;

  @override
  Future<LearningBundle> load() async {
    final wordsJson = await assetBundle.loadString(_wordsAsset);
    final baseWords = (jsonDecode(wordsJson) as List<dynamic>)
        .cast<Map<String, dynamic>>()
        .map(LearningWord.fromJson)
        .toList(growable: false);
    final contextsByWordId = await _loadContextsByWordId();
    final words = baseWords
        .map(
          (word) => word.copyWith(
            contexts: contextsByWordId[word.wordId] ?? const <LearningContext>[],
          ),
        )
        .toList(growable: false);

    final manifest = await AssetManifest.loadFromAssetBundle(assetBundle);
    final assetPaths = manifest.listAssets();

    return LearningBundle(
      words: words,
      guideLessons: _buildLessonEntries(assetPaths, _guidePrefix),
      verbLessons: _buildLessonEntries(assetPaths, _verbsPrefix),
      readingLessons: _buildLessonEntries(assetPaths, _readingPrefix),
    );
  }

  Future<Map<String, List<LearningContext>>> _loadContextsByWordId() async {
    try {
      final contextSentencesJson =
          await assetBundle.loadString(_contextSentencesAsset);
      final wordContextLinksJson =
          await assetBundle.loadString(_wordContextLinksAsset);

      final contextSentences = (jsonDecode(contextSentencesJson) as List<dynamic>)
          .cast<Map<String, dynamic>>()
          .map(LearningContext.fromJson)
          .toList(growable: false);
      final contextsById = <String, LearningContext>{
        for (final context in contextSentences)
          if (context.contextId.isNotEmpty) context.contextId: context,
      };

      final wordContextLinks =
          (jsonDecode(wordContextLinksJson) as Map<String, dynamic>)
              .map(
                (key, value) => MapEntry(
                  key,
                  (value as List<dynamic>).whereType<String>().toList(growable: false),
                ),
              );

      return wordContextLinks.map(
        (wordId, contextIds) => MapEntry(
          wordId,
          contextIds
              .where((contextId) => contextsById.containsKey(contextId))
              .map((contextId) => contextsById[contextId]!)
              .toList(growable: false),
        ),
      );
    } on FlutterError {
      return const <String, List<LearningContext>>{};
    }
  }

  List<LessonEntry> _buildLessonEntries(
    List<String> assetPaths,
    String prefix,
  ) {
    final filteredPaths = assetPaths
        .where(
          (path) =>
              path.startsWith(prefix) &&
              path.endsWith('.md') &&
              !_isInstructionFile(path),
        )
        .toList()
      ..sort(_compareLessonPaths);

    return filteredPaths
        .map(
          (path) => LessonEntry(
            assetPath: path,
            displayName: _displayNameForPath(path),
          ),
        )
        .toList(growable: false);
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

  int? _numericPrefix(String filename) {
    final match = RegExp(r'^(\d+)').firstMatch(filename);
    return match == null ? null : int.tryParse(match.group(1)!);
  }

  String _displayNameForPath(String path) {
    final filename = path.split('/').last;
    final withoutExtension = filename.replaceFirst(RegExp(r'\.md$'), '');
    final withoutPrefix =
        withoutExtension.replaceFirst(RegExp(r'^\d+[_-]*'), '');
    final words = withoutPrefix
        .split(RegExp(r'[_-]+'))
        .where((part) => part.isNotEmpty)
        .map((part) => '${part[0].toUpperCase()}${part.substring(1)}')
        .join(' ');
    final numericPrefix = _numericPrefix(filename);

    if (numericPrefix == null) {
      return words;
    }

    final paddedPrefix = numericPrefix.toString().padLeft(2, '0');
    return '$paddedPrefix $words';
  }
}
