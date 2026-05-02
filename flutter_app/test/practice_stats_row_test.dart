import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hebrew_language_flutter/screens/widgets/practice_stat_pill.dart';
import 'package:hebrew_language_flutter/screens/widgets/practice_stats_row.dart';
import 'package:hebrew_language_flutter/theme/app_theme.dart';

void main() {
  testWidgets('renders stat items as equal-width pills', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: buildLightAppTheme(),
        home: const Scaffold(
          body: SizedBox(
            width: 360,
            child: PracticeStatsRow(
              stats: [
                PracticeStatItem(
                  label: 'Correct',
                  value: 7,
                  icon: Icons.check_rounded,
                  accent: Color(0xFF0F766E),
                ),
                PracticeStatItem(
                  label: 'Mistakes',
                  value: 3,
                  icon: Icons.close_rounded,
                  accent: Color(0xFFB91C1C),
                ),
              ],
            ),
          ),
        ),
      ),
    );

    expect(find.byType(PracticeStatPill), findsNWidgets(2));
    expect(find.text('Correct:'), findsOneWidget);
    expect(find.text('7'), findsOneWidget);
    expect(find.text('Mistakes:'), findsOneWidget);
    expect(find.text('3'), findsOneWidget);
    expect(find.byIcon(Icons.check_rounded), findsOneWidget);
    expect(find.byIcon(Icons.close_rounded), findsOneWidget);

    final firstWidth = tester
        .getSize(find.byType(PracticeStatPill).at(0))
        .width;
    final secondWidth = tester
        .getSize(find.byType(PracticeStatPill).at(1))
        .width;
    expect(firstWidth, secondWidth);
  });
}
