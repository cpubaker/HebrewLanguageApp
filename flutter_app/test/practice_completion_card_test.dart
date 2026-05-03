import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hebrew_language_flutter/screens/widgets/practice_completion_card.dart';
import 'package:hebrew_language_flutter/theme/app_theme.dart';

void main() {
  testWidgets('renders completion content, stats, and actions', (tester) async {
    var primaryTapCount = 0;
    var secondaryTapCount = 0;

    await tester.pumpWidget(
      MaterialApp(
        theme: buildLightAppTheme(),
        home: Scaffold(
          body: PracticeCompletionCard(
            badgeLabel: 'Done',
            title: '12 cards completed',
            body: 'Review is ready.',
            stats: const [
              PracticeCompletionStat(
                label: 'Correct',
                value: 9,
                icon: Icons.check_rounded,
                accent: Color(0xFF0F766E),
              ),
              PracticeCompletionStat(
                label: 'Repeat',
                value: 3,
                icon: Icons.refresh_rounded,
                accent: Color(0xFFB45309),
              ),
            ],
            primaryAction: PracticeCompletionAction(
              label: 'Start again',
              icon: Icons.refresh_rounded,
              onPressed: () => primaryTapCount += 1,
            ),
            secondaryAction: PracticeCompletionAction(
              label: 'Review',
              icon: Icons.rule_rounded,
              style: PracticeCompletionActionStyle.outlined,
              onPressed: () => secondaryTapCount += 1,
            ),
          ),
        ),
      ),
    );

    expect(find.text('Done'), findsOneWidget);
    expect(find.text('12 cards completed'), findsOneWidget);
    expect(find.text('Review is ready.'), findsOneWidget);
    expect(find.text('Correct:'), findsOneWidget);
    expect(find.text('9'), findsOneWidget);
    expect(find.text('Repeat:'), findsOneWidget);
    expect(find.text('3'), findsOneWidget);

    await tester.tap(find.text('Start again'));
    await tester.tap(find.text('Review'));

    expect(primaryTapCount, 1);
    expect(secondaryTapCount, 1);
  });

  testWidgets('omits empty body and stats spacing', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: buildLightAppTheme(),
        home: Scaffold(
          body: PracticeCompletionCard(
            badgeLabel: 'Done',
            title: 'No stats',
            body: '   ',
            stats: const [],
            primaryAction: PracticeCompletionAction(
              label: 'Restart',
              icon: Icons.replay_rounded,
              onPressed: () {},
            ),
          ),
        ),
      ),
    );

    expect(find.text('Done'), findsOneWidget);
    expect(find.text('No stats'), findsOneWidget);
    expect(find.text('   '), findsNothing);
    expect(find.text('Restart'), findsOneWidget);
  });
}
