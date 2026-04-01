import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hebrew_language_flutter/screens/widgets/markdown_lesson_body.dart';

void main() {
  testWidgets('renders Hebrew paragraph as right-aligned RTL text', (
    WidgetTester tester,
  ) async {
    const hebrewText = 'יוסי קם בבוקר.';

    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: MarkdownLessonBody(
            body: hebrewText,
            accentColor: Color(0xFF1D4ED8),
          ),
        ),
      ),
    );

    final selectableText = tester.widget<SelectableText>(
      find.byWidgetPredicate(
        (widget) => widget is SelectableText && widget.data == hebrewText,
      ),
    );

    expect(selectableText.textAlign, TextAlign.right);
    expect(selectableText.textDirection, TextDirection.rtl);
  });

  testWidgets('keeps mixed Ukrainian text with Hebrew letters left-aligned', (
    WidgetTester tester,
  ) async {
    const mixedText =
        'Наприклад, літера מ усередині слова пишеться як מ, а в кінці слова — як ם.';

    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: MarkdownLessonBody(
            body: mixedText,
            accentColor: Color(0xFF1D4ED8),
          ),
        ),
      ),
    );

    final selectableText = tester.widget<SelectableText>(
      find.byWidgetPredicate(
        (widget) => widget is SelectableText && widget.data == mixedText,
      ),
    );

    expect(selectableText.textAlign, TextAlign.left);
    expect(selectableText.textDirection, TextDirection.ltr);
  });
}
