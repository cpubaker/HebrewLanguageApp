import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hebrew_language_flutter/screens/widgets/markdown_lesson_body.dart';

void main() {
  testWidgets('renders Hebrew paragraph as right-aligned RTL text', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: MarkdownLessonBody(
            body: 'יוסי קם בבוקר.',
            accentColor: Color(0xFF1D4ED8),
          ),
        ),
      ),
    );

    final selectableText = tester.widget<SelectableText>(
      find.byWidgetPredicate(
        (widget) =>
            widget is SelectableText && widget.data == 'יוסי קם בבוקר.',
      ),
    );

    expect(selectableText.textAlign, TextAlign.right);
    expect(selectableText.textDirection, TextDirection.rtl);
  });
}
