import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hebrew_language_flutter/l10n/generated/app_localizations.dart';
import 'package:hebrew_language_flutter/models/guide_lesson_status.dart';
import 'package:hebrew_language_flutter/screens/widgets/lesson_status_controls.dart';
import 'package:hebrew_language_flutter/theme/app_theme.dart';

void main() {
  test('lesson status visuals use semantic theme tokens', () {
    final tokens = buildLightAppTheme().appTokens;

    expect(
      lessonStatusVisuals(GuideLessonStatus.unread, tokens: tokens).color,
      tokens.warningAccent,
    );
    expect(
      lessonStatusVisuals(GuideLessonStatus.studying, tokens: tokens).color,
      tokens.infoAccent,
    );
    expect(
      lessonStatusVisuals(GuideLessonStatus.read, tokens: tokens).color,
      tokens.successAccent,
    );
  });

  testWidgets('toggle uses themed status color by default', (tester) async {
    final tokens = buildDarkAppTheme().appTokens;

    await tester.pumpWidget(
      MaterialApp(
        locale: const Locale('uk'),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        theme: buildDarkAppTheme(),
        home: Scaffold(
          body: LessonStatusToggleButton(
            status: GuideLessonStatus.studying,
            onPressed: () {},
          ),
        ),
      ),
    );

    final icon = tester.widget<Icon>(find.byIcon(Icons.timelapse_rounded));
    expect(icon.color, tokens.infoAccent);
  });
}
