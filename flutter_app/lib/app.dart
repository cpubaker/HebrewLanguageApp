import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'screens/app_shell_screen.dart';
import 'services/ai_context_service.dart';
import 'services/ai_context_settings_store.dart';
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
  const HebrewFlutterApp({
    super.key,
    LearningBundleLoader? loader,
    LessonDocumentLoader? documentLoader,
    WordProgressStore? progressStore,
    GuideProgressStore? guideProgressStore,
    ReadingProgressStore? readingProgressStore,
    LearningProgressRepository? progressRepository,
    FeatureAccessService? featureAccessService,
    AiContextService? aiContextService,
    AiContextSettingsStore? aiContextSettingsStore,
    AiPracticeTextSettingsStore? aiPracticeTextSettingsStore,
    CreateVerbAudioPlayer? audioPlayerFactory,
    CreateAudioPlaybackAwareness? audioPlaybackAwarenessFactory,
    this.themeModeStore,
    this.initialThemeMode = ThemeMode.light,
  }) : _loader = loader,
       _documentLoader = documentLoader,
       _progressStore = progressStore,
       _guideProgressStore = guideProgressStore,
       _readingProgressStore = readingProgressStore,
       _progressRepository = progressRepository,
       _featureAccessService = featureAccessService,
       _aiContextService = aiContextService,
       _aiContextSettingsStore = aiContextSettingsStore,
       _aiPracticeTextSettingsStore = aiPracticeTextSettingsStore,
       _audioPlayerFactory = audioPlayerFactory,
       _audioPlaybackAwarenessFactory = audioPlaybackAwarenessFactory;

  final LearningBundleLoader? _loader;
  final LessonDocumentLoader? _documentLoader;
  final WordProgressStore? _progressStore;
  final GuideProgressStore? _guideProgressStore;
  final ReadingProgressStore? _readingProgressStore;
  final LearningProgressRepository? _progressRepository;
  final FeatureAccessService? _featureAccessService;
  final AiContextService? _aiContextService;
  final AiContextSettingsStore? _aiContextSettingsStore;
  final AiPracticeTextSettingsStore? _aiPracticeTextSettingsStore;
  final CreateVerbAudioPlayer? _audioPlayerFactory;
  final CreateAudioPlaybackAwareness? _audioPlaybackAwarenessFactory;
  final ThemeModeStore? themeModeStore;
  final ThemeMode initialThemeMode;

  @override
  State<HebrewFlutterApp> createState() => _HebrewFlutterAppState();
}

class _HebrewFlutterAppState extends State<HebrewFlutterApp> {
  late ThemeMode _themeMode = widget.initialThemeMode;
  late final FeatureAccessService _featureAccessService =
      widget._featureAccessService ?? const StaticFeatureAccessService();

  @override
  void initState() {
    super.initState();
    final store = widget.themeModeStore;
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

    final store = widget.themeModeStore;
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
        progressRepository:
            widget._progressRepository ??
            StoreBackedLearningProgressRepository(
              loader: widget._loader ?? AssetLearningBundleLoader(),
              wordProgressStore:
                  widget._progressStore ?? SharedPreferencesWordProgressStore(),
              guideProgressStore:
                  widget._guideProgressStore ??
                  SharedPreferencesGuideProgressStore(),
              readingProgressStore:
                  widget._readingProgressStore ??
                  SharedPreferencesReadingProgressStore(),
            ),
        documentLoader: widget._documentLoader ?? AssetLessonDocumentLoader(),
        featureAccessService: _featureAccessService,
        aiContextService:
            widget._aiContextService ?? createDefaultAiContextService(),
        aiContextSettingsStore:
            widget._aiContextSettingsStore ??
            const SharedPreferencesAiContextSettingsStore(),
        aiPracticeTextSettingsStore:
            widget._aiPracticeTextSettingsStore ??
            const SharedPreferencesAiPracticeTextSettingsStore(),
        audioPlayerFactory:
            widget._audioPlayerFactory ?? createAssetVerbAudioPlayer,
        audioPlaybackAwarenessFactory:
            widget._audioPlaybackAwarenessFactory ??
            createAudioPlaybackAwareness,
        isDarkMode: _themeMode == ThemeMode.dark,
        onToggleThemeMode: _toggleThemeMode,
      ),
    );
  }
}
