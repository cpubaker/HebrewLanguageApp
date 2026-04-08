import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

class MarkdownLessonBody extends StatefulWidget {
  const MarkdownLessonBody({
    super.key,
    required this.body,
    required this.accentColor,
    this.inlineGlossary = const <String, String>{},
  });

  final String body;
  final Color accentColor;
  final Map<String, String> inlineGlossary;

  @override
  State<MarkdownLessonBody> createState() => _MarkdownLessonBodyState();
}

class _MarkdownLessonBodyState extends State<MarkdownLessonBody> {
  final List<TapGestureRecognizer> _recognizers = <TapGestureRecognizer>[];

  @override
  void dispose() {
    _disposeRecognizers();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    _disposeRecognizers();

    final lines = widget.body.split('\n');
    final children = <Widget>[];

    for (final rawLine in lines) {
      final line = rawLine.trimRight();
      if (line.trim().isEmpty) {
        children.add(const SizedBox(height: 12));
        continue;
      }

      final headingMatch = RegExp(r'^(#{1,6})\s+(.*)$').firstMatch(line.trim());
      if (headingMatch != null) {
        final level = headingMatch.group(1)!.length;
        final title = headingMatch.group(2)!.trim();
        final textDirection = _resolveTextDirection(title);
        children.add(
          Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: SizedBox(
              width: double.infinity,
              child: Text(
                title,
                style: _headingStyleForLevel(context, level),
                textAlign: _textAlignForDirection(textDirection),
                textDirection: textDirection,
              ),
            ),
          ),
        );
        continue;
      }

      if (line.trimLeft().startsWith('- ')) {
        final bulletText = line.trimLeft().substring(2).trim();
        final displayText = _prepareBidirectionalText(bulletText);
        final textDirection = _preferredTextDirectionForDisplay(bulletText);
        children.add(
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Icon(Icons.circle, size: 8, color: widget.accentColor),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: SelectableText(
                    displayText,
                    style: Theme.of(
                      context,
                    ).textTheme.bodyLarge?.copyWith(height: 1.55),
                    textAlign: _textAlignForDirection(textDirection),
                    textDirection: textDirection,
                  ),
                ),
              ],
            ),
          ),
        );
        continue;
      }

      final text = line.trim();
      final textDirection = _preferredTextDirectionForDisplay(text);
      children.add(
        Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: SizedBox(
            width: double.infinity,
            child: _buildParagraph(
              context,
              _prepareBidirectionalText(text),
              textDirection,
            ),
          ),
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: children,
      ),
    );
  }

  TextStyle? _headingStyleForLevel(BuildContext context, int level) {
    if (level <= 2) {
      return Theme.of(
        context,
      ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800);
    }

    return Theme.of(
      context,
    ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700);
  }

  TextDirection _resolveTextDirection(String text) {
    for (final rune in text.runes) {
      final character = String.fromCharCode(rune);
      if (RegExp(r'[\u0590-\u05FF]').hasMatch(character)) {
        return TextDirection.rtl;
      }

      if (RegExp(r'[A-Za-z\u0400-\u04FF]').hasMatch(character)) {
        return TextDirection.ltr;
      }
    }

    return TextDirection.ltr;
  }

  TextDirection _preferredTextDirectionForDisplay(String text) {
    if (_hasMixedScriptContent(text)) {
      return TextDirection.ltr;
    }

    return _resolveTextDirection(text);
  }

  Widget _buildParagraph(
    BuildContext context,
    String text,
    TextDirection textDirection,
  ) {
    final style = Theme.of(context).textTheme.bodyLarge?.copyWith(height: 1.6);
    if (widget.inlineGlossary.isEmpty || !_containsHebrew(text)) {
      return SelectableText(
        text,
        style: style,
        textAlign: _textAlignForDirection(textDirection),
        textDirection: textDirection,
      );
    }

    final interactiveSpans = _buildInteractiveSpans(context, text, style);
    if (interactiveSpans == null) {
      return SelectableText(
        text,
        style: style,
        textAlign: _textAlignForDirection(textDirection),
        textDirection: textDirection,
      );
    }

    return RichText(
      textAlign: _textAlignForDirection(textDirection),
      textDirection: textDirection,
      text: TextSpan(style: style, children: interactiveSpans),
    );
  }

  List<InlineSpan>? _buildInteractiveSpans(
    BuildContext context,
    String text,
    TextStyle? baseStyle,
  ) {
    final rawTokens = RegExp(r'\s+|[^\s]+')
        .allMatches(text)
        .map((match) => match.group(0)!)
        .toList(growable: false);
    if (rawTokens.isEmpty) {
      return null;
    }

    final glossaryEntries = widget.inlineGlossary.entries
        .map(
          (entry) => _GlossaryEntry(
            source: entry.key,
            translation: entry.value,
            normalizedWords: _normalizeForLookup(entry.key)
                .split(' ')
                .where((part) => part.isNotEmpty)
                .toList(growable: false),
          ),
        )
        .where((entry) => entry.normalizedWords.isNotEmpty)
        .toList(growable: false);
    if (glossaryEntries.isEmpty) {
      return null;
    }

    final entriesByFirstWord = <String, List<_GlossaryEntry>>{};
    for (final entry in glossaryEntries) {
      entriesByFirstWord
          .putIfAbsent(entry.normalizedWords.first, () => <_GlossaryEntry>[])
          .add(entry);
    }
    for (final entries in entriesByFirstWord.values) {
      entries.sort(
        (left, right) => right.normalizedWords.length.compareTo(
          left.normalizedWords.length,
        ),
      );
    }

    final wordTokens = <_WordToken>[];
    for (var rawIndex = 0; rawIndex < rawTokens.length; rawIndex++) {
      final normalized = _normalizeForLookup(rawTokens[rawIndex]);
      if (normalized.isEmpty || normalized.contains(' ')) {
        continue;
      }

      wordTokens.add(
        _WordToken(
          rawTokenIndex: rawIndex,
          normalized: normalized,
        ),
      );
    }

    if (wordTokens.isEmpty) {
      return null;
    }

    final matchesByStart = <int, _GlossaryMatch>{};
    for (var wordIndex = 0; wordIndex < wordTokens.length; wordIndex++) {
      final currentWord = wordTokens[wordIndex];
      final candidates =
          entriesByFirstWord[currentWord.normalized] ?? const <_GlossaryEntry>[];
      if (candidates.isEmpty) {
        continue;
      }

      _GlossaryEntry? matchedEntry;
      var matchedWordEndIndex = wordIndex;

      for (final candidate in candidates) {
        final nextWordEndIndex = wordIndex + candidate.normalizedWords.length - 1;
        if (nextWordEndIndex >= wordTokens.length) {
          continue;
        }

        var matches = true;
        for (var offset = 0; offset < candidate.normalizedWords.length; offset++) {
          if (wordTokens[wordIndex + offset].normalized !=
              candidate.normalizedWords[offset]) {
            matches = false;
            break;
          }
        }

        if (matches) {
          matchedEntry = candidate;
          matchedWordEndIndex = nextWordEndIndex;
          break;
        }
      }

      if (matchedEntry == null) {
        continue;
      }

      matchesByStart[currentWord.rawTokenIndex] = _GlossaryMatch(
        rawTokenEndIndex: wordTokens[matchedWordEndIndex].rawTokenIndex,
        source: matchedEntry.source,
        translation: matchedEntry.translation,
      );
      wordIndex = matchedWordEndIndex;
    }

    if (matchesByStart.isEmpty) {
      return null;
    }

    final tappableStyle = baseStyle?.copyWith(
      color: widget.accentColor,
      fontWeight: FontWeight.w700,
      decoration: TextDecoration.underline,
      decorationColor: widget.accentColor.withValues(alpha: 0.4),
    );

    final spans = <InlineSpan>[];
    for (var rawIndex = 0; rawIndex < rawTokens.length;) {
      final match = matchesByStart[rawIndex];
      if (match == null) {
        spans.add(TextSpan(text: rawTokens[rawIndex], style: baseStyle));
        rawIndex++;
        continue;
      }

      spans.add(
        TextSpan(
          text: rawTokens
              .sublist(rawIndex, match.rawTokenEndIndex + 1)
              .join(),
          style: tappableStyle,
          recognizer: _createTapRecognizer(() {
            _showGlossarySheet(
              context,
              source: match.source,
              translation: match.translation,
            );
          }),
        ),
      );
      rawIndex = match.rawTokenEndIndex + 1;
    }

    return spans;
  }

  TapGestureRecognizer _createTapRecognizer(VoidCallback onTap) {
    final recognizer = TapGestureRecognizer()..onTap = onTap;
    _recognizers.add(recognizer);
    return recognizer;
  }

  Future<void> _showGlossarySheet(
    BuildContext context, {
    required String source,
    required String translation,
  }) {
    final sourceDirection = _resolveTextDirection(source);
    return showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  source,
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    color: widget.accentColor,
                    fontWeight: FontWeight.w800,
                  ),
                  textDirection: sourceDirection,
                  textAlign: _textAlignForDirection(sourceDirection),
                ),
                const SizedBox(height: 10),
                Text(
                  translation,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    height: 1.45,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  TextAlign _textAlignForDirection(TextDirection textDirection) {
    return textDirection == TextDirection.rtl ? TextAlign.right : TextAlign.left;
  }

  bool _containsHebrew(String text) {
    return RegExp(r'[\u0590-\u05FF]').hasMatch(text);
  }

  bool _containsLatinOrCyrillic(String text) {
    return RegExp(r'[A-Za-z\u0400-\u04FF]').hasMatch(text);
  }

  bool _hasMixedScriptContent(String text) {
    return _containsHebrew(text) && _containsLatinOrCyrillic(text);
  }

  String _prepareBidirectionalText(String text) {
    if (!_hasMixedScriptContent(text)) {
      return text;
    }

    final separatorPattern = RegExp(r'\s+—\s+');
    final segments = text.split(separatorPattern);
    if (segments.length <= 1) {
      return text;
    }

    return segments.map(_wrapWithDirectionalIsolate).join(' — ');
  }

  String _wrapWithDirectionalIsolate(String text) {
    final direction = _resolveTextDirection(text);
    final isolateStart = direction == TextDirection.rtl ? '\u2067' : '\u2066';
    return '$isolateStart$text\u2069';
  }

  String _normalizeForLookup(String text) {
    final withoutNiqqud = text.replaceAll(RegExp(r'[\u0591-\u05C7]'), '');
    final cleaned = withoutNiqqud.replaceAll(
      RegExp(r'[^0-9A-Za-z\u0590-\u05FF]+'),
      ' ',
    );
    return cleaned.trim().replaceAll(RegExp(r'\s+'), ' ');
  }

  void _disposeRecognizers() {
    for (final recognizer in _recognizers) {
      recognizer.dispose();
    }
    _recognizers.clear();
  }
}

class _GlossaryEntry {
  const _GlossaryEntry({
    required this.source,
    required this.translation,
    required this.normalizedWords,
  });

  final String source;
  final String translation;
  final List<String> normalizedWords;
}

class _WordToken {
  const _WordToken({
    required this.rawTokenIndex,
    required this.normalized,
  });

  final int rawTokenIndex;
  final String normalized;
}

class _GlossaryMatch {
  const _GlossaryMatch({
    required this.rawTokenEndIndex,
    required this.source,
    required this.translation,
  });

  final int rawTokenEndIndex;
  final String source;
  final String translation;
}
