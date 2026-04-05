import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hebrew_language_flutter/models/learning_bundle.dart';
import 'package:hebrew_language_flutter/models/lesson_document.dart';
import 'package:hebrew_language_flutter/screens/verbs_screen.dart';
import 'package:hebrew_language_flutter/services/lesson_document_loader.dart';
import 'package:hebrew_language_flutter/services/verb_audio_player.dart';

void main() {
  testWidgets('filters verb lessons by loaded lesson title', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: VerbsScreen(
            lessons: const [
              LessonEntry(
                assetPath: 'assets/learning/input/verbs/01_walk.md',
                displayName: '01 Walk',
              ),
              LessonEntry(
                assetPath: 'assets/learning/input/verbs/02_see.md',
                displayName: '02 See',
              ),
            ],
            documentLoader: _FakeLessonDocumentLoader(),
            audioPlayerFactory: () => _FakeVerbAudioPlayer(),
          ),
        ),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text('Ходити'), findsOneWidget);
    expect(find.text('Бачити'), findsOneWidget);
    expect(find.byIcon(Icons.search_rounded), findsWidgets);

    await tester.tap(find.byTooltip('Показати пошук'));
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(EditableText).last, 'ход');
    await tester.pumpAndSettle();

    expect(find.text('Знайдено: 1 із 2'), findsOneWidget);
    expect(find.text('Ходити'), findsOneWidget);
    expect(find.text('Бачити'), findsNothing);
  });
}

class _FakeLessonDocumentLoader implements LessonDocumentLoader {
  @override
  Future<LessonDocument> load(String assetPath) async {
    if (assetPath.endsWith('01_walk.md')) {
      return const LessonDocument(title: 'Ходити', body: 'Stub');
    }

    if (assetPath.endsWith('02_see.md')) {
      return const LessonDocument(title: 'Бачити', body: 'Stub');
    }

    return const LessonDocument(title: 'Stub', body: 'Stub');
  }
}

class _FakeVerbAudioPlayer implements VerbAudioPlayer {
  @override
  Stream<bool> get isPlayingStream => const Stream<bool>.empty();

  @override
  Future<bool> assetExists(String assetPath) async => false;

  @override
  Future<void> dispose() async {}

  @override
  Future<void> playAsset(String assetPath) async {}

  @override
  Future<void> stop() async {}
}
