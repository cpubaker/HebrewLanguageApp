import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'screens/app_shell_screen.dart';
import 'services/guide_progress_store.dart';
import 'services/lesson_document_loader.dart';
import 'services/learning_bundle_loader.dart';
import 'services/reading_progress_store.dart';
import 'services/verb_audio_player.dart';
import 'services/word_progress_store.dart';
import 'theme/app_theme.dart';

class HebrewFlutterApp extends StatelessWidget {
  const HebrewFlutterApp({
    super.key,
    LearningBundleLoader? loader,
    LessonDocumentLoader? documentLoader,
    WordProgressStore? progressStore,
    GuideProgressStore? guideProgressStore,
    ReadingProgressStore? readingProgressStore,
    CreateVerbAudioPlayer? audioPlayerFactory,
  }) : _loader = loader,
       _documentLoader = documentLoader,
       _progressStore = progressStore,
       _guideProgressStore = guideProgressStore,
       _readingProgressStore = readingProgressStore,
       _audioPlayerFactory = audioPlayerFactory;

  final LearningBundleLoader? _loader;
  final LessonDocumentLoader? _documentLoader;
  final WordProgressStore? _progressStore;
  final GuideProgressStore? _guideProgressStore;
  final ReadingProgressStore? _readingProgressStore;
  final CreateVerbAudioPlayer? _audioPlayerFactory;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Вчимо іврит',
      debugShowCheckedModeBanner: false,
      locale: const Locale('uk'),
      supportedLocales: const [Locale('uk')],
      localizationsDelegates: GlobalMaterialLocalizations.delegates,
      theme: buildAppTheme(),
      home: AppShellScreen(
        loader: _loader ?? AssetLearningBundleLoader(),
        documentLoader: _documentLoader ?? AssetLessonDocumentLoader(),
        progressStore: _progressStore ?? SharedPreferencesWordProgressStore(),
        guideProgressStore:
            _guideProgressStore ?? SharedPreferencesGuideProgressStore(),
        readingProgressStore:
            _readingProgressStore ?? SharedPreferencesReadingProgressStore(),
        audioPlayerFactory: _audioPlayerFactory ?? createAssetVerbAudioPlayer,
      ),
    );
  }
}
