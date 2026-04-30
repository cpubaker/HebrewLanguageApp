import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'app_dependencies.dart';
import 'screens/app_shell_screen.dart';
import 'services/ai_context_service.dart';
import 'services/ai_context_settings_store.dart';
import 'services/ai_practice_text_service.dart';
import 'services/ai_practice_text_settings_store.dart';
import 'services/audio_playback_awareness.dart';
import 'services/feature_access_service.dart';
import 'services/guide_progress_store.dart';
import 'services/lesson_document_loader.dart';
import 'services/learning_bundle_loader.dart';
import 'services/learning_progress_repository.dart';
import 'services/reading_progress_store.dart';
import 'services/theme_mode_store.dart';
import 'services/verb_audio_player.dart';
import 'services/word_progress_store.dart';
import 'theme/app_theme.dart';

class HebrewFlutterApp extends StatefulWidget {
  HebrewFlutterApp({
    super.key,
    AppDependencies dependencies = const AppDependencies(),
    LearningBundleLoader? loader,
    LessonDocumentLoader? documentLoader,
    WordProgressStore? progressStore,
    GuideProgressStore? guideProgressStore,
    ReadingProgressStore? readingProgressStore,
    LearningProgressRepository? progressRepository,
    FeatureAccessService? featureAccessService,
    AiContextService? aiContextService,
    AiContextSettingsStore? aiContextSettingsStore,
    AiPracticeTextService? aiPracticeTextService,
    AiPracticeTextSettingsStore? aiPracticeTextSettingsStore,
    CreateVerbAudioPlayer? audioPlayerFactory,
    CreateAudioPlaybackAwareness? audioPlaybackAwarenessFactory,
    ThemeModeStore? themeModeStore,
    this.initialThemeMode = ThemeMode.light,
  }) : dependencies = dependencies.withOverrides(
         loader: loader,
         documentLoader: documentLoader,
         progressStore: progressStore,
         guideProgressStore: guideProgressStore,
         readingProgressStore: readingProgressStore,
         progressRepository: progressRepository,
         featureAccessService: featureAccessService,
         aiContextService: aiContextService,
         aiContextSettingsStore: aiContextSettingsStore,
         aiPracticeTextService: aiPracticeTextService,
         aiPracticeTextSettingsStore: aiPracticeTextSettingsStore,
         audioPlayerFactory: audioPlayerFactory,
         audioPlaybackAwarenessFactory: audioPlaybackAwarenessFactory,
         themeModeStore: themeModeStore,
       );

  final AppDependencies dependencies;
  final ThemeMode initialThemeMode;

  @override
  State<HebrewFlutterApp> createState() => _HebrewFlutterAppState();
}

class _HebrewFlutterAppState extends State<HebrewFlutterApp> {
  late ThemeMode _themeMode = widget.initialThemeMode;
  late final AppDependencies _dependencies = widget.dependencies;
  late final LearningProgressRepository _progressRepository = _dependencies
      .resolveProgressRepository();
  late final LessonDocumentLoader _documentLoader = _dependencies
      .resolveDocumentLoader();
  late final FeatureAccessService _featureAccessService = _dependencies
      .resolveFeatureAccessService();
  late final AiContextService _aiContextService = _dependencies
      .resolveAiContextService();
  late final AiContextSettingsStore _aiContextSettingsStore = _dependencies
      .resolveAiContextSettingsStore();
  late final AiPracticeTextService _aiPracticeTextService = _dependencies
      .resolveAiPracticeTextService();
  late final AiPracticeTextSettingsStore _aiPracticeTextSettingsStore =
      _dependencies.resolveAiPracticeTextSettingsStore();
  late final CreateVerbAudioPlayer _audioPlayerFactory = _dependencies
      .resolveAudioPlayerFactory();
  late final CreateAudioPlaybackAwareness _audioPlaybackAwarenessFactory =
      _dependencies.resolveAudioPlaybackAwarenessFactory();

  @override
  void initState() {
    super.initState();
    final store = _dependencies.themeModeStore;
    if (store != null) {
      unawaited(_restoreThemeMode(store));
    }
  }

  Future<void> _restoreThemeMode(ThemeModeStore store) async {
    final restoredMode = await store.load();
    if (restoredMode == ThemeMode.dark &&
        !_featureAccessService.isEnabled(AppFeature.nightMode)) {
      return;
    }

    if (!mounted || restoredMode == _themeMode) {
      return;
    }

    setState(() {
      _themeMode = restoredMode;
    });
  }

  void _toggleThemeMode() {
    final nextMode = _themeMode == ThemeMode.dark
        ? ThemeMode.light
        : ThemeMode.dark;
    if (nextMode == ThemeMode.dark &&
        !_featureAccessService.isEnabled(AppFeature.nightMode)) {
      return;
    }

    setState(() {
      _themeMode = nextMode;
    });

    final store = _dependencies.themeModeStore;
    if (store != null) {
      unawaited(store.save(nextMode));
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Р’С‡РёРјРѕ С–РІСЂРёС‚',
      debugShowCheckedModeBanner: false,
      locale: const Locale('uk'),
      supportedLocales: const [Locale('uk')],
      localizationsDelegates: GlobalMaterialLocalizations.delegates,
      theme: buildLightAppTheme(),
      darkTheme: buildDarkAppTheme(),
      themeMode: _themeMode,
      home: AppShellScreen(
        progressRepository: _progressRepository,
        documentLoader: _documentLoader,
        featureAccessService: _featureAccessService,
        aiContextService: _aiContextService,
        aiContextSettingsStore: _aiContextSettingsStore,
        aiPracticeTextService: _aiPracticeTextService,
        aiPracticeTextSettingsStore: _aiPracticeTextSettingsStore,
        audioPlayerFactory: _audioPlayerFactory,
        audioPlaybackAwarenessFactory: _audioPlaybackAwarenessFactory,
        isDarkMode: _themeMode == ThemeMode.dark,
        onToggleThemeMode: _toggleThemeMode,
      ),
    );
  }
}
