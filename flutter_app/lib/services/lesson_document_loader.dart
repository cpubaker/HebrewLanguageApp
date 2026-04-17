import 'package:flutter/services.dart';

import '../models/lesson_document.dart';

abstract class LessonDocumentLoader {
  Future<LessonDocument> load(String assetPath);
}

class AssetLessonDocumentLoader implements LessonDocumentLoader {
  AssetLessonDocumentLoader({
    AssetBundle? assetBundle,
  }) : assetBundle = assetBundle ?? rootBundle;

  final AssetBundle assetBundle;
  final Map<String, Future<LessonDocument>> _cache =
      <String, Future<LessonDocument>>{};

  @override
  Future<LessonDocument> load(String assetPath) {
    return _cache.putIfAbsent(assetPath, () async {
      final content = await assetBundle.loadString(assetPath);
      final (title, rawBody) = _splitMarkdownSection(content);
      final cleanedBody = _stripRelatedTopicsSection(rawBody);
      return LessonDocument(
        title: title,
        body: cleanedBody,
        glossary: _extractGlossary(cleanedBody),
        summary: _extractSummary(rawBody),
        headings: _extractHeadings(rawBody),
        relatedTopics: _extractRelatedTopics(rawBody),
      );
    });
  }

  (String, String) _splitMarkdownSection(String content) {
    final lines = content.replaceFirst('\ufeff', '').split('\n');

    for (var index = 0; index < lines.length; index++) {
      final strippedLine = lines[index].trim().replaceFirst('\ufeff', '');
      if (strippedLine.isEmpty) {
        continue;
      }

      final headingMatch = RegExp(r'^#{1,6}\s+(.*)$').firstMatch(strippedLine);
      if (headingMatch != null) {
        return (
          headingMatch.group(1)!.trim(),
          lines.sublist(index + 1).join('\n').trim(),
        );
      }

      return (
        strippedLine,
        lines.sublist(index + 1).join('\n').trim(),
      );
    }

    return ('', '');
  }

  Map<String, String> _extractGlossary(String body) {
    final glossary = <String, String>{};

    for (final rawLine in body.split('\n')) {
      final line = rawLine.trim();
      if (!line.startsWith('- ')) {
        continue;
      }

      final item = line.substring(2).trim();
      final separatorIndex = item.indexOf(' - ');
      if (separatorIndex <= 0 || separatorIndex >= item.length - 3) {
        continue;
      }

      final source = item.substring(0, separatorIndex).trim();
      final translation = item.substring(separatorIndex + 3).trim();
      if (source.isEmpty ||
          translation.isEmpty ||
          !_containsHebrew(source)) {
        continue;
      }

      glossary.putIfAbsent(source, () => translation);
    }

    return glossary;
  }

  String _extractSummary(String body) {
    final lines = body.replaceFirst('\ufeff', '').split('\n');

    for (var index = 0; index < lines.length; index++) {
      final line = lines[index].trim();
      if (!line.startsWith('Коротко:')) {
        continue;
      }

      final summaryLines = <String>[];
      final inlineSummary = line.substring('Коротко:'.length).trim();
      if (inlineSummary.isNotEmpty) {
        summaryLines.add(inlineSummary);
      }

      for (var nextIndex = index + 1; nextIndex < lines.length; nextIndex++) {
        final nextLine = lines[nextIndex].trim();
        if (nextLine.isEmpty) {
          if (summaryLines.isNotEmpty) {
            break;
          }
          continue;
        }

        if (nextLine.startsWith('#')) {
          break;
        }

        summaryLines.add(nextLine);
      }

      return summaryLines.join(' ').trim();
    }

    return '';
  }

  List<String> _extractHeadings(String body) {
    return body
        .split('\n')
        .map((line) => RegExp(r'^##\s+(.*)$').firstMatch(line.trim()))
        .whereType<RegExpMatch>()
        .map((match) => match.group(1)!.trim())
        .where(
          (heading) =>
              heading.isNotEmpty &&
              heading != 'Пов’язані теми' &&
              heading != "Пов'язані теми",
        )
        .toList(growable: false);
  }

  List<String> _extractRelatedTopics(String body) {
    final lines = body.replaceFirst('\ufeff', '').split('\n');
    final relatedTopics = <String>[];
    var inRelatedTopics = false;

    for (final rawLine in lines) {
      final line = rawLine.trim();
      if (line.isEmpty) {
        continue;
      }

      final headingMatch = RegExp(r'^##\s+(.*)$').firstMatch(line);
      if (headingMatch != null) {
        final heading = headingMatch.group(1)!.trim();
        final isRelatedHeading =
            heading == 'Пов’язані теми' || heading == "Пов'язані теми";
        if (isRelatedHeading) {
          inRelatedTopics = true;
          continue;
        }

        if (inRelatedTopics) {
          break;
        }
      }

      if (!inRelatedTopics || !line.startsWith('- ')) {
        continue;
      }

      final topic = line.substring(2).trim();
      if (topic.isNotEmpty) {
        relatedTopics.add(topic);
      }
    }

    return relatedTopics;
  }

  String _stripRelatedTopicsSection(String body) {
    final lines = body.replaceFirst('\ufeff', '').split('\n');
    final keptLines = <String>[];
    var inRelatedTopics = false;

    for (final rawLine in lines) {
      final line = rawLine.trim();
      final headingMatch = RegExp(r'^##\s+(.*)$').firstMatch(line);
      if (headingMatch != null) {
        final heading = headingMatch.group(1)!.trim();
        final isRelatedHeading =
            heading == 'Пов’язані теми' || heading == "Пов'язані теми";
        if (isRelatedHeading) {
          inRelatedTopics = true;
          continue;
        }

        if (inRelatedTopics) {
          inRelatedTopics = false;
        }
      }

      if (inRelatedTopics) {
        continue;
      }

      keptLines.add(rawLine);
    }

    return keptLines.join('\n').trim();
  }

  bool _containsHebrew(String text) {
    return RegExp(r'[\u0590-\u05FF]').hasMatch(text);
  }
}
