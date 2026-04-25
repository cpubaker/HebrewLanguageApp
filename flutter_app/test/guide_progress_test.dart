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

const _unreadLabel =
    '\u041d\u0435 \u043f\u0440\u043e\u0447\u0438\u0442\u0430\u043d\u043e';
const _studyingLabel =
    '\u0412\u0438\u0432\u0447\u0430\u0454\u0442\u044c\u0441\u044f';
const _readLabel = '\u041f\u0440\u043e\u0447\u0438\u0442\u0430\u043d\u043e';
const _guideTitle = '\u0414\u043e\u0432\u0456\u0434\u043d\u0438\u043a';
const _outlineHeading =
    '\u0423 \u0446\u0456\u0439 \u0441\u0442\u0430\u0442\u0442\u0456';
const _nextLessonLabel =
    '\u041d\u0430\u0441\u0442\u0443\u043f\u043d\u0430 \u0442\u0435\u043c\u0430';
const _changeStatusTooltip =
    '\u0417\u043c\u0456\u043d\u0438\u0442\u0438 \u0441\u0442\u0430\u0442\u0443\u0441 \u0443\u0440\u043e\u043a\u0443';
const _openSectionFilterTooltip =
    '\u0412\u0456\u0434\u043a\u0440\u0438\u0442\u0438 \u0444\u0456\u043b\u044c\u0442\u0440 \u0441\u0435\u043a\u0446\u0456\u0439';
const _showSearchTooltip =
    '\u041f\u043e\u043a\u0430\u0437\u0430\u0442\u0438 \u043f\u043e\u0448\u0443\u043a';

const _introAssetPath = 'assets/learning/input/guide/01_intro_alphabet.md';
const _readingRulesAssetPath =
    'assets/learning/input/guide/02_reading_rules.md';
const _smixutAssetPath = 'assets/learning/input/guide/07_smixut.md';
const _wholeAlphabetAssetPath =
    'assets/learning/input/guide/03_whole_alphabet.md';

const _introTitle = 'Alphabet Basics';
const _readingRulesTitle = 'Reading Rules';
const _smixutTitle = 'Smikhut';
const _wholeAlphabetTitle = 'Whole Alphabet';

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

    await tester.tap(find.byIcon(Icons.school_outlined));
    await tester.pumpAndSettle();
    await tester.tap(find.byIcon(Icons.menu_book_rounded).first);
    await tester.pumpAndSettle();

    expect(find.text(_unreadLabel), findsOneWidget);

    await tester.tap(find.byTooltip(_changeStatusTooltip));
    await tester.pumpAndSettle();

    expect(find.text(_studyingLabel), findsWidgets);

    await tester.tap(find.byTooltip(_changeStatusTooltip));
    await tester.pumpAndSettle();

    expect(guideStore.lessonStatuses['intro_alphabet'], GuideLessonStatus.read);
    expect(find.text(_readLabel), findsWidgets);
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
                assetPath:
                    'assets/learning/input/guide/34_infinitive_constructions.md',
                displayName: '34 Infinitive Constructions',
                lessonId: 'infinitive_constructions',
                sectionId: 'verbs',
                sectionLabel: 'Verbs',
              ),
              LessonEntry(
                assetPath:
                    'assets/learning/input/guide/59_register_formal_vs_spoken.md',
                displayName: '59 Register Formal Vs Spoken',
                lessonId: 'register_formal_spoken',
                sectionId: 'spoken',
                sectionLabel: 'Spoken',
              ),
              LessonEntry(
                assetPath: _introAssetPath,
                displayName: '01 Intro Alphabet',
                lessonId: 'intro_alphabet',
                sectionId: 'basics',
                sectionLabel: 'Basics',
              ),
            ],
            documentLoader: _GuideSearchDocumentLoader(),
            lessonStatuses: const <String, GuideLessonStatus>{},
            onStatusChanged: (_, _) => true,
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Infinitive Constructions'), findsOneWidget);
    expect(find.text('Formal vs Spoken'), findsOneWidget);
    expect(find.text('Alphabet'), findsOneWidget);

    await tester.tap(find.byTooltip(_openSectionFilterTooltip));
    await tester.pumpAndSettle();

    final verbsOption = find.text('Verbs').last;
    await tester.ensureVisible(verbsOption);
    await tester.tap(verbsOption);
    await tester.pumpAndSettle();

    final spokenOption = find.text('Spoken').last;
    await tester.ensureVisible(spokenOption);
    await tester.tap(spokenOption);
    await tester.pumpAndSettle();
    await tester.tapAt(const Offset(20, 20));
    await tester.pumpAndSettle();

    expect(find.text('Formal vs Spoken'), findsOneWidget);
    expect(find.text('Infinitive Constructions'), findsOneWidget);
    expect(find.text('Alphabet'), findsNothing);

    await tester.ensureVisible(find.byTooltip(_showSearchTooltip));
    await tester.tap(find.byTooltip(_showSearchTooltip));
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(EditableText).last, 'natural');
    await tester.pumpAndSettle();

    expect(find.text('Formal vs Spoken'), findsOneWidget);
    expect(find.text('Infinitive Constructions'), findsNothing);
  });

  testWidgets('guide lesson becomes studying when opened', (
    WidgetTester tester,
  ) async {
    GuideLessonStatus? latestStatus;

    await tester.pumpWidget(
      MaterialApp(
        home: GuideDetailScreen(
          lesson: const LessonEntry(
            assetPath: _introAssetPath,
            displayName: '01 Intro Alphabet',
            lessonId: 'intro_alphabet',
            sectionId: 'basics',
            sectionLabel: 'Basics',
            relatedIds: ['reading_rules'],
          ),
          allLessons: const [
            LessonEntry(
              assetPath: _introAssetPath,
              displayName: '01 Intro Alphabet',
              lessonId: 'intro_alphabet',
              sectionId: 'basics',
              sectionLabel: 'Basics',
              relatedIds: ['reading_rules'],
            ),
            LessonEntry(
              assetPath: _readingRulesAssetPath,
              displayName: '02 Reading Rules',
              lessonId: 'reading_rules',
              sectionId: 'basics',
              sectionLabel: 'Basics',
            ),
          ],
          documentLoader: _GuideDocumentLoader(),
          initialStatus: GuideLessonStatus.unread,
          onStatusChanged: (status) {
            latestStatus = status;
            return true;
          },
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(latestStatus, GuideLessonStatus.studying);
    expect(find.text(_studyingLabel), findsWidgets);
    expect(find.text(_outlineHeading), findsOneWidget);
    expect(find.text(_nextLessonLabel), findsOneWidget);
    expect(find.text(_readingRulesTitle), findsWidgets);
  });

  testWidgets('guide lesson is marked as read after scrolling to the end', (
    WidgetTester tester,
  ) async {
    GuideLessonStatus? latestStatus;

    await tester.pumpWidget(
      MaterialApp(
        home: GuideDetailScreen(
          lesson: const LessonEntry(
            assetPath: _introAssetPath,
            displayName: '01 Intro Alphabet',
          ),
          documentLoader: _LongGuideDocumentLoader(),
          initialStatus: GuideLessonStatus.studying,
          onStatusChanged: (status) {
            latestStatus = status;
            return true;
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
    expect(find.text(_readLabel), findsWidgets);
  });

  testWidgets(
    'guide adjacent navigation uses lesson titles instead of file labels',
    (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: GuideDetailScreen(
            lesson: const LessonEntry(
              assetPath: _readingRulesAssetPath,
              displayName: '02 Reading Rules',
              lessonId: 'reading_rules',
              sectionId: 'basics',
              sectionLabel: 'Basics',
            ),
            allLessons: const [
              LessonEntry(
                assetPath: _introAssetPath,
                displayName: '01 Intro Alphabet',
                lessonId: 'intro_alphabet',
                sectionId: 'basics',
                sectionLabel: 'Basics',
              ),
              LessonEntry(
                assetPath: _readingRulesAssetPath,
                displayName: '02 Reading Rules',
                lessonId: 'reading_rules',
                sectionId: 'basics',
                sectionLabel: 'Basics',
              ),
              LessonEntry(
                assetPath: _smixutAssetPath,
                displayName: '07 Smixut',
                lessonId: 'smixut',
                sectionId: 'basics',
                sectionLabel: 'Basics',
              ),
            ],
            documentLoader: _GuideAdjacentTitlesDocumentLoader(),
            initialStatus: GuideLessonStatus.studying,
            onStatusChanged: (_) => true,
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text(_introTitle), findsOneWidget);
      expect(find.text(_smixutTitle), findsOneWidget);
      expect(find.text('01 Intro Alphabet'), findsNothing);
      expect(find.text('07 Smixut'), findsNothing);
    },
  );

  testWidgets(
    'guide related topics deduplicate metadata and markdown matches',
    (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: GuideDetailScreen(
            lesson: const LessonEntry(
              assetPath: _introAssetPath,
              displayName: '01 Intro Alphabet',
              lessonId: 'intro_alphabet',
              sectionId: 'basics',
              sectionLabel: 'Basics',
              relatedIds: ['reading_rules'],
            ),
            allLessons: const [
              LessonEntry(
                assetPath: _introAssetPath,
                displayName: '01 Intro Alphabet',
                lessonId: 'intro_alphabet',
                sectionId: 'basics',
                sectionLabel: 'Basics',
                relatedIds: ['reading_rules'],
              ),
              LessonEntry(
                assetPath: _readingRulesAssetPath,
                displayName: '02 Reading Rules',
                lessonId: 'reading_rules',
                sectionId: 'basics',
                sectionLabel: 'Basics',
              ),
            ],
            documentLoader: _GuideRelatedTopicsCleanupLoader(),
            initialStatus: GuideLessonStatus.studying,
            onStatusChanged: (_) => true,
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text(_readingRulesTitle), findsOneWidget);
      expect(find.text('Missing Topic'), findsNothing);
    },
  );

  testWidgets(
    'guide back button returns to guide list after opening adjacent lesson',
    (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: GuideScreen(
              lessons: const [
                LessonEntry(
                  assetPath: _introAssetPath,
                  displayName: '01 Intro Alphabet',
                  lessonId: 'intro_alphabet',
                  sectionId: 'basics',
                  sectionLabel: 'Basics',
                ),
                LessonEntry(
                  assetPath: _readingRulesAssetPath,
                  displayName: '02 Reading Rules',
                  lessonId: 'reading_rules',
                  sectionId: 'basics',
                  sectionLabel: 'Basics',
                ),
                LessonEntry(
                  assetPath: _wholeAlphabetAssetPath,
                  displayName: '03 Whole Alphabet',
                  lessonId: 'whole_alphabet',
                  sectionId: 'basics',
                  sectionLabel: 'Basics',
                ),
              ],
              documentLoader: _GuideNavigationFlowDocumentLoader(),
              lessonStatuses: const <String, GuideLessonStatus>{},
              onStatusChanged: (_, _) => true,
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text(_readingRulesTitle));
      await tester.pumpAndSettle();

      expect(find.text(_wholeAlphabetTitle), findsOneWidget);
      await tester.ensureVisible(find.text(_wholeAlphabetTitle));
      await tester.tap(find.text(_wholeAlphabetTitle));
      await tester.pumpAndSettle();

      expect(find.text(_wholeAlphabetTitle), findsWidgets);
      await tester.pageBack();
      await tester.pumpAndSettle();

      expect(find.text(_guideTitle), findsOneWidget);
      expect(find.text(_readingRulesTitle), findsOneWidget);
      expect(find.text(_introTitle), findsOneWidget);
    },
  );
}

class _GuideOnlyBundleLoader implements LearningBundleLoader {
  @override
  Future<LearningBundle> load() async {
    return const LearningBundle(
      words: <LearningWord>[],
      guideLessons: [
        LessonEntry(
          assetPath: _introAssetPath,
          displayName: '01 Intro Alphabet',
          sectionId: 'basics',
          sectionLabel: 'Basics',
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
        title: _readingRulesTitle,
        summary: 'How letters and vowels behave in real reading.',
        headings: ['Core idea'],
        body: '## Core idea\n\n- We look at the common reading pattern.',
      );
    }

    return const LessonDocument(
      title: _introTitle,
      summary: 'A short overview of writing direction and basic reading logic.',
      headings: ['First concept'],
      relatedTopics: [_readingRulesTitle],
      body: '## First concept\n\n- Hebrew is read from right to left.',
    );
  }
}

class _GuideSearchDocumentLoader implements LessonDocumentLoader {
  @override
  Future<LessonDocument> load(String assetPath) async {
    if (assetPath.contains('34_infinitive')) {
      return const LessonDocument(
        title: 'Infinitive Constructions',
        summary: 'How to build patterns like want to do and started to say.',
        headings: ['Main pattern'],
        body: '## Main pattern\n\nPattern with infinitive.',
      );
    }

    if (assetPath.contains('01_intro_alphabet')) {
      return const LessonDocument(
        title: 'Alphabet',
        summary: 'A basic entry point into letters and sounds.',
        headings: ['First letters'],
        body: '## First letters\n\nWe start with the alphabet.',
      );
    }

    return const LessonDocument(
      title: 'Formal vs Spoken',
      summary: 'How to sound natural instead of overly formal.',
      headings: ['Natural alternatives'],
      body:
          '## Natural alternatives\n\nThis lesson shows more natural phrasing.',
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

    return LessonDocument(title: 'Long Lesson', body: body);
  }
}

class _GuideAdjacentTitlesDocumentLoader implements LessonDocumentLoader {
  @override
  Future<LessonDocument> load(String assetPath) async {
    if (assetPath.contains('01_intro_alphabet')) {
      return const LessonDocument(
        title: _introTitle,
        body: '## Core idea\n\n- We start with the letters.',
      );
    }

    if (assetPath.contains('07_smixut')) {
      return const LessonDocument(
        title: _smixutTitle,
        body: '## Core idea\n\n- We look at noun linkage.',
      );
    }

    return const LessonDocument(
      title: _readingRulesTitle,
      body: '## Core idea\n\n- We look at the common reading pattern.',
    );
  }
}

class _GuideRelatedTopicsCleanupLoader implements LessonDocumentLoader {
  @override
  Future<LessonDocument> load(String assetPath) async {
    if (assetPath.contains('02_reading_rules')) {
      return const LessonDocument(
        title: _readingRulesTitle,
        body: '## Core idea\n\n- We look at vowels and patterns.',
      );
    }

    return const LessonDocument(
      title: _introTitle,
      headings: ['Core idea'],
      relatedTopics: [_readingRulesTitle, 'Missing Topic'],
      body: '## Core idea\n\n- We learn the basic letters.',
    );
  }
}

class _GuideNavigationFlowDocumentLoader implements LessonDocumentLoader {
  @override
  Future<LessonDocument> load(String assetPath) async {
    if (assetPath.contains('01_intro_alphabet')) {
      return const LessonDocument(
        title: _introTitle,
        summary: 'The first pass over the letters.',
        headings: ['Core idea'],
        body: '## Core idea\n\n- We see the basic letters.',
      );
    }

    if (assetPath.contains('03_whole_alphabet')) {
      return const LessonDocument(
        title: _wholeAlphabetTitle,
        summary: 'All letters in one place.',
        headings: ['Core idea'],
        body: '## Core idea\n\n- We gather the whole alphabet.',
      );
    }

    return const LessonDocument(
      title: _readingRulesTitle,
      summary: 'How to read niqqud and basic patterns.',
      headings: ['Core idea'],
      body: '## Core idea\n\n- We look at niqqud.',
    );
  }
}

class FakeGuideProgressStore implements GuideProgressStore {
  FakeGuideProgressStore({Map<String, GuideLessonStatus>? initialStatuses})
    : lessonStatuses = <String, GuideLessonStatus>{...?initialStatuses};

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
  Future<bool> prepareAsset(String assetPath) async => false;

  @override
  Future<void> dispose() async {}

  @override
  Future<void> playAsset(String assetPath) async {}

  @override
  Future<void> stop() async {}
}
