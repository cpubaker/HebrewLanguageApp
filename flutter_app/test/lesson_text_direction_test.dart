import 'dart:ui' show TextDirection;

import 'package:flutter_test/flutter_test.dart';
import 'package:hebrew_language_flutter/services/lesson_text_direction.dart';

void main() {
  test('resolves direction from first strong lesson script', () {
    expect(resolveLessonTextDirection('יוסי קם בבוקר.'), TextDirection.rtl);
    expect(resolveLessonTextDirection('Український текст'), TextDirection.ltr);
    expect(resolveLessonTextDirection('English text'), TextDirection.ltr);
    expect(resolveLessonTextDirection('1234'), TextDirection.ltr);
  });

  test('prefers left-to-right display for mixed lesson scripts', () {
    expect(
      preferredLessonTextDirectionForDisplay('אות ב всередині слова'),
      TextDirection.ltr,
    );
    expect(
      preferredLessonTextDirectionForDisplay('בוקר טוב'),
      TextDirection.rtl,
    );
  });

  test('detects Hebrew and mixed lesson script content', () {
    expect(containsHebrewText('שלום'), isTrue);
    expect(containsHebrewText('shalom'), isFalse);
    expect(hasMixedLessonScriptContent('שלום shalom'), isTrue);
    expect(hasMixedLessonScriptContent('שלום'), isFalse);
  });

  test('wraps mixed em dash segments with directional isolates', () {
    final prepared = prepareBidirectionalLessonText('אות א — як alef');

    expect(prepared, startsWith('\u2067אות א\u2069'));
    expect(prepared, contains(' — '));
    expect(prepared, endsWith('\u2066як alef\u2069'));
  });

  test('leaves mixed text without em dash separator unchanged', () {
    const text = 'אות א всередині речення';

    expect(prepareBidirectionalLessonText(text), text);
  });
}
