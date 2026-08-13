import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hebrew_language_flutter/l10n/generated/app_localizations.dart';
import 'package:hebrew_language_flutter/models/learning_bundle.dart';
import 'package:hebrew_language_flutter/models/learning_context.dart';
import 'package:hebrew_language_flutter/models/learning_word.dart';
import 'package:hebrew_language_flutter/screens/home_screen.dart';
import 'package:hebrew_language_flutter/theme/app_theme.dart';

import 'support/fakes.dart';

void main() {
  testWidgets('shows the word of the day on the home screen', (tester) async {
    final audioPlayer = FakeLearningAudioPlayer();

    await tester.pumpWidget(
      MaterialApp(
        locale: const Locale('uk'),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        theme: buildLightAppTheme(),
        home: Scaffold(
          body: HomeScreen(
            bundle: const LearningBundle(
              words: [
                LearningWord(
                  wordId: 'word_plain',
                  hebrew: 'plain',
                  english: 'plain',
                  transcription: 'plain',
                  correct: 0,
                  wrong: 0,
                ),
                LearningWord(
                  wordId: 'word_dog',
                  hebrew: 'kelev',
                  english: 'dog',
                  ukrainian: 'pes',
                  transcription: 'kelev',
                  audioAssetPath: 'assets/learning/input/audio/dog.mp3',
                  correct: 0,
                  wrong: 0,
                  contexts: [
                    LearningContext(
                      contextId: 'ctx_dog',
                      hebrew: 'dog context',
                      translation: 'dog translation',
                    ),
                  ],
                ),
              ],
              guideLessons: [],
              verbLessons: [],
              readingLessons: [],
            ),
            onOpenWords: () {},
            onOpenFlashcards: (_) {},
            onOpenWriting: () {},
            onOpenSprint: () {},
            onOpenGuide: () {},
            onOpenVerbs: () {},
            onOpenReading: () {},
            audioPlayerFactory: () => audioPlayer,
            wordOfDayDateProvider: () => DateTime.utc(2026, 3, 27),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Слово дня'), findsOneWidget);
    expect(find.text('kelev'), findsWidgets);
    expect(find.text('pes'), findsOneWidget);
    expect(find.text('dog context'), findsOneWidget);
    expect(find.text('dog translation'), findsOneWidget);
    expect(audioPlayer.playedAssets, isEmpty);

    await tester.tap(find.byKey(const ValueKey('word-of-day-audio-button')));
    await tester.pump();

    expect(audioPlayer.playedAssets, ['assets/learning/input/audio/dog.mp3']);

    expect(find.widgetWithText(OutlinedButton, 'До карток'), findsNothing);
  });
}
