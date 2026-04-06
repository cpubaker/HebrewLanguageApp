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
  Future<LessonDocument> load(String assetPath) async {
    return _cache.putIfAbsent(assetPath, () async {
      final content = await assetBundle.loadString(assetPath);
      final (title, body) = _splitMarkdownSection(content);
      return LessonDocument(
        title: title,
        body: body,
        glossary: _extractGlossary(body),
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

  bool _containsHebrew(String text) {
    return RegExp(r'[\u0590-\u05FF]').hasMatch(text);
  }
}
