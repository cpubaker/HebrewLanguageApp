import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

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

@immutable
class AppDependencies {
  const AppDependencies({
    this.loader,
    this.documentLoader,
    this.progressStore,
    this.guideProgressStore,
    this.readingProgressStore,
    this.sprintStatsStore,
    this.progressRepository,
    this.featureAccessService,
    this.aiContextService,
    this.aiContextSettingsStore,
    this.aiPracticeTextService,
    this.aiPracticeTextSettingsStore,
    this.appShellSettingsStore,
    this.audioPlayerFactory,
    this.audioPlaybackAwarenessFactory,
    this.themeModeStore,
  });

  final LearningBundleLoader? loader;
  final LessonDocumentLoader? documentLoader;
  final WordProgressStore? progressStore;
  final GuideProgressStore? guideProgressStore;
  final ReadingProgressStore? readingProgressStore;
  final SprintStatsStore? sprintStatsStore;
  final LearningProgressRepository? progressRepository;
  final FeatureAccessService? featureAccessService;
  final AiContextService? aiContextService;
  final AiContextSettingsStore? aiContextSettingsStore;
  final AiPracticeTextService? aiPracticeTextService;
  final AiPracticeTextSettingsStore? aiPracticeTextSettingsStore;
  final AppShellSettingsStore? appShellSettingsStore;
  final CreateVerbAudioPlayer? audioPlayerFactory;
  final CreateAudioPlaybackAwareness? audioPlaybackAwarenessFactory;
  final ThemeModeStore? themeModeStore;

  LearningProgressRepository resolveProgressRepository() {
    return progressRepository ??
        StoreBackedLearningProgressRepository(
          loader: loader ?? AssetLearningBundleLoader(),
          wordProgressStore:
              progressStore ?? SharedPreferencesWordProgressStore(),
          guideProgressStore:
              guideProgressStore ?? SharedPreferencesGuideProgressStore(),
          readingProgressStore:
              readingProgressStore ?? SharedPreferencesReadingProgressStore(),
        );
  }

  LessonDocumentLoader resolveDocumentLoader() {
    return documentLoader ?? AssetLessonDocumentLoader();
  }

  FeatureAccessService resolveFeatureAccessService() {
    return featureAccessService ?? const StaticFeatureAccessService();
  }

  SprintStatsStore resolveSprintStatsStore() {
    return sprintStatsStore ?? const SharedPreferencesSprintStatsStore();
  }

  AiContextService resolveAiContextService() {
    return aiContextService ?? createDefaultAiContextService();
  }

  AiContextSettingsStore resolveAiContextSettingsStore() {
    return aiContextSettingsStore ??
        const SharedPreferencesAiContextSettingsStore();
  }

  AiPracticeTextService resolveAiPracticeTextService() {
    return aiPracticeTextService ?? createDefaultAiPracticeTextService();
  }

  AiPracticeTextSettingsStore resolveAiPracticeTextSettingsStore() {
    return aiPracticeTextSettingsStore ??
        const SharedPreferencesAiPracticeTextSettingsStore();
  }

  AppShellSettingsStore resolveAppShellSettingsStore() {
    return appShellSettingsStore ??
        const SharedPreferencesAppShellSettingsStore();
  }

  CreateVerbAudioPlayer resolveAudioPlayerFactory() {
    return audioPlayerFactory ?? createAssetVerbAudioPlayer;
  }

  CreateAudioPlaybackAwareness resolveAudioPlaybackAwarenessFactory() {
    return audioPlaybackAwarenessFactory ?? createAudioPlaybackAwareness;
  }

  AppDependencies withOverrides({
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
  }) {
    return AppDependencies(
      loader: loader ?? this.loader,
      documentLoader: documentLoader ?? this.documentLoader,
      progressStore: progressStore ?? this.progressStore,
      guideProgressStore: guideProgressStore ?? this.guideProgressStore,
      readingProgressStore: readingProgressStore ?? this.readingProgressStore,
      sprintStatsStore: sprintStatsStore ?? this.sprintStatsStore,
      progressRepository: progressRepository ?? this.progressRepository,
      featureAccessService: featureAccessService ?? this.featureAccessService,
      aiContextService: aiContextService ?? this.aiContextService,
      aiContextSettingsStore:
          aiContextSettingsStore ?? this.aiContextSettingsStore,
      aiPracticeTextService:
          aiPracticeTextService ?? this.aiPracticeTextService,
      aiPracticeTextSettingsStore:
          aiPracticeTextSettingsStore ?? this.aiPracticeTextSettingsStore,
      appShellSettingsStore:
          appShellSettingsStore ?? this.appShellSettingsStore,
      audioPlayerFactory: audioPlayerFactory ?? this.audioPlayerFactory,
      audioPlaybackAwarenessFactory:
          audioPlaybackAwarenessFactory ?? this.audioPlaybackAwarenessFactory,
      themeModeStore: themeModeStore ?? this.themeModeStore,
    );
  }
}
