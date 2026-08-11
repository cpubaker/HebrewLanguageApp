import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hebrew_language_flutter/l10n/generated/app_localizations.dart';
import 'package:hebrew_language_flutter/models/learning_word.dart';
import 'package:hebrew_language_flutter/screens/sprint_screen.dart';
import 'package:hebrew_language_flutter/services/learning_audio_player.dart';
import 'package:hebrew_language_flutter/services/sprint_stats_store.dart';

import 'support/app_test_harness.dart';
import 'support/fakes.dart';

void main() {
  testWidgets('swipes select first option left and second option right', (
    WidgetTester tester,
  ) async {
    await useTallMobileViewport(tester);
    final updatedWords = <LearningWord>[];

    await _pumpSprintScreen(
      tester,
      words: const [
        LearningWord(
          wordId: 'word_alpha',
          hebrew: 'alpha',
          english: 'alpha',
          transcription: 'alpha',
          correct: 0,
          wrong: 0,
        ),
        LearningWord(
          wordId: 'word_beta',
          hebrew: 'beta',
          english: 'beta',
          transcription: 'beta',
          correct: 0,
          wrong: 0,
        ),
      ],
      onWordProgressChanged: updatedWords.add,
    );

    await tester.fling(
      find.byKey(const ValueKey('sprint-active-card')),
      const Offset(-420, 0),
      1000,
    );
    await tester.pump();

    expect(updatedWords, hasLength(1));
    expect(updatedWords.single.wordId, 'word_alpha');
    expect(updatedWords.single.correct, 0);
    expect(updatedWords.single.wrong, 1);

    await tester.fling(
      find.byKey(const ValueKey('sprint-active-card')),
      const Offset(420, 0),
      1000,
    );
    await tester.pump();

    expect(updatedWords, hasLength(2));
    expect(updatedWords.last.wordId, 'word_beta');
    expect(updatedWords.last.correct, 1);
    expect(updatedWords.last.wrong, 0);
  });

  testWidgets('completion shows record and above-average feedback', (
    WidgetTester tester,
  ) async {
    final statsStore = FakeSprintStatsStore(
      const SprintStats(sessions: 2, bestCorrect: 1, totalCorrect: 1),
    );

    await _pumpSprintScreen(
      tester,
      statsStore: statsStore,
      duration: const Duration(seconds: 1),
    );

    await tester.tap(find.byKey(const ValueKey('sprint-option-1')));
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));
    await tester.pump();

    expect(find.text('Рекорд досягнуто'), findsOneWidget);
    expect(
      find.textContaining('Ви досягли свого рекорду: 1 вірних відповідей.'),
      findsOneWidget,
    );
    expect(
      find.textContaining('Це на 0,3 вище вашого середнього.'),
      findsNothing,
    );
    expect(
      find.textContaining('Середній результат: 1 вірних відповідей.'),
      findsOneWidget,
    );
    expect(statsStore.savedStats.last.bestCorrect, 1);
    expect(statsStore.savedStats.last.sessions, 3);
  });

  testWidgets('auto-plays audio for the first and second prompts', (
    WidgetTester tester,
  ) async {
    final audioPlayer = FakeVerbAudioPlayer(
      availableAssets: const {
        'assets/audio/shalom.mp3',
        'assets/audio/bayit.mp3',
      },
    );

    await _pumpSprintScreen(
      tester,
      words: [
        testPeaceWord.copyWith(audioAssetPath: 'assets/audio/shalom.mp3'),
        testHouseWord.copyWith(audioAssetPath: 'assets/audio/bayit.mp3'),
      ],
      audioPlayerFactory: () => audioPlayer,
    );
    await tester.pump();

    expect(audioPlayer.playedAssets, ['assets/audio/shalom.mp3']);

    await tester.tap(find.byKey(const ValueKey('sprint-option-0')));
    await tester.pump();
    await tester.pump();

    expect(audioPlayer.playedAssets, [
      'assets/audio/shalom.mp3',
      'assets/audio/bayit.mp3',
    ]);
  });

  testWidgets('stays silent when the next prompt has no audio', (
    WidgetTester tester,
  ) async {
    final audioPlayer = FakeVerbAudioPlayer(
      availableAssets: const {'assets/audio/shalom.mp3'},
    );

    await _pumpSprintScreen(
      tester,
      words: [
        testPeaceWord.copyWith(audioAssetPath: 'assets/audio/shalom.mp3'),
        testHouseWord,
      ],
      audioPlayerFactory: () => audioPlayer,
    );
    await tester.pump();

    expect(audioPlayer.playedAssets, ['assets/audio/shalom.mp3']);

    await tester.tap(find.byKey(const ValueKey('sprint-option-0')));
    await tester.pump();
    await tester.pump();

    expect(audioPlayer.playedAssets, ['assets/audio/shalom.mp3']);
  });
}

Future<void> _pumpSprintScreen(
  WidgetTester tester, {
  List<LearningWord> words = const [testPeaceWord, testHouseWord],
  void Function(LearningWord word)? onWordProgressChanged,
  CreateLearningAudioPlayer? audioPlayerFactory,
  SprintStatsStore? statsStore,
  Duration duration = const Duration(seconds: 60),
}) async {
  await tester.pumpWidget(
    MaterialApp(
      locale: const Locale('uk'),
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: Scaffold(
        body: SprintScreen(
          words: words,
          onWordProgressChanged: onWordProgressChanged ?? (_) {},
          audioPlayerFactory: audioPlayerFactory ?? FakeVerbAudioPlayer.new,
          statsStore: statsStore ?? FakeSprintStatsStore(),
          duration: duration,
          rng: _FixedRandom(),
        ),
      ),
    ),
  );
  await tester.pump();
}

class _FixedRandom implements Random {
  @override
  bool nextBool() => false;

  @override
  double nextDouble() => 0;

  @override
  int nextInt(int max) => 0;
}
