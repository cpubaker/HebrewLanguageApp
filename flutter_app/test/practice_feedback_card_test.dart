import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hebrew_language_flutter/screens/widgets/practice_feedback_card.dart';
import 'package:hebrew_language_flutter/theme/app_theme.dart';

void main() {
  testWidgets('renders compact neutral feedback', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: buildLightAppTheme(),
        home: const Scaffold(
          body: PracticeFeedbackCard(
            tone: PracticeFeedbackTone.neutral,
            message: 'Answer to see feedback.',
            compact: true,
          ),
        ),
      ),
    );

    expect(find.byIcon(Icons.info_outline_rounded), findsOneWidget);
    expect(find.text('Answer to see feedback.'), findsOneWidget);
  });

  testWidgets('renders success feedback with RTL primary text', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: buildLightAppTheme(),
        home: const Scaffold(
          body: PracticeFeedbackCard(
            tone: PracticeFeedbackTone.success,
            title: 'Correct',
            primaryText: 'שלום',
            primaryTextDirection: TextDirection.rtl,
            message: 'Move to the next item.',
            footerText: 'Last correct: today',
          ),
        ),
      ),
    );

    expect(find.byIcon(Icons.check_circle_rounded), findsOneWidget);
    expect(find.text('Correct'), findsOneWidget);
    expect(find.text('Move to the next item.'), findsOneWidget);
    expect(find.text('Last correct: today'), findsOneWidget);

    final primaryText = tester.widget<Text>(find.text('שלום'));
    expect(primaryText.textDirection, TextDirection.rtl);
  });

  testWidgets('renders error feedback with extra content', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: buildLightAppTheme(),
        home: const Scaffold(
          body: PracticeFeedbackCard(
            tone: PracticeFeedbackTone.error,
            title: 'Try again',
            primaryText: 'בית',
            primaryTextDirection: TextDirection.rtl,
            message: 'We will revisit this later.',
            extraContent: Icon(Icons.volume_up_rounded),
          ),
        ),
      ),
    );

    expect(find.byIcon(Icons.cancel_rounded), findsOneWidget);
    expect(find.byIcon(Icons.volume_up_rounded), findsOneWidget);
    expect(find.text('Try again'), findsOneWidget);
    expect(find.text('We will revisit this later.'), findsOneWidget);
  });
}
