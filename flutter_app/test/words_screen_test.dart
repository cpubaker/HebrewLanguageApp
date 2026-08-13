import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hebrew_language_flutter/l10n/generated/app_localizations.dart';
import 'package:hebrew_language_flutter/models/learning_context.dart';
import 'package:hebrew_language_flutter/models/learning_word.dart';
import 'package:hebrew_language_flutter/screens/words_screen.dart';
import 'package:hebrew_language_flutter/services/audio_playback_awareness.dart';
import 'package:hebrew_language_flutter/services/learning_audio_player.dart';

import 'support/fakes.dart';

const _wordAudioAsset = 'assets/learning/input/audio/words/word_man.mp3';

void main() {
  testWidgets('plays word audio from the list without opening details', (
    WidgetTester tester,
  ) async {
    final audioPlayer = FakeLearningAudioPlayer(assetExistsResult: true);

    await _pumpWordsScreen(
      tester,
      words: [_wordMan(audioAssetPath: _wordAudioAsset)],
      audioPlayerFactory: () => audioPlayer,
    );

    final listAudioButton = find.byKey(
      const ValueKey('word-list-audio-button-word_man'),
    );

    expect(listAudioButton, findsOneWidget);

    await tester.tap(listAudioButton);
    await tester.pumpAndSettle();

    expect(audioPlayer.playedAssets, [_wordAudioAsset]);
    expect(audioPlayer.preparedAssets, isEmpty);
    expect(find.text('Вимова'), findsNothing);
  });

  testWidgets('keeps word audio disabled until mp3 exists', (
    WidgetTester tester,
  ) async {
    final audioPlayer = FakeLearningAudioPlayer(assetExistsResult: false);

    await _pumpWordsScreen(
      tester,
      words: [_wordMan(audioAssetPath: _wordAudioAsset)],
      audioPlayerFactory: () => audioPlayer,
    );

    await _openWordDetails(tester);

    expect(find.text('Вимова'), findsNothing);

    final disabledButton = tester.widget<IconButton>(
      find.byKey(const ValueKey('word-detail-audio-button-word_man')),
    );
    expect(disabledButton.onPressed, isNull);
    expect(audioPlayer.playedAssets, isEmpty);
  });

  testWidgets(
    'shows a muted-volume hint before playback when awareness requests it',
    (WidgetTester tester) async {
      final audioPlayer = FakeLearningAudioPlayer(assetExistsResult: true);

      await _pumpWordsScreen(
        tester,
        words: [_wordMan(audioAssetPath: _wordAudioAsset)],
        audioPlayerFactory: () => audioPlayer,
        audioPlaybackAwareness: FakeAudioPlaybackAwareness(
          hint: AudioPlaybackHint.mediaVolumeMuted,
        ),
      );

      await tester.tap(
        find.byKey(const ValueKey('word-list-audio-button-word_man')),
      );
      await tester.pump();

      expect(
        find.text('Звук вимкнений. Підніміть гучність медіа кнопками збоку.'),
        findsOneWidget,
      );
      expect(audioPlayer.playedAssets, [_wordAudioAsset]);
    },
  );

  testWidgets('opens word details from the trailing arrow', (
    WidgetTester tester,
  ) async {
    await _pumpWordsScreen(tester, words: [_wordMan(ukrainian: 'чоловік')]);

    expect(find.text('Вимова'), findsNothing);

    await _openWordDetails(tester);

    expect(find.text('Вимова'), findsNothing);
    expect(find.text('чоловік'), findsWidgets);
    expect(find.text('ID: word_man'), findsOneWidget);
  });

  testWidgets('word details sheet expands for context-heavy entries', (
    WidgetTester tester,
  ) async {
    tester.view.physicalSize = const Size(393, 852);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final contexts = List<LearningContext>.generate(
      5,
      (index) => LearningContext(
        contextId: 'ctx_$index',
        hebrew: 'המכונית עומדת מול הבית מספר $index.',
        translation:
            'The car is parked on a narrow street near the shop, context $index.',
      ),
    );

    await _pumpWordsScreen(tester, words: [_wordCar(contexts: contexts)]);

    await tester.tap(find.byIcon(Icons.arrow_forward_ios_rounded));
    await tester.pumpAndSettle();

    final sheetRect = tester.getRect(find.byType(BottomSheet));
    expect(sheetRect.height, greaterThan(600));
  });

  testWidgets('prepares detail word audio before playback', (
    WidgetTester tester,
  ) async {
    final audioPlayer = FakeLearningAudioPlayer(assetExistsResult: true);

    await _pumpWordsScreen(
      tester,
      words: [_wordMan(ukrainian: 'чоловік', audioAssetPath: _wordAudioAsset)],
      audioPlayerFactory: () => audioPlayer,
    );

    await _openWordDetails(tester);

    await tester.tap(
      find.byKey(const ValueKey('word-detail-audio-button-word_man')),
    );
    await tester.pumpAndSettle();

    expect(audioPlayer.preparedAssets, [_wordAudioAsset]);
    expect(audioPlayer.playedAssets, [_wordAudioAsset]);
  });

  testWidgets('cycles a new dictionary word through learning statuses', (
    WidgetTester tester,
  ) async {
    LearningWord? changedWord;

    await _pumpWordsScreen(
      tester,
      words: [_wordMan(ukrainian: 'чоловік')],
      onWordProgressChanged: (word) {
        changedWord = word;
      },
    );
    expect(find.text('Не знаю'), findsOneWidget);

    await tester.tap(find.text('Не знаю'));
    await tester.pump();

    expect(changedWord, isNotNull);
    expect(changedWord!.wordId, 'word_man');
    expect(changedWord!.correct, 0);
    expect(changedWord!.wrong, 0);
    expect(changedWord!.lastReviewedAt, isNotNull);
    expect(changedWord!.lastReviewCorrect, isFalse);
    expect(find.text('Вчу'), findsOneWidget);
    expect(find.text('Повторити · 1'), findsOneWidget);

    await tester.tap(find.text('Вчу'));
    await tester.pumpAndSettle();

    expect(find.text('ID: word_man'), findsNothing);
    expect(changedWord!.lastCorrect, isNotNull);
    expect(changedWord!.lastReviewedAt, isNotNull);
    expect(changedWord!.lastReviewCorrect, isTrue);
    expect(find.text('Знаю'), findsOneWidget);
    expect(find.text('Вивчені · 1'), findsOneWidget);

    await tester.tap(find.text('Знаю'));
    await tester.pumpAndSettle();

    expect(find.text('ID: word_man'), findsNothing);
    expect(changedWord!.lastCorrect, isNull);
    expect(changedWord!.lastReviewedAt, isNull);
    expect(changedWord!.lastReviewCorrect, isNull);
    expect(find.text('Не знаю'), findsOneWidget);
    expect(find.text('Нові · 1'), findsOneWidget);
  });

  testWidgets('cycles a known dictionary word back to new', (
    WidgetTester tester,
  ) async {
    LearningWord? changedWord;

    await _pumpWordsScreen(
      tester,
      words: [
        _wordMan(ukrainian: 'чоловік', correct: 4, lastReviewCorrect: true),
      ],
      onWordProgressChanged: (word) {
        changedWord = word;
      },
    );
    expect(find.text('Знаю'), findsOneWidget);

    await tester.tap(find.text('Знаю'));
    await tester.pump();

    expect(changedWord, isNotNull);
    expect(changedWord!.wordId, 'word_man');
    expect(changedWord!.correct, 0);
    expect(changedWord!.wrong, 0);
    expect(changedWord!.lastCorrect, isNull);
    expect(changedWord!.lastReviewedAt, isNull);
    expect(changedWord!.lastReviewCorrect, isNull);
    expect(find.text('ID: word_man'), findsNothing);
    expect(find.text('Не знаю'), findsOneWidget);
    expect(find.text('Нові · 1'), findsOneWidget);
  });

  testWidgets(
    'shares a single audio player across all word cards in the list',
    (WidgetTester tester) async {
      final factory = FakeLearningAudioPlayerFactory();
      final wordsWithAudio = List<LearningWord>.generate(
        12,
        (index) => LearningWord(
          wordId: 'word_$index',
          hebrew: 'מילה $index',
          english: 'Word $index',
          ukrainian: 'Слово $index',
          transcription: 'word $index',
          audioAssetPath:
              'assets/learning/input/audio/words/word_$index.mp3',
          correct: 0,
          wrong: 0,
        ),
      );

      await _pumpWordsScreen(
        tester,
        words: wordsWithAudio,
        audioPlayerFactory: factory.create,
      );

      expect(factory.players, hasLength(1));
    },
  );

  testWidgets(
    'shows scroll-to-top action after scrolling the vocabulary list',
    (WidgetTester tester) async {
      await _pumpWordsScreen(tester, words: _manyWords());

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

Future<void> _pumpWordsScreen(
  WidgetTester tester, {
  required List<LearningWord> words,
  CreateLearningAudioPlayer? audioPlayerFactory,
  AudioPlaybackAwareness audioPlaybackAwareness =
      const NoopAudioPlaybackAwareness(),
  ValueChanged<LearningWord>? onWordProgressChanged,
}) async {
  await tester.pumpWidget(
    MaterialApp(
      locale: const Locale('uk'),
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: Scaffold(
        body: WordsScreen(
          words: words,
          audioPlayerFactory:
              audioPlayerFactory ??
              () => FakeLearningAudioPlayer(assetExistsResult: false),
          audioPlaybackAwareness: audioPlaybackAwareness,
          onWordProgressChanged: onWordProgressChanged,
        ),
      ),
    ),
  );
  await tester.pumpAndSettle();
}

Future<void> _openWordDetails(WidgetTester tester) async {
  await tester.tap(find.byTooltip('Відкрити слово'));
  await tester.pumpAndSettle();
}

LearningWord _wordMan({
  String ukrainian = '',
  String? audioAssetPath,
  int correct = 0,
  int wrong = 0,
  bool? lastReviewCorrect,
}) {
  return LearningWord(
    wordId: 'word_man',
    hebrew: 'איש',
    english: 'man',
    ukrainian: ukrainian,
    transcription: 'ish',
    audioAssetPath: audioAssetPath,
    correct: correct,
    wrong: wrong,
    lastReviewCorrect: lastReviewCorrect,
  );
}

LearningWord _wordCar({required List<LearningContext> contexts}) {
  return LearningWord(
    wordId: 'word_car',
    hebrew: 'מכונית',
    english: 'car',
    ukrainian: 'car',
    transcription: 'mekhonit',
    correct: 0,
    wrong: 0,
    contexts: contexts,
  );
}

List<LearningWord> _manyWords() {
  return List<LearningWord>.generate(
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
}
