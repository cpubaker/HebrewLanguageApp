import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hebrew_language_flutter/models/generated_practice_text.dart';
import 'package:hebrew_language_flutter/models/learning_word.dart';
import 'package:hebrew_language_flutter/screens/ai_practice_text_screen.dart';
import 'package:hebrew_language_flutter/services/ai_practice_text_service.dart';
import 'package:hebrew_language_flutter/theme/app_theme.dart';

void main() {
  testWidgets('shows generated practice text and target words', (tester) async {
    var flashcardsOpened = false;
    var writingOpened = false;

    await tester.pumpWidget(
      MaterialApp(
        theme: buildLightAppTheme(),
        home: Scaffold(
          body: AiPracticeTextScreen(
            words: const <LearningWord>[
              LearningWord(
                wordId: 'word_book',
                hebrew: 'ספר',
                english: 'book',
                ukrainian: 'книга',
                transcription: 'sefer',
                correct: 0,
                wrong: 0,
              ),
            ],
            textService: const _StaticAiPracticeTextService(
              texts: <GeneratedPracticeText>[
                GeneratedPracticeText(
                  textId: 'ai_text_1',
                  title: 'ספר חדש',
                  hebrew: 'אני קורא ספר חדש.',
                  translation: 'Я читаю нову книгу.',
                  wordIds: <String>['word_book'],
                ),
              ],
            ),
            onOpenFlashcards: () {
              flashcardsOpened = true;
            },
            onOpenWriting: () {
              writingOpened = true;
            },
          ),
        ),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text('Текст зі словами'), findsOneWidget);
    expect(find.text('ספר חדש'), findsOneWidget);
    expect(find.text('אני קורא ספר חדש.'), findsOneWidget);
    expect(find.text('Я читаю нову книгу.'), findsOneWidget);
    expect(find.text('Нове!'), findsOneWidget);
    expect(find.textContaining('книга'), findsWidgets);

    await tester.tap(find.text('Картки'));
    await tester.pump();
    await tester.tap(find.text('Написання'));
    await tester.pump();

    expect(flashcardsOpened, isTrue);
    expect(writingOpened, isTrue);
  });

  testWidgets('shows empty state when service returns no text', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: buildLightAppTheme(),
        home: Scaffold(
          body: AiPracticeTextScreen(
            words: const <LearningWord>[
              LearningWord(
                wordId: 'word_book',
                hebrew: 'ספר',
                english: 'book',
                ukrainian: 'книга',
                transcription: 'sefer',
                correct: 0,
                wrong: 0,
              ),
            ],
            textService: const _StaticAiPracticeTextService(
              texts: <GeneratedPracticeText>[],
            ),
            onOpenFlashcards: () {},
            onOpenWriting: () {},
          ),
        ),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text('Текст ще не згенеровано'), findsOneWidget);
    expect(find.text('Спробувати ще раз'), findsOneWidget);
  });
}

class _StaticAiPracticeTextService implements AiPracticeTextService {
  const _StaticAiPracticeTextService({required this.texts});

  final List<GeneratedPracticeText> texts;

  @override
  Future<List<GeneratedPracticeText>> textsForRequest(
    AiPracticeTextRequest request,
  ) async {
    return texts;
  }
}
