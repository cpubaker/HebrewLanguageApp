import 'dart:ui' show TextDirection;

TextDirection resolveLessonTextDirection(String text) {
  for (final rune in text.runes) {
    final character = String.fromCharCode(rune);
    if (containsHebrewText(character)) {
      return TextDirection.rtl;
    }

    if (containsLatinOrCyrillicText(character)) {
      return TextDirection.ltr;
    }
  }

  return TextDirection.ltr;
}

TextDirection preferredLessonTextDirectionForDisplay(String text) {
  if (hasMixedLessonScriptContent(text)) {
    return TextDirection.ltr;
  }

  return resolveLessonTextDirection(text);
}

bool containsHebrewText(String text) {
  return RegExp(r'[\u0590-\u05FF]').hasMatch(text);
}

bool containsLatinOrCyrillicText(String text) {
  return RegExp(r'[A-Za-z\u0400-\u04FF]').hasMatch(text);
}

bool hasMixedLessonScriptContent(String text) {
  return containsHebrewText(text) && containsLatinOrCyrillicText(text);
}

String prepareBidirectionalLessonText(String text) {
  if (!hasMixedLessonScriptContent(text)) {
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
  final direction = resolveLessonTextDirection(text);
  final isolateStart = direction == TextDirection.rtl ? '\u2067' : '\u2066';
  return '$isolateStart$text\u2069';
}
