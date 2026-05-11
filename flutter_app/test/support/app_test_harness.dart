import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hebrew_language_flutter/app.dart';
import 'package:hebrew_language_flutter/models/learning_bundle.dart';
import 'package:hebrew_language_flutter/models/learning_context.dart';
import 'package:hebrew_language_flutter/models/learning_word.dart';
import 'package:hebrew_language_flutter/models/lesson_document.dart';
import 'package:hebrew_language_flutter/services/app_shell_settings_store.dart';
import 'package:hebrew_language_flutter/services/audio_playback_awareness.dart';
import 'package:hebrew_language_flutter/services/feature_access_service.dart';
import 'package:hebrew_language_flutter/services/guide_progress_store.dart';
import 'package:hebrew_language_flutter/services/lesson_document_loader.dart';
import 'package:hebrew_language_flutter/services/learning_bundle_loader.dart';
import 'package:hebrew_language_flutter/services/reading_progress_store.dart';
import 'package:hebrew_language_flutter/services/theme_mode_store.dart';
import 'package:hebrew_language_flutter/services/verb_audio_player.dart';
import 'package:hebrew_language_flutter/services/word_progress_store.dart';

import 'fakes.dart';

const testManWord = LearningWord(
  wordId: 'word_man',
  hebrew: '\u05d0\u05d9\u05e9',
  english: 'man',
  ukrainian: '\u0447\u043e\u043b\u043e\u0432\u0456\u043a',
  transcription: 'ish',
  correct: 1,
  wrong: 0,
  contexts: [
    LearningContext(
      contextId: 'ctx_man_01',
      hebrew:
          '\u05d4\u05d0\u05d9\u05e9 \u05d4\u05d5\u05dc\u05da \u05d1\u05e8\u05d7\u05d5\u05d1.',
      translation:
          '\u0427\u043e\u043b\u043e\u0432\u0456\u043a \u0456\u0434\u0435 \u0432\u0443\u043b\u0438\u0446\u0435\u044e.',
    ),
  ],
);

const testWomanWord = LearningWord(
  wordId: 'word_woman',
  hebrew: '\u05d0\u05d9\u05e9\u05d4',
  english: 'woman',
  ukrainian: '\u0436\u0456\u043d\u043a\u0430',
  transcription: 'isha',
  correct: 3,
  wrong: 1,
);

const testPeaceWord = LearningWord(
  wordId: 'word_peace',
  hebrew: '\u05e9\u05dc\u05d5\u05dd',
  english: 'peace',
  ukrainian: '\u043c\u0438\u0440',
  transcription: 'shalom',
  correct: 0,
  wrong: 0,
);

const testHouseWord = LearningWord(
  wordId: 'word_house',
  hebrew: '\u05d1\u05d9\u05ea',
  english: 'house',
  ukrainian: '\u0431\u0443\u0434\u0438\u043d\u043e\u043a',
  transcription: 'bayit',
  correct: 0,
  wrong: 0,
);

const testLearningBundle = LearningBundle(
  words: [testManWord, testWomanWord],
  guideLessons: [
    LessonEntry(
      assetPath: 'assets/learning/input/guide/01_intro_alphabet.md',
      displayName: '01 Intro Alphabet',
    ),
  ],
  verbLessons: [],
  readingLessons: [
    LessonEntry(
      assetPath:
          'assets/learning/input/reading/beginner/01_yosi_goes_to_school.md',
      displayName: '01 Yosi Goes To School',
    ),
  ],
);

class TestLearningBundleLoader implements LearningBundleLoader {
  const TestLearningBundleLoader({this.bundle = testLearningBundle});

  final LearningBundle bundle;

  @override
  Future<LearningBundle> load() async => bundle;
}

class TestLessonDocumentLoader implements LessonDocumentLoader {
  const TestLessonDocumentLoader();

  @override
  Future<LessonDocument> load(String assetPath) async {
    if (assetPath.contains('/verbs/')) {
      return const LessonDocument(
        title: '\u0425\u043e\u0434\u0438\u0442\u0438',
        body: '## Present\n\n- holekh\n- holekhet',
      );
    }

    if (assetPath.contains('/reading/')) {
      return const LessonDocument(
        title: 'Yosi Goes To School',
        body: '## Key words\n\n- yosi\n- school',
      );
    }

    return const LessonDocument(
      title: 'Alphabet Basics',
      body: '## First concept\n\n- Hebrew is read from right to left.',
    );
  }
}

Future<void> useTallMobileViewport(
  WidgetTester tester, {
  Size size = const Size(430, 1400),
}) async {
  tester.view.physicalSize = size;
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
}

Future<void> pumpHebrewTestApp(
  WidgetTester tester, {
  LearningBundleLoader loader = const TestLearningBundleLoader(),
  LessonDocumentLoader documentLoader = const TestLessonDocumentLoader(),
  WordProgressStore? progressStore,
  GuideProgressStore? guideProgressStore,
  ReadingProgressStore? readingProgressStore,
  ThemeModeStore? themeModeStore,
  AppShellSettingsStore? appShellSettingsStore,
  FeatureAccessService? featureAccessService,
  CreateVerbAudioPlayer? audioPlayerFactory,
  CreateAudioPlaybackAwareness? audioPlaybackAwarenessFactory,
  DateTime Function()? currentDateTime,
}) async {
  await useTallMobileViewport(tester);
  await tester.pumpWidget(
    HebrewFlutterApp(
      loader: loader,
      documentLoader: documentLoader,
      progressStore: progressStore ?? FakeWordProgressStore(),
      guideProgressStore: guideProgressStore ?? FakeGuideProgressStore(),
      readingProgressStore: readingProgressStore ?? FakeReadingProgressStore(),
      themeModeStore: themeModeStore,
      appShellSettingsStore: appShellSettingsStore,
      featureAccessService: featureAccessService,
      audioPlayerFactory: audioPlayerFactory,
      audioPlaybackAwarenessFactory: audioPlaybackAwarenessFactory,
      currentDateTime: currentDateTime,
    ),
  );
  await tester.pumpAndSettle();
}
