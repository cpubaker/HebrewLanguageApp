import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hebrew_language_flutter/app.dart';
import 'package:hebrew_language_flutter/models/guide_lesson_status.dart';
import 'package:hebrew_language_flutter/models/learning_bundle.dart';
import 'package:hebrew_language_flutter/models/learning_word.dart';
import 'package:hebrew_language_flutter/models/lesson_document.dart';
import 'package:hebrew_language_flutter/screens/guide_screen.dart';
import 'package:hebrew_language_flutter/services/guide_progress_store.dart';
import 'package:hebrew_language_flutter/services/lesson_document_loader.dart';
import 'package:hebrew_language_flutter/services/learning_bundle_loader.dart';
import 'package:hebrew_language_flutter/services/reading_progress_store.dart';
import 'package:hebrew_language_flutter/services/verb_audio_player.dart';
import 'package:hebrew_language_flutter/services/word_progress_store.dart';

void main() {
  testWidgets('guide list allows cycling lesson status manually', (
    WidgetTester tester,
  ) async {
    final guideStore = FakeGuideProgressStore();

    await tester.pumpWidget(
      HebrewFlutterApp(
        loader: _GuideOnlyBundleLoader(),
        documentLoader: _GuideDocumentLoader(),
        progressStore: FakeWordProgressStore(),
        guideProgressStore: guideStore,
        readingProgressStore: FakeReadingProgressStore(),
        audioPlayerFactory: () => FakeVerbAudioPlayer(),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.byIcon(Icons.menu_book_outlined));
    await tester.pumpAndSettle();

    expect(find.text('Не прочитано'), findsOneWidget);

    await tester.tap(find.byTooltip('Змінити статус уроку'));
    await tester.pumpAndSettle();

    expect(find.text('Вивчається'), findsWidgets);

    await tester.tap(find.byTooltip('Змінити статус уроку'));
    await tester.pumpAndSettle();

    expect(
      guideStore.lessonStatuses['assets/learning/input/guide/01_intro_alphabet.md'],
      GuideLessonStatus.read,
    );
    expect(find.text('Прочитано'), findsWidgets);
  });

  testWidgets('guide screen filters lessons by section and summary search', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: GuideScreen(
            lessons: const [
              LessonEntry(
                assetPath: 'assets/learning/input/guide/42_infinitive_constructions.md',
                displayName: '42 Infinitive Constructions',
                lessonId: 'infinitive_constructions',
                sectionId: 'verbs',
                sectionLabel: 'Дієслова',
              ),
              LessonEntry(
                assetPath: 'assets/learning/input/guide/49_register_formal_vs_spoken.md',
                displayName: '49 Register Formal Vs Spoken',
                lessonId: 'register_formal_spoken',
                sectionId: 'spoken',
                sectionLabel: 'Жива мова',
              ),
            ],
            documentLoader: _GuideSearchDocumentLoader(),
            lessonStatuses: const <String, GuideLessonStatus>{},
            onStatusChanged: (_, _) {},
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Інфінітив у конструкціях'), findsOneWidget);
    expect(find.text('Формально і по-живому'), findsOneWidget);

    await tester.tap(find.widgetWithText(ChoiceChip, 'Жива мова'));
    await tester.pumpAndSettle();

    expect(find.text('Формально і по-живому'), findsOneWidget);
    expect(find.text('Інфінітив у конструкціях'), findsNothing);

    await tester.tap(find.byTooltip('Показати пошук'));
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(EditableText).last, 'природно');
    await tester.pumpAndSettle();

    expect(find.text('Знайдено: 1 із 2'), findsOneWidget);
    expect(find.text('Формально і по-живому'), findsOneWidget);
  });

  testWidgets('guide lesson becomes studying when opened', (
    WidgetTester tester,
  ) async {
    GuideLessonStatus? latestStatus;

    await tester.pumpWidget(
      MaterialApp(
        home: GuideDetailScreen(
          lesson: const LessonEntry(
            assetPath: 'assets/learning/input/guide/01_intro_alphabet.md',
            displayName: '01 Intro Alphabet',
            lessonId: 'intro_alphabet',
            sectionId: 'basics',
            sectionLabel: 'База',
            relatedIds: ['reading_rules'],
          ),
          allLessons: const [
            LessonEntry(
              assetPath: 'assets/learning/input/guide/01_intro_alphabet.md',
              displayName: '01 Intro Alphabet',
              lessonId: 'intro_alphabet',
              sectionId: 'basics',
              sectionLabel: 'База',
              relatedIds: ['reading_rules'],
            ),
            LessonEntry(
              assetPath: 'assets/learning/input/guide/02_reading_rules.md',
              displayName: '02 Reading Rules',
              lessonId: 'reading_rules',
              sectionId: 'basics',
              sectionLabel: 'База',
            ),
          ],
          documentLoader: _GuideDocumentLoader(),
          initialStatus: GuideLessonStatus.unread,
          onStatusChanged: (status) {
            latestStatus = status;
          },
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(latestStatus, GuideLessonStatus.studying);
    expect(find.text('Вивчається'), findsWidgets);
    expect(find.text('У цій статті'), findsOneWidget);
    expect(find.text('Наступна тема'), findsOneWidget);
    expect(find.text('Пов’язані теми'), findsOneWidget);
    expect(find.text('Правила читання'), findsWidgets);
  });

  testWidgets('guide lesson is marked as read after scrolling to the end', (
    WidgetTester tester,
  ) async {
    GuideLessonStatus? latestStatus;

    await tester.pumpWidget(
      MaterialApp(
        home: GuideDetailScreen(
          lesson: const LessonEntry(
            assetPath: 'assets/learning/input/guide/01_intro_alphabet.md',
            displayName: '01 Intro Alphabet',
          ),
          documentLoader: _LongGuideDocumentLoader(),
          initialStatus: GuideLessonStatus.studying,
          onStatusChanged: (status) {
            latestStatus = status;
          },
        ),
      ),
    );
    await tester.pumpAndSettle();

    await tester.scrollUntilVisible(
      find.text('Paragraph 80 about Hebrew grammar.'),
      400,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.pumpAndSettle();

    expect(latestStatus, GuideLessonStatus.read);
    expect(find.text('Прочитано'), findsWidgets);
  });

  testWidgets('guide adjacent navigation uses lesson titles instead of file labels', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: GuideDetailScreen(
          lesson: const LessonEntry(
            assetPath: 'assets/learning/input/guide/02_reading_rules.md',
            displayName: '02 Reading Rules',
            lessonId: 'reading_rules',
            sectionId: 'basics',
            sectionLabel: 'База',
          ),
          allLessons: const [
            LessonEntry(
              assetPath: 'assets/learning/input/guide/01_intro_alphabet.md',
              displayName: '01 Intro Alphabet',
              lessonId: 'intro_alphabet',
              sectionId: 'basics',
              sectionLabel: 'База',
            ),
            LessonEntry(
              assetPath: 'assets/learning/input/guide/02_reading_rules.md',
              displayName: '02 Reading Rules',
              lessonId: 'reading_rules',
              sectionId: 'basics',
              sectionLabel: 'База',
            ),
            LessonEntry(
              assetPath: 'assets/learning/input/guide/03_smixut.md',
              displayName: '03 Smixut',
              lessonId: 'smixut',
              sectionId: 'basics',
              sectionLabel: 'База',
            ),
          ],
          documentLoader: _GuideAdjacentTitlesDocumentLoader(),
          initialStatus: GuideLessonStatus.studying,
          onStatusChanged: (_) {},
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Абетка'), findsOneWidget);
    expect(find.text('Сміхут'), findsOneWidget);
    expect(find.text('01 Intro Alphabet'), findsNothing);
    expect(find.text('03 Smixut'), findsNothing);
  });

  testWidgets('guide related topics deduplicate metadata and markdown matches', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: GuideDetailScreen(
          lesson: const LessonEntry(
            assetPath: 'assets/learning/input/guide/01_intro_alphabet.md',
            displayName: '01 Intro Alphabet',
            lessonId: 'intro_alphabet',
            sectionId: 'basics',
            sectionLabel: 'База',
            relatedIds: ['reading_rules'],
          ),
          allLessons: const [
            LessonEntry(
              assetPath: 'assets/learning/input/guide/01_intro_alphabet.md',
              displayName: '01 Intro Alphabet',
              lessonId: 'intro_alphabet',
              sectionId: 'basics',
              sectionLabel: 'База',
              relatedIds: ['reading_rules'],
            ),
            LessonEntry(
              assetPath: 'assets/learning/input/guide/02_reading_rules.md',
              displayName: '02 Reading Rules',
              lessonId: 'reading_rules',
              sectionId: 'basics',
              sectionLabel: 'База',
            ),
          ],
          documentLoader: _GuideRelatedTopicsCleanupLoader(),
          initialStatus: GuideLessonStatus.studying,
          onStatusChanged: (_) {},
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Пов’язані теми'), findsOneWidget);
    expect(find.text('Правила читання'), findsOneWidget);
    expect(find.text('Неіснуюча тема'), findsNothing);
  });

  testWidgets('guide back button returns to guide list after opening adjacent lesson', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: GuideScreen(
            lessons: const [
              LessonEntry(
                assetPath: 'assets/learning/input/guide/01_intro_alphabet.md',
                displayName: '01 Intro Alphabet',
                lessonId: 'intro_alphabet',
                sectionId: 'basics',
                sectionLabel: 'База',
              ),
              LessonEntry(
                assetPath: 'assets/learning/input/guide/02_reading_rules.md',
                displayName: '02 Reading Rules',
                lessonId: 'reading_rules',
                sectionId: 'basics',
                sectionLabel: 'База',
              ),
              LessonEntry(
                assetPath: 'assets/learning/input/guide/03_whole_alphabet.md',
                displayName: '03 Whole Alphabet',
                lessonId: 'whole_alphabet',
                sectionId: 'basics',
                sectionLabel: 'База',
              ),
            ],
            documentLoader: _GuideNavigationFlowDocumentLoader(),
            lessonStatuses: const <String, GuideLessonStatus>{},
            onStatusChanged: (_, _) {},
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('Правила читання'));
    await tester.pumpAndSettle();

    expect(find.text('Увесь алфавіт'), findsOneWidget);
    await tester.tap(find.text('Увесь алфавіт'));
    await tester.pumpAndSettle();

    expect(find.text('Увесь алфавіт'), findsWidgets);
    await tester.pageBack();
    await tester.pumpAndSettle();

    expect(find.text('Довідник'), findsOneWidget);
    expect(find.text('Правила читання'), findsOneWidget);
    expect(find.text('Абетка'), findsOneWidget);
  });
}

class _GuideOnlyBundleLoader implements LearningBundleLoader {
  @override
  Future<LearningBundle> load() async {
    return const LearningBundle(
      words: <LearningWord>[],
      guideLessons: [
        LessonEntry(
          assetPath: 'assets/learning/input/guide/01_intro_alphabet.md',
          displayName: '01 Intro Alphabet',
          sectionId: 'basics',
          sectionLabel: 'База',
        ),
      ],
      verbLessons: <LessonEntry>[],
      readingLessons: <LessonEntry>[],
    );
  }
}

class _GuideDocumentLoader implements LessonDocumentLoader {
  @override
  Future<LessonDocument> load(String assetPath) async {
    if (assetPath.contains('02_reading_rules')) {
      return const LessonDocument(
        title: 'Правила читання',
        summary: 'Що відбувається з буквами та голосними в реальному читанні.',
        headings: ['Основна ідея'],
        body: '## Основна ідея\n\n- Дивимось на шаблон слова.',
      );
    }

    return const LessonDocument(
      title: 'Alphabet Basics',
      summary: 'Коротка довідка про напрямок письма та базову логіку читання.',
      headings: ['First concept'],
      relatedTopics: ['Правила читання'],
      body: '## First concept\n\n- Hebrew is read from right to left.',
    );
  }
}

class _GuideSearchDocumentLoader implements LessonDocumentLoader {
  @override
  Future<LessonDocument> load(String assetPath) async {
    if (assetPath.contains('42_infinitive')) {
      return const LessonDocument(
        title: 'Інфінітив у конструкціях',
        summary: 'Як будувати моделі на кшталт хочу зробити і почав говорити.',
        headings: ['Основна модель'],
        body: '## Основна модель\n\nМодель עם інфінітив.',
      );
    }

    return const LessonDocument(
      title: 'Формально і по-живому',
      summary: 'Як сказати природно, а не книжково.',
      headings: ['Живі заміни'],
      body: '## Живі заміни\n\nЦя стаття показує, як сказати природно.',
    );
  }
}

class _LongGuideDocumentLoader implements LessonDocumentLoader {
  @override
  Future<LessonDocument> load(String assetPath) async {
    final body = List<String>.generate(
      80,
      (index) => 'Paragraph ${index + 1} about Hebrew grammar.',
    ).join('\n\n');

    return LessonDocument(
      title: 'Long Lesson',
      body: body,
    );
  }
}

class _GuideAdjacentTitlesDocumentLoader implements LessonDocumentLoader {
  @override
  Future<LessonDocument> load(String assetPath) async {
    if (assetPath.contains('01_intro_alphabet')) {
      return const LessonDocument(
        title: 'Абетка',
        body: '## Основна ідея\n\n- Знайомимось з буквами.',
      );
    }

    if (assetPath.contains('03_smixut')) {
      return const LessonDocument(
        title: 'Сміхут',
        body: '## Основна ідея\n\n- Дивимось на зв’язку двох іменників.',
      );
    }

    return const LessonDocument(
      title: 'Правила читання',
      body: '## Основна ідея\n\n- Дивимось на шаблон слова.',
    );
  }
}

class _GuideRelatedTopicsCleanupLoader implements LessonDocumentLoader {
  @override
  Future<LessonDocument> load(String assetPath) async {
    if (assetPath.contains('02_reading_rules')) {
      return const LessonDocument(
        title: 'Правила читання',
        body: '## Основна ідея\n\n- Дивимось на нікуд і шаблони.',
      );
    }

    return const LessonDocument(
      title: 'Абетка',
      headings: ['Основна ідея'],
      relatedTopics: ['Правила читання', 'Неіснуюча тема'],
      body: '## Основна ідея\n\n- Вчимо базові літери.',
    );
  }
}

class _GuideNavigationFlowDocumentLoader implements LessonDocumentLoader {
  @override
  Future<LessonDocument> load(String assetPath) async {
    if (assetPath.contains('01_intro_alphabet')) {
      return const LessonDocument(
        title: 'Абетка',
        summary: 'Перший вхід у букви.',
        headings: ['Основна ідея'],
        body: '## Основна ідея\n\n- Бачимо базові літери.',
      );
    }

    if (assetPath.contains('03_whole_alphabet')) {
      return const LessonDocument(
        title: 'Увесь алфавіт',
        summary: 'Усі літери в одному місці.',
        headings: ['Основна ідея'],
        body: '## Основна ідея\n\n- Збираємо всю абетку.',
      );
    }

    return const LessonDocument(
      title: 'Правила читання',
      summary: 'Як читати нікуд і базові шаблони.',
      headings: ['Основна ідея'],
      body: '## Основна ідея\n\n- Дивимось на нікуд.',
    );
  }
}

class FakeGuideProgressStore implements GuideProgressStore {
  FakeGuideProgressStore({
    Map<String, GuideLessonStatus>? initialStatuses,
  }) : lessonStatuses = <String, GuideLessonStatus>{...?initialStatuses};

  final Map<String, GuideLessonStatus> lessonStatuses;

  @override
  Future<Map<String, GuideLessonStatus>> loadLessonStatuses() async {
    return Map<String, GuideLessonStatus>.from(lessonStatuses);
  }

  @override
  Future<void> setLessonStatus(
    String assetPath,
    GuideLessonStatus status,
  ) async {
    if (status == GuideLessonStatus.unread) {
      lessonStatuses.remove(assetPath);
    } else {
      lessonStatuses[assetPath] = status;
    }
  }
}

class FakeReadingProgressStore implements ReadingProgressStore {
  @override
  Future<Map<String, GuideLessonStatus>> loadLessonStatuses() async {
    return <String, GuideLessonStatus>{};
  }

  @override
  Future<void> setLessonStatus(
    String assetPath,
    GuideLessonStatus status,
  ) async {}
}

class FakeWordProgressStore implements WordProgressStore {
  @override
  Future<Map<String, StoredWordProgress>> load() async {
    return <String, StoredWordProgress>{};
  }

  @override
  Future<void> saveWord(LearningWord word) async {}
}

class FakeVerbAudioPlayer implements VerbAudioPlayer {
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
