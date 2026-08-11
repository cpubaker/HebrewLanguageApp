import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hebrew_language_flutter/l10n/generated/app_localizations.dart';
import 'package:hebrew_language_flutter/models/guide_lesson_status.dart';
import 'package:hebrew_language_flutter/models/learning_bundle.dart';
import 'package:hebrew_language_flutter/models/lesson_document.dart';
import 'package:hebrew_language_flutter/screens/guide_screen.dart';
import 'package:hebrew_language_flutter/services/lesson_document_loader.dart';

import 'support/app_test_harness.dart';
import 'support/fakes.dart';

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
const _wholeAlphabetAssetPath =
    'assets/learning/input/guide/03_whole_alphabet.md';
const _smixutAssetPath = 'assets/learning/input/guide/07_smixut.md';
const _infinitiveAssetPath =
    'assets/learning/input/guide/34_infinitive_constructions.md';
const _registerAssetPath =
    'assets/learning/input/guide/59_register_formal_vs_spoken.md';

const _introTitle = 'Alphabet Basics';
const _readingRulesTitle = 'Reading Rules';
const _wholeAlphabetTitle = 'Whole Alphabet';
const _smixutTitle = 'Smikhut';

final _introLesson = _lesson(_introAssetPath, '01 Intro Alphabet');
final _introRelatedLesson = _lesson(
  _introAssetPath,
  '01 Intro Alphabet',
  relatedIds: ['reading_rules'],
);
final _readingRulesLesson = _lesson(
  _readingRulesAssetPath,
  '02 Reading Rules',
  lessonId: 'reading_rules',
);
final _wholeAlphabetLesson = _lesson(
  _wholeAlphabetAssetPath,
  '03 Whole Alphabet',
);
final _smixutLesson = _lesson(_smixutAssetPath, '07 Smixut');
final _infinitiveLesson = _lesson(
  _infinitiveAssetPath,
  '34 Infinitive Constructions',
  sectionId: 'verbs',
  sectionLabel: 'Verbs',
);
final _registerLesson = _lesson(
  _registerAssetPath,
  '59 Register Formal Vs Spoken',
  sectionId: 'spoken',
  sectionLabel: 'Spoken',
);

final _searchDocuments = <String, LessonDocument>{
  _infinitiveAssetPath: _doc(
    'Infinitive Constructions',
    '## Main pattern\n\nPattern with infinitive.',
    summary: 'How to build patterns like want to do and started to say.',
    headings: ['Main pattern'],
  ),
  _registerAssetPath: _doc(
    'Formal vs Spoken',
    '## Natural alternatives\n\nThis lesson shows more natural phrasing.',
    summary: 'How to sound natural instead of overly formal.',
    headings: ['Natural alternatives'],
  ),
  _introAssetPath: _doc(
    'Alphabet',
    '## First letters\n\nWe start with the alphabet.',
    summary: 'A basic entry point into letters and sounds.',
    headings: ['First letters'],
  ),
};

final _relatedCleanupDocuments = <String, LessonDocument>{
  _introAssetPath: _doc(
    _introTitle,
    '## Core idea\n\n- We learn the basic letters.',
    headings: ['Core idea'],
    relatedTopics: [_readingRulesTitle, 'Missing Topic'],
  ),
  _readingRulesAssetPath: _navigationDocuments[_readingRulesAssetPath]!,
};

final _navigationDocuments = <String, LessonDocument>{
  _introAssetPath: _doc(
    _introTitle,
    '## Core idea\n\n- We see the basic letters.',
    summary: 'The first pass over the letters.',
    headings: ['Core idea'],
  ),
  _readingRulesAssetPath: _doc(
    _readingRulesTitle,
    '## Core idea\n\n- We look at niqqud.',
    summary: 'How to read niqqud and basic patterns.',
    headings: ['Core idea'],
  ),
  _wholeAlphabetAssetPath: _doc(
    _wholeAlphabetTitle,
    '## Core idea\n\n- We gather the whole alphabet.',
    summary: 'All letters in one place.',
    headings: ['Core idea'],
  ),
  _smixutAssetPath: _doc(
    _smixutTitle,
    '## Core idea\n\n- We look at noun linkage.',
  ),
};

LessonEntry _lesson(
  String assetPath,
  String displayName, {
  String? lessonId,
  String sectionId = 'basics',
  String sectionLabel = 'Basics',
  List<String> relatedIds = const <String>[],
}) => LessonEntry(
  assetPath: assetPath,
  displayName: displayName,
  lessonId: lessonId,
  sectionId: sectionId,
  sectionLabel: sectionLabel,
  relatedIds: relatedIds,
);

LessonDocument _doc(
  String title,
  String body, {
  String summary = '',
  List<String> headings = const <String>[],
  List<String> relatedTopics = const <String>[],
}) => LessonDocument(
  title: title,
  summary: summary,
  headings: headings,
  relatedTopics: relatedTopics,
  body: body,
);

void main() {
  testWidgets('guide list allows cycling lesson status manually', (
    WidgetTester tester,
  ) async {
    final guideStore = FakeGuideProgressStore();

    await pumpHebrewTestApp(
      tester,
      guideProgressStore: guideStore,
      audioPlayerFactory: () => FakeVerbAudioPlayer(),
    );

    await _openFirstGuideLesson(tester);

    expect(find.text(_unreadLabel), findsOneWidget);

    await _cycleLessonStatus(tester);

    expect(find.text(_studyingLabel), findsWidgets);

    await _cycleLessonStatus(tester);

    expect(guideStore.lessonStatuses['intro_alphabet'], GuideLessonStatus.read);
    expect(find.text(_readLabel), findsWidgets);
  });

  testWidgets('guide screen filters lessons by section and summary search', (
    WidgetTester tester,
  ) async {
    await _pumpGuideScreen(
      tester,
      lessons: [_infinitiveLesson, _registerLesson, _introLesson],
      documentLoader: _MapGuideDocumentLoader(_searchDocuments),
    );

    expect(find.text('Infinitive Constructions'), findsOneWidget);
    expect(find.text('Formal vs Spoken'), findsOneWidget);
    expect(find.text('Alphabet'), findsOneWidget);

    await tester.tap(find.byTooltip(_openSectionFilterTooltip));
    await tester.pumpAndSettle();

    for (final section in ['Verbs', 'Spoken']) {
      final option = find.text(section).last;
      await tester.ensureVisible(option);
      await tester.tap(option);
      await tester.pumpAndSettle();
    }
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

    await _pumpGuideDetail(
      tester,
      lesson: _introRelatedLesson,
      allLessons: [_introRelatedLesson, _readingRulesLesson],
      documentLoader: _MapGuideDocumentLoader(_relatedCleanupDocuments),
      initialStatus: GuideLessonStatus.unread,
      onStatusChanged: (status) {
        latestStatus = status;
        return true;
      },
    );

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

    await _pumpGuideDetail(
      tester,
      lesson: _introLesson,
      documentLoader: const _LongGuideDocumentLoader(),
      initialStatus: GuideLessonStatus.studying,
      onStatusChanged: (status) {
        latestStatus = status;
        return true;
      },
    );

    await tester.scrollUntilVisible(
      find.text('Paragraph 80 about Hebrew grammar.'),
      400,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.pumpAndSettle();

    expect(latestStatus, GuideLessonStatus.read);

    await tester.scrollUntilVisible(
      find.text('Long Lesson'),
      -400,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.pumpAndSettle();

    expect(find.text(_readLabel), findsWidgets);
  });

  testWidgets(
    'guide adjacent navigation uses lesson titles instead of file labels',
    (WidgetTester tester) async {
      await _pumpGuideDetail(
        tester,
        lesson: _readingRulesLesson,
        allLessons: [_introLesson, _readingRulesLesson, _smixutLesson],
        documentLoader: _MapGuideDocumentLoader(_navigationDocuments),
      );

      expect(find.text(_introTitle), findsOneWidget);
      expect(find.text(_smixutTitle), findsOneWidget);
      expect(find.text('01 Intro Alphabet'), findsNothing);
      expect(find.text('07 Smixut'), findsNothing);
    },
  );

  testWidgets(
    'guide related topics deduplicate metadata and markdown matches',
    (WidgetTester tester) async {
      await _pumpGuideDetail(
        tester,
        lesson: _introRelatedLesson,
        allLessons: [_introRelatedLesson, _readingRulesLesson],
        documentLoader: _MapGuideDocumentLoader(_relatedCleanupDocuments),
      );

      expect(find.text(_readingRulesTitle), findsOneWidget);
      expect(find.text('Missing Topic'), findsNothing);
    },
  );

  testWidgets(
    'guide back button returns to guide list after opening adjacent lesson',
    (WidgetTester tester) async {
      await _pumpGuideScreen(
        tester,
        lessons: [_introLesson, _readingRulesLesson, _wholeAlphabetLesson],
        documentLoader: _MapGuideDocumentLoader(_navigationDocuments),
      );

      await tester.tap(find.text(_readingRulesTitle));
      await tester.pumpAndSettle();

      expect(find.text(_wholeAlphabetTitle), findsOneWidget);
      await tester.ensureVisible(find.text(_wholeAlphabetTitle));
      await tester.tap(find.text(_wholeAlphabetTitle));
      await tester.pumpAndSettle();

      expect(find.text(_wholeAlphabetTitle), findsWidgets);
      Navigator.of(tester.element(find.byType(GuideDetailScreen))).pop();
      await tester.pumpAndSettle();

      expect(find.text(_guideTitle), findsOneWidget);
      expect(find.text(_readingRulesTitle), findsOneWidget);
      expect(find.text(_introTitle), findsOneWidget);
    },
  );
}

Future<void> _pumpGuideScreen(
  WidgetTester tester, {
  required List<LessonEntry> lessons,
  required LessonDocumentLoader documentLoader,
  Map<String, GuideLessonStatus> lessonStatuses =
      const <String, GuideLessonStatus>{},
  bool Function(String, GuideLessonStatus) onStatusChanged =
      _acceptListStatusChange,
}) async {
  await tester.pumpWidget(
    MaterialApp(
      locale: const Locale('uk'),
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: Scaffold(
        body: GuideScreen(
          lessons: lessons,
          documentLoader: documentLoader,
          lessonStatuses: lessonStatuses,
          onStatusChanged: onStatusChanged,
        ),
      ),
    ),
  );
  await tester.pumpAndSettle();
}

Future<void> _pumpGuideDetail(
  WidgetTester tester, {
  required LessonEntry lesson,
  List<LessonEntry> allLessons = const <LessonEntry>[],
  required LessonDocumentLoader documentLoader,
  GuideLessonStatus initialStatus = GuideLessonStatus.studying,
  bool Function(GuideLessonStatus) onStatusChanged = _acceptDetailStatusChange,
}) async {
  await tester.pumpWidget(
    MaterialApp(
      locale: const Locale('uk'),
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: GuideDetailScreen(
        lesson: lesson,
        allLessons: allLessons,
        documentLoader: documentLoader,
        initialStatus: initialStatus,
        onStatusChanged: onStatusChanged,
      ),
    ),
  );
  await tester.pumpAndSettle();
}

Future<void> _openFirstGuideLesson(WidgetTester tester) async {
  await tester.tap(find.byIcon(Icons.school_outlined));
  await tester.pumpAndSettle();
  await tester.tap(find.byIcon(Icons.menu_book_rounded).first);
  await tester.pumpAndSettle();
}

Future<void> _cycleLessonStatus(WidgetTester tester) async {
  await tester.tap(find.byTooltip(_changeStatusTooltip));
  await tester.pumpAndSettle();
}

bool _acceptListStatusChange(String lessonKey, GuideLessonStatus status) {
  return true;
}

bool _acceptDetailStatusChange(GuideLessonStatus status) {
  return true;
}

class _MapGuideDocumentLoader implements LessonDocumentLoader {
  const _MapGuideDocumentLoader(this.documents);

  final Map<String, LessonDocument> documents;

  @override
  Future<LessonDocument> load(String assetPath) async {
    final document = documents[assetPath];
    if (document == null) {
      throw StateError('No test document for $assetPath');
    }
    return document;
  }
}

class _LongGuideDocumentLoader implements LessonDocumentLoader {
  const _LongGuideDocumentLoader();

  @override
  Future<LessonDocument> load(String assetPath) async {
    final body = List<String>.generate(
      80,
      (index) => 'Paragraph ${index + 1} about Hebrew grammar.',
    ).join('\n\n');

    return LessonDocument(title: 'Long Lesson', body: body);
  }
}
