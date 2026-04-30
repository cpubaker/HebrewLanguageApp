import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

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

@immutable
class AppDependencies {
  const AppDependencies({
    this.loader,
    this.documentLoader,
    this.progressStore,
    this.guideProgressStore,
    this.readingProgressStore,
    this.progressRepository,
    this.featureAccessService,
    this.aiContextService,
    this.aiContextSettingsStore,
    this.aiPracticeTextService,
    this.aiPracticeTextSettingsStore,
    this.audioPlayerFactory,
    this.audioPlaybackAwarenessFactory,
    this.themeModeStore,
  });

  final LearningBundleLoader? loader;
  final LessonDocumentLoader? documentLoader;
  final WordProgressStore? progressStore;
  final GuideProgressStore? guideProgressStore;
  final ReadingProgressStore? readingProgressStore;
  final LearningProgressRepository? progressRepository;
  final FeatureAccessService? featureAccessService;
  final AiContextService? aiContextService;
  final AiContextSettingsStore? aiContextSettingsStore;
  final AiPracticeTextService? aiPracticeTextService;
  final AiPracticeTextSettingsStore? aiPracticeTextSettingsStore;
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
    LearningProgressRepository? progressRepository,
    FeatureAccessService? featureAccessService,
    AiContextService? aiContextService,
    AiContextSettingsStore? aiContextSettingsStore,
    AiPracticeTextService? aiPracticeTextService,
    AiPracticeTextSettingsStore? aiPracticeTextSettingsStore,
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
      progressRepository: progressRepository ?? this.progressRepository,
      featureAccessService: featureAccessService ?? this.featureAccessService,
      aiContextService: aiContextService ?? this.aiContextService,
      aiContextSettingsStore:
          aiContextSettingsStore ?? this.aiContextSettingsStore,
      aiPracticeTextService:
          aiPracticeTextService ?? this.aiPracticeTextService,
      aiPracticeTextSettingsStore:
          aiPracticeTextSettingsStore ?? this.aiPracticeTextSettingsStore,
      audioPlayerFactory: audioPlayerFactory ?? this.audioPlayerFactory,
      audioPlaybackAwarenessFactory:
          audioPlaybackAwarenessFactory ?? this.audioPlaybackAwarenessFactory,
      themeModeStore: themeModeStore ?? this.themeModeStore,
    );
  }
}
