import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hebrew_language_flutter/models/learning_bundle.dart';
import 'package:hebrew_language_flutter/models/learning_context.dart';
import 'package:hebrew_language_flutter/models/learning_word.dart';
import 'package:hebrew_language_flutter/models/lesson_document.dart';
import 'package:hebrew_language_flutter/screens/home_screen.dart';
import 'package:hebrew_language_flutter/services/learning_audio_player.dart';
import 'package:hebrew_language_flutter/services/lesson_document_loader.dart';
import 'package:hebrew_language_flutter/theme/app_theme.dart';

void main() {
  testWidgets('shows the word of the day on the home screen', (tester) async {
    final audioPlayer = _FakeLearningAudioPlayer();

    await tester.pumpWidget(
      MaterialApp(
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
            documentLoader: _FakeLessonDocumentLoader(),
            onOpenWords: () {},
            onOpenFlashcards: (_) {},
            onOpenWriting: () {},
            onOpenSprint: () {},
            onOpenGuide: () {},
            onOpenVerbs: () {},
            onOpenReading: () {},
            onOpenReadingLesson: (_) {},
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

class _FakeLearningAudioPlayer implements LearningAudioPlayer {
  final List<String> playedAssets = <String>[];
  final _isPlayingController = StreamController<bool>.broadcast();

  @override
  Stream<bool> get isPlayingStream => _isPlayingController.stream;

  @override
  Future<bool> assetExists(String assetPath) async => true;

  @override
  Future<bool> prepareAsset(String assetPath) async => true;

  @override
  Future<void> playAsset(String assetPath) async {
    playedAssets.add(assetPath);
    _isPlayingController.add(true);
  }

  @override
  Future<void> stop() async {
    _isPlayingController.add(false);
  }

  @override
  Future<void> dispose() async {
    await _isPlayingController.close();
  }
}

class _FakeLessonDocumentLoader implements LessonDocumentLoader {
  @override
  Future<LessonDocument> load(String assetPath) async {
    return const LessonDocument(title: 'Title', body: 'Body');
  }
}
