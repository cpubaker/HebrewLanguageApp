import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'app_dependencies.dart';
import 'screens/app_shell_screen.dart';
import 'services/ai_context_service.dart';
import 'services/ai_context_settings_store.dart';
import 'services/ai_practice_text_service.dart';
import 'services/ai_practice_text_settings_store.dart';
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
    ThemeMode? initialThemeMode,
    AppThemePreference? initialThemePreference,
    this.currentDateTime,
  }) : initialThemePreference =
           initialThemePreference ??
           AppThemePreference.fromThemeMode(
             initialThemeMode ?? ThemeMode.light,
           ),
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
       );

  final AppDependencies dependencies;
  final AppThemePreference initialThemePreference;
  final DateTime Function()? currentDateTime;

  @override
  State<HebrewFlutterApp> createState() => _HebrewFlutterAppState();
}

class _HebrewFlutterAppState extends State<HebrewFlutterApp> {
  late AppThemePreference _themePreference = widget.initialThemePreference;
  late final DateTime Function() _currentDateTime =
      widget.currentDateTime ?? DateTime.now;
  Timer? _automaticThemeTimer;
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
    final store = _dependencies.themeModeStore;
    if (store != null) {
      unawaited(_restoreThemeMode(store));
    }
    _scheduleAutomaticThemeRefresh();
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
    _scheduleAutomaticThemeRefresh();
  }

  void _setThemePreference(AppThemePreference preference) {
    if (preference.requiresNightMode &&
        !_featureAccessService.isEnabled(AppFeature.nightMode)) {
      return;
    }

    setState(() {
      _themePreference = preference;
    });
    _scheduleAutomaticThemeRefresh();

    final store = _dependencies.themeModeStore;
    if (store != null) {
      unawaited(store.save(preference));
    }
  }

  ThemeMode _effectiveThemeMode() {
    return switch (_themePreference) {
      AppThemePreference.light => ThemeMode.light,
      AppThemePreference.dark => ThemeMode.dark,
      AppThemePreference.system => ThemeMode.system,
      AppThemePreference.automatic => _automaticThemeMode(_currentDateTime()),
    };
  }

  ThemeMode _automaticThemeMode(DateTime now) {
    return now.hour >= 20 || now.hour < 7 ? ThemeMode.dark : ThemeMode.light;
  }

  void _scheduleAutomaticThemeRefresh() {
    _automaticThemeTimer?.cancel();
    if (_themePreference != AppThemePreference.automatic) {
      return;
    }

    final now = _currentDateTime();
    final transition = _nextAutomaticThemeTransition(now);
    final delay = transition.difference(now);
    _automaticThemeTimer = Timer(delay, () {
      if (!mounted) {
        return;
      }

      setState(() {});
      _scheduleAutomaticThemeRefresh();
    });
  }

  DateTime _nextAutomaticThemeTransition(DateTime now) {
    final morning = DateTime(now.year, now.month, now.day, 7);
    final evening = DateTime(now.year, now.month, now.day, 20);

    if (now.isBefore(morning)) {
      return morning;
    }
    if (now.isBefore(evening)) {
      return evening;
    }

    return DateTime(now.year, now.month, now.day + 1, 7);
  }

  @override
  void dispose() {
    _automaticThemeTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Вчимо іврит',
      debugShowCheckedModeBanner: false,
      locale: const Locale('uk'),
      supportedLocales: const [Locale('uk')],
      localizationsDelegates: GlobalMaterialLocalizations.delegates,
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
      ),
    );
  }
}
