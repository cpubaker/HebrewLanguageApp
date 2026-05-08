import 'dart:async';

import 'package:hebrew_language_flutter/models/guide_lesson_status.dart';
import 'package:hebrew_language_flutter/models/learning_word.dart';
import 'package:hebrew_language_flutter/services/app_shell_settings_store.dart';
import 'package:hebrew_language_flutter/services/audio_playback_awareness.dart';
import 'package:hebrew_language_flutter/services/guide_progress_store.dart';
import 'package:hebrew_language_flutter/services/learning_audio_player.dart';
import 'package:hebrew_language_flutter/services/reading_progress_store.dart';
import 'package:hebrew_language_flutter/services/sprint_stats_store.dart';
import 'package:hebrew_language_flutter/services/theme_mode_store.dart';
import 'package:hebrew_language_flutter/services/verb_audio_player.dart';
import 'package:hebrew_language_flutter/services/word_progress_store.dart';

class FakeWordProgressStore implements WordProgressStore {
  FakeWordProgressStore({Map<String, StoredWordProgress>? initialProgress})
    : savedByWordId = <String, StoredWordProgress>{...?initialProgress};

  final Map<String, StoredWordProgress> savedByWordId;
  final List<String> savedWordIds = <String>[];

  @override
  Future<Map<String, StoredWordProgress>> load() async {
    return Map<String, StoredWordProgress>.from(savedByWordId);
  }

  @override
  Future<void> saveWord(LearningWord word) async {
    savedWordIds.add(word.wordId);
    savedByWordId[word.wordId] = StoredWordProgress(
      wordId: word.wordId,
      correct: word.correct,
      wrong: word.wrong,
      lastCorrect: word.lastCorrect,
      lastReviewedAt: word.lastReviewedAt,
      lastReviewCorrect: word.lastReviewCorrect,
      writingCorrect: word.writingCorrect,
      writingWrong: word.writingWrong,
      writingLastCorrect: word.writingLastCorrect,
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
    String lessonKey,
    GuideLessonStatus status,
  ) async {
    if (status == GuideLessonStatus.unread) {
      lessonStatuses.remove(lessonKey);
    } else {
      lessonStatuses[lessonKey] = status;
    }
  }
}

class FakeReadingProgressStore implements ReadingProgressStore {
  FakeReadingProgressStore({Map<String, GuideLessonStatus>? initialStatuses})
    : lessonStatuses = <String, GuideLessonStatus>{...?initialStatuses};

  final Map<String, GuideLessonStatus> lessonStatuses;

  @override
  Future<Map<String, GuideLessonStatus>> loadLessonStatuses() async {
    return Map<String, GuideLessonStatus>.from(lessonStatuses);
  }

  @override
  Future<void> setLessonStatus(
    String lessonKey,
    GuideLessonStatus status,
  ) async {
    if (status == GuideLessonStatus.unread) {
      lessonStatuses.remove(lessonKey);
    } else {
      lessonStatuses[lessonKey] = status;
    }
  }
}

class ThrowingGuideProgressStore extends FakeGuideProgressStore {
  int attemptedWrites = 0;

  @override
  Future<void> setLessonStatus(
    String lessonKey,
    GuideLessonStatus status,
  ) async {
    attemptedWrites += 1;
    throw StateError('Simulated persistence failure');
  }
}

class ThrowingReadingProgressStore extends FakeReadingProgressStore {
  int attemptedWrites = 0;

  @override
  Future<void> setLessonStatus(
    String lessonKey,
    GuideLessonStatus status,
  ) async {
    attemptedWrites += 1;
    throw StateError('Simulated persistence failure');
  }
}

class FakeSprintStatsStore implements SprintStatsStore {
  FakeSprintStatsStore([this.stats = const SprintStats.empty()]);

  SprintStats stats;
  final List<SprintStats> savedStats = <SprintStats>[];

  @override
  Future<SprintStats> load() async => stats;

  @override
  Future<void> save(SprintStats stats) async {
    this.stats = stats;
    savedStats.add(stats);
  }
}

class FakeLearningAudioPlayer implements LearningAudioPlayer {
  FakeLearningAudioPlayer({
    this.assetExistsResult = true,
    bool? prepareAssetResult,
    Set<String>? availableAssets,
    this.emitPlaybackEvents = false,
  }) : prepareAssetResult = prepareAssetResult ?? assetExistsResult,
       availableAssets = availableAssets == null
           ? null
           : Set<String>.unmodifiable(availableAssets);

  final bool assetExistsResult;
  final bool prepareAssetResult;
  final Set<String>? availableAssets;
  final bool emitPlaybackEvents;
  final List<String> playedAssets = <String>[];
  final List<String> preparedAssets = <String>[];
  final StreamController<bool> _isPlayingController =
      StreamController<bool>.broadcast();
  bool stopped = false;
  bool disposed = false;

  @override
  Stream<bool> get isPlayingStream => _isPlayingController.stream;

  @override
  Future<bool> assetExists(String assetPath) async {
    final assets = availableAssets;
    return assets == null ? assetExistsResult : assets.contains(assetPath);
  }

  @override
  Future<bool> prepareAsset(String assetPath) async {
    final assets = availableAssets;
    if (assets != null && !assets.contains(assetPath)) {
      return false;
    }
    preparedAssets.add(assetPath);
    return prepareAssetResult;
  }

  @override
  Future<void> playAsset(String assetPath) async {
    playedAssets.add(assetPath);
    if (emitPlaybackEvents && !disposed) {
      _isPlayingController.add(true);
    }
  }

  @override
  Future<void> stop() async {
    stopped = true;
    if (emitPlaybackEvents && !disposed) {
      _isPlayingController.add(false);
    }
  }

  @override
  Future<void> dispose() async {
    disposed = true;
    await _isPlayingController.close();
  }
}

class FakeVerbAudioPlayer extends FakeLearningAudioPlayer
    implements VerbAudioPlayer {
  FakeVerbAudioPlayer({
    Set<String> availableAssets = const {
      'assets/learning/input/audio/verbs/walk.mp3',
    },
  }) : super(
         assetExistsResult: false,
         prepareAssetResult: true,
         availableAssets: availableAssets,
       );
}

class FakeLearningAudioPlayerFactory {
  final List<FakeLearningAudioPlayer> players = <FakeLearningAudioPlayer>[];

  FakeLearningAudioPlayer create() {
    final player = FakeLearningAudioPlayer();
    players.add(player);
    return player;
  }

  FakeLearningAudioPlayer get primaryPlayer => players.first;
}

class FakeAudioPlaybackAwareness implements AudioPlaybackAwareness {
  FakeAudioPlaybackAwareness({this.hint});

  final AudioPlaybackHint? hint;

  @override
  Future<AudioPlaybackHint?> checkBeforePlayback() async => hint;
}

class FakeThemeModeStore implements ThemeModeStore {
  FakeThemeModeStore({this.initialPreference = AppThemePreference.light});

  final AppThemePreference initialPreference;
  final List<AppThemePreference> savedPreferences = <AppThemePreference>[];

  @override
  Future<AppThemePreference> load() async => initialPreference;

  @override
  Future<void> save(AppThemePreference preference) async {
    savedPreferences.add(preference);
  }
}

class FakeAppShellSettingsStore implements AppShellSettingsStore {
  FakeAppShellSettingsStore({this.initialAutoHideBottomNavOnScroll = true});

  final bool initialAutoHideBottomNavOnScroll;
  final List<bool> savedAutoHideBottomNavValues = <bool>[];

  @override
  Future<bool> loadAutoHideBottomNavOnScroll() async {
    return initialAutoHideBottomNavOnScroll;
  }

  @override
  Future<void> saveAutoHideBottomNavOnScroll(bool enabled) async {
    savedAutoHideBottomNavValues.add(enabled);
  }
}
