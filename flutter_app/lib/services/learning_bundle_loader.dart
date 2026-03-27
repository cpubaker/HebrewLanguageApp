import 'dart:convert';

import 'package:flutter/services.dart';

import '../models/learning_bundle.dart';
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
  static const String _guidePrefix = 'assets/learning/input/guide/';
  static const String _verbsPrefix = 'assets/learning/input/verbs/';
  static const String _readingPrefix = 'assets/learning/input/reading/';

  final AssetBundle assetBundle;

  @override
  Future<LearningBundle> load() async {
    final wordsJson = await assetBundle.loadString(_wordsAsset);
    final manifestJson = await assetBundle.loadString('AssetManifest.json');

    final words = (jsonDecode(wordsJson) as List<dynamic>)
        .cast<Map<String, dynamic>>()
        .map(LearningWord.fromJson)
        .toList(growable: false);

    final manifest = jsonDecode(manifestJson) as Map<String, dynamic>;
    final assetPaths = manifest.keys.toList(growable: false);

    return LearningBundle(
      words: words,
      guideLessons: _buildLessonEntries(assetPaths, _guidePrefix),
      verbLessons: _buildLessonEntries(assetPaths, _verbsPrefix),
      readingLessons: _buildLessonEntries(assetPaths, _readingPrefix),
    );
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
