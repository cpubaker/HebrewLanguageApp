class LessonGlossaryTextSegment {
  const LessonGlossaryTextSegment({required this.text, this.match});

  final String text;
  final LessonGlossaryMatch? match;
}

class LessonGlossaryMatch {
  const LessonGlossaryMatch({required this.source, required this.translation});

  final String source;
  final String translation;
}

List<LessonGlossaryTextSegment>? matchLessonGlossaryText(
  String text,
  Map<String, String> glossary,
) {
  final rawTokens = RegExp(
    r'\s+|[^\s]+',
  ).allMatches(text).map((match) => match.group(0)!).toList(growable: false);
  if (rawTokens.isEmpty) {
    return null;
  }

  final glossaryEntries = glossary.entries
      .map(
        (entry) => _GlossaryEntry(
          source: entry.key,
          translation: entry.value,
          normalizedWords: normalizeLessonGlossaryText(
            entry.key,
          ).split(' ').where((part) => part.isNotEmpty).toList(growable: false),
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
      (left, right) =>
          right.normalizedWords.length.compareTo(left.normalizedWords.length),
    );
  }

  final wordTokens = <_WordToken>[];
  for (var rawIndex = 0; rawIndex < rawTokens.length; rawIndex++) {
    final normalized = normalizeLessonGlossaryText(rawTokens[rawIndex]);
    if (normalized.isEmpty || normalized.contains(' ')) {
      continue;
    }

    wordTokens.add(_WordToken(rawTokenIndex: rawIndex, normalized: normalized));
  }

  if (wordTokens.isEmpty) {
    return null;
  }

  final matchesByStart = <int, _RawGlossaryMatch>{};
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
      for (
        var offset = 0;
        offset < candidate.normalizedWords.length;
        offset++
      ) {
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

    matchesByStart[currentWord.rawTokenIndex] = _RawGlossaryMatch(
      rawTokenEndIndex: wordTokens[matchedWordEndIndex].rawTokenIndex,
      source: matchedEntry.source,
      translation: matchedEntry.translation,
    );
    wordIndex = matchedWordEndIndex;
  }

  if (matchesByStart.isEmpty) {
    return null;
  }

  final segments = <LessonGlossaryTextSegment>[];
  for (var rawIndex = 0; rawIndex < rawTokens.length;) {
    final match = matchesByStart[rawIndex];
    if (match == null) {
      segments.add(LessonGlossaryTextSegment(text: rawTokens[rawIndex]));
      rawIndex++;
      continue;
    }

    segments.add(
      LessonGlossaryTextSegment(
        text: rawTokens.sublist(rawIndex, match.rawTokenEndIndex + 1).join(),
        match: LessonGlossaryMatch(
          source: match.source,
          translation: match.translation,
        ),
      ),
    );
    rawIndex = match.rawTokenEndIndex + 1;
  }

  return segments;
}

String normalizeLessonGlossaryText(String text) {
  final withoutNiqqud = text.replaceAll(RegExp(r'[\u0591-\u05C7]'), '');
  final cleaned = withoutNiqqud.replaceAll(
    RegExp(r'[^0-9A-Za-z\u0590-\u05FF]+'),
    ' ',
  );
  return cleaned.trim().replaceAll(RegExp(r'\s+'), ' ');
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
  const _WordToken({required this.rawTokenIndex, required this.normalized});

  final int rawTokenIndex;
  final String normalized;
}

class _RawGlossaryMatch {
  const _RawGlossaryMatch({
    required this.rawTokenEndIndex,
    required this.source,
    required this.translation,
  });

  final int rawTokenEndIndex;
  final String source;
  final String translation;
}
