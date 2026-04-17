import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hebrew_language_flutter/models/learning_word.dart';
import 'package:hebrew_language_flutter/screens/words_screen.dart';
import 'package:hebrew_language_flutter/services/audio_playback_awareness.dart';
import 'package:hebrew_language_flutter/services/learning_audio_player.dart';

void main() {
  testWidgets('plays word audio from the list without opening details', (
    WidgetTester tester,
  ) async {
    final audioPlayer = _FakeLearningAudioPlayer(assetExistsResult: true);

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: WordsScreen(
            words: const [
              LearningWord(
                wordId: 'word_man',
                hebrew: 'איש',
                english: 'man',
                transcription: 'ish',
                audioAssetPath:
                    'assets/learning/input/audio/words/word_man.mp3',
                correct: 0,
                wrong: 0,
              ),
            ],
            audioPlayerFactory: () => audioPlayer,
          ),
        ),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.byTooltip('Увімкнути вимову слова'), findsOneWidget);

    await tester.tap(find.text('Аудіо'));
    await tester.pumpAndSettle();

    expect(audioPlayer.playedAssets, [
      'assets/learning/input/audio/words/word_man.mp3',
    ]);
    expect(find.text('Вимова'), findsNothing);
  });

  testWidgets('keeps word audio disabled until mp3 exists', (
    WidgetTester tester,
  ) async {
    final audioPlayer = _FakeLearningAudioPlayer(assetExistsResult: false);

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: WordsScreen(
            words: const [
              LearningWord(
                wordId: 'word_man',
                hebrew: 'איש',
                english: 'man',
                transcription: 'ish',
                audioAssetPath:
                    'assets/learning/input/audio/words/word_man.mp3',
                correct: 0,
                wrong: 0,
              ),
            ],
            audioPlayerFactory: () => audioPlayer,
          ),
        ),
      ),
    );

    await tester.tap(find.byTooltip('Відкрити слово'));
    await tester.pumpAndSettle();

    expect(find.text('Вимова'), findsNothing);

    final disabledButton = tester.widget<IconButton>(
      find.byWidgetPredicate(
        (widget) =>
            widget is IconButton &&
            widget.tooltip == 'Аудіо для слова ще недоступне',
      ),
    );
    expect(disabledButton.onPressed, isNull);
    expect(audioPlayer.playedAssets, isEmpty);
  });

  testWidgets(
    'shows a muted-volume hint before playback when awareness requests it',
    (WidgetTester tester) async {
      final audioPlayer = _FakeLearningAudioPlayer(assetExistsResult: true);

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: WordsScreen(
              words: const [
                LearningWord(
                  wordId: 'word_man',
                  hebrew: 'ЧђЧ™Ч©',
                  english: 'man',
                  transcription: 'ish',
                  audioAssetPath:
                      'assets/learning/input/audio/words/word_man.mp3',
                  correct: 0,
                  wrong: 0,
                ),
              ],
              audioPlayerFactory: () => audioPlayer,
              audioPlaybackAwareness: _FakeAudioPlaybackAwareness(
                hint: AudioPlaybackHint.mediaVolumeMuted,
              ),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();
      await tester.tap(find.text('РђСѓРґС–Рѕ'));
      await tester.pump();

      expect(
        find.text(
          'Звук вимкнений. Підніміть гучність медіа кнопками збоку.',
        ),
        findsOneWidget,
      );
      expect(audioPlayer.playedAssets, [
        'assets/learning/input/audio/words/word_man.mp3',
      ]);
    },
  );

  testWidgets('opens word details from the trailing arrow', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: WordsScreen(
            words: const [
              LearningWord(
                wordId: 'word_man',
                hebrew: 'איש',
                english: 'man',
                ukrainian: 'чоловік',
                transcription: 'ish',
                correct: 0,
                wrong: 0,
              ),
            ],
            audioPlayerFactory: () =>
                _FakeLearningAudioPlayer(assetExistsResult: false),
          ),
        ),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text('Вимова'), findsNothing);

    await tester.tap(find.byTooltip('Відкрити слово'));
    await tester.pumpAndSettle();

    expect(find.text('Вимова'), findsNothing);
    expect(find.text('чоловік'), findsWidgets);
    expect(find.text('ID: word_man'), findsOneWidget);
  });

  testWidgets(
    'shows scroll-to-top action after scrolling the vocabulary list',
    (WidgetTester tester) async {
      final words = List<LearningWord>.generate(
        30,
        (index) => LearningWord(
          wordId: 'word_$index',
          hebrew: 'מילה $index',
          english: 'Word $index',
          ukrainian: 'Слово $index',
          transcription: 'word $index',
          correct: 0,
          wrong: 0,
        ),
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: WordsScreen(
              words: words,
              audioPlayerFactory: () =>
                  _FakeLearningAudioPlayer(assetExistsResult: false),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      Finder scrollToTopOpacity() => find.ancestor(
        of: find.byIcon(Icons.vertical_align_top_rounded),
        matching: find.byType(AnimatedOpacity),
      );

      expect(
        tester.widget<AnimatedOpacity>(scrollToTopOpacity()).opacity,
        equals(0),
      );

      await tester.drag(find.byType(CustomScrollView), const Offset(0, -900));
      await tester.pumpAndSettle();

      expect(
        tester.widget<AnimatedOpacity>(scrollToTopOpacity()).opacity,
        equals(1),
      );

      await tester.tap(find.byIcon(Icons.vertical_align_top_rounded));
      await tester.pumpAndSettle();

      expect(
        tester.widget<AnimatedOpacity>(scrollToTopOpacity()).opacity,
        equals(0),
      );
    },
  );
}

class _FakeLearningAudioPlayer implements LearningAudioPlayer {
  _FakeLearningAudioPlayer({required this.assetExistsResult});

  final bool assetExistsResult;
  final List<String> playedAssets = <String>[];

  @override
  Stream<bool> get isPlayingStream => const Stream<bool>.empty();

  @override
  Future<bool> assetExists(String assetPath) async => assetExistsResult;

  @override
  Future<bool> prepareAsset(String assetPath) async => assetExistsResult;

  @override
  Future<void> dispose() async {}

  @override
  Future<void> playAsset(String assetPath) async {
    playedAssets.add(assetPath);
  }

  @override
  Future<void> stop() async {}
}

class _FakeAudioPlaybackAwareness implements AudioPlaybackAwareness {
  _FakeAudioPlaybackAwareness({this.hint});

  final AudioPlaybackHint? hint;

  @override
  Future<AudioPlaybackHint?> checkBeforePlayback() async => hint;
}
