import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'app_dependencies.dart';
import 'l10n/generated/app_localizations.dart';
import 'screens/app_shell_screen.dart';
import 'services/ai_context_service.dart';
import 'services/ai_context_settings_store.dart';
import 'services/ai_practice_text_service.dart';
import 'services/ai_practice_text_settings_store.dart';
import 'services/app_locale_store.dart';
import 'services/app_shell_settings_store.dart';
import 'services/audio_playback_awareness.dart';
import 'services/feature_access_service.dart';
import 'services/guide_progress_store.dart';
import 'services/lesson_document_loader.dart';
import 'services/learning_bundle_loader.dart';
import 'services/learning_progress_repository.dart';
import 'services/reading_progress_store.dart';
import 'services/sprint_stats_store.dart';
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
    SprintStatsStore? sprintStatsStore,
    LearningProgressRepository? progressRepository,
    FeatureAccessService? featureAccessService,
    AiContextService? aiContextService,
    AiContextSettingsStore? aiContextSettingsStore,
    AiPracticeTextService? aiPracticeTextService,
    AiPracticeTextSettingsStore? aiPracticeTextSettingsStore,
    AppShellSettingsStore? appShellSettingsStore,
    CreateVerbAudioPlayer? audioPlayerFactory,
    CreateAudioPlaybackAwareness? audioPlaybackAwarenessFactory,
    ThemeModeStore? themeModeStore,
    AppLocaleStore? localeStore,
    ThemeMode? initialThemeMode,
    AppThemePreference? initialThemePreference,
    AppLocalePreference? initialLocalePreference,
  }) : initialThemePreference =
           initialThemePreference ??
           AppThemePreference.fromThemeMode(
             initialThemeMode ?? ThemeMode.light,
           ),
       initialLocalePreference =
           initialLocalePreference ?? AppLocalePreference.uk,
       dependencies = dependencies.withOverrides(
         loader: loader,
         documentLoader: documentLoader,
         progressStore: progressStore,
         guideProgressStore: guideProgressStore,
         readingProgressStore: readingProgressStore,
         sprintStatsStore: sprintStatsStore,
         progressRepository: progressRepository,
         featureAccessService: featureAccessService,
         aiContextService: aiContextService,
         aiContextSettingsStore: aiContextSettingsStore,
         aiPracticeTextService: aiPracticeTextService,
         aiPracticeTextSettingsStore: aiPracticeTextSettingsStore,
         appShellSettingsStore: appShellSettingsStore,
         audioPlayerFactory: audioPlayerFactory,
         audioPlaybackAwarenessFactory: audioPlaybackAwarenessFactory,
         themeModeStore: themeModeStore,
         localeStore: localeStore,
       );

  final AppDependencies dependencies;
  final AppThemePreference initialThemePreference;
  final AppLocalePreference initialLocalePreference;

  @override
  State<HebrewFlutterApp> createState() => _HebrewFlutterAppState();
}

class _HebrewFlutterAppState extends State<HebrewFlutterApp> {
  late AppThemePreference _themePreference = widget.initialThemePreference;
  late AppLocalePreference _localePreference = widget.initialLocalePreference;
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
  late final AppShellSettingsStore _appShellSettingsStore = _dependencies
      .resolveAppShellSettingsStore();
  late final SprintStatsStore _sprintStatsStore = _dependencies
      .resolveSprintStatsStore();
  late final CreateVerbAudioPlayer _audioPlayerFactory = _dependencies
      .resolveAudioPlayerFactory();
  late final CreateAudioPlaybackAwareness _audioPlaybackAwarenessFactory =
      _dependencies.resolveAudioPlaybackAwarenessFactory();

  @override
  void initState() {
    super.initState();
    final themeStore = _dependencies.themeModeStore;
    if (themeStore != null) {
      unawaited(_restoreThemeMode(themeStore));
    }
    final localeStore = _dependencies.localeStore;
    if (localeStore != null) {
      unawaited(_restoreLocale(localeStore));
    }
  }

  Future<void> _restoreThemeMode(ThemeModeStore store) async {
    final restoredPreference = await store.load();
    if (restoredPreference.requiresNightMode &&
        !_featureAccessService.isEnabled(AppFeature.nightMode)) {
      return;
    }

    if (!mounted || restoredPreference == _themePreference) {
      return;
    }

    setState(() {
      _themePreference = restoredPreference;
    });
  }

  Future<void> _restoreLocale(AppLocaleStore store) async {
    final restoredPreference = await store.load();
    if (!mounted || restoredPreference == _localePreference) {
      return;
    }

    setState(() {
      _localePreference = restoredPreference;
    });
  }

  void _setThemePreference(AppThemePreference preference) {
    if (preference.requiresNightMode &&
        !_featureAccessService.isEnabled(AppFeature.nightMode)) {
      return;
    }

    setState(() {
      _themePreference = preference;
    });

    final store = _dependencies.themeModeStore;
    if (store != null) {
      unawaited(store.save(preference));
    }
  }

  void _setLocalePreference(AppLocalePreference preference) {
    if (preference == _localePreference) {
      return;
    }

    setState(() {
      _localePreference = preference;
    });

    final store = _dependencies.localeStore;
    if (store != null) {
      unawaited(store.save(preference));
    }
  }

  ThemeMode _effectiveThemeMode() {
    return switch (_themePreference) {
      AppThemePreference.light => ThemeMode.light,
      AppThemePreference.dark => ThemeMode.dark,
      AppThemePreference.system => ThemeMode.system,
    };
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      onGenerateTitle: (context) => AppLocalizations.of(context).appTitle,
      debugShowCheckedModeBanner: false,
      locale: _localePreference.locale,
      supportedLocales: AppLocalizations.supportedLocales,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      theme: buildLightAppTheme(),
      darkTheme: buildDarkAppTheme(),
      themeMode: _effectiveThemeMode(),
      home: AppShellScreen(
        progressRepository: _progressRepository,
        documentLoader: _documentLoader,
        featureAccessService: _featureAccessService,
        aiContextService: _aiContextService,
        aiContextSettingsStore: _aiContextSettingsStore,
        aiPracticeTextService: _aiPracticeTextService,
        aiPracticeTextSettingsStore: _aiPracticeTextSettingsStore,
        appShellSettingsStore: _appShellSettingsStore,
        sprintStatsStore: _sprintStatsStore,
        audioPlayerFactory: _audioPlayerFactory,
        audioPlaybackAwarenessFactory: _audioPlaybackAwarenessFactory,
        themePreference: _themePreference,
        onThemePreferenceChanged: _setThemePreference,
        localePreference: _localePreference,
        onLocalePreferenceChanged: _setLocalePreference,
      ),
    );
  }
}
