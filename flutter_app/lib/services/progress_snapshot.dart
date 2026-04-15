import '../models/guide_lesson_status.dart';
import '../models/learning_bundle.dart';
import '../models/learning_word.dart';

enum WordLearningState { unseen, known, needsReview }

WordLearningState classifyWordLearningState(LearningWord word) {
  final attempts = word.correct + word.wrong;
  if (attempts == 0) {
    return WordLearningState.unseen;
  }

  if (word.wrong > 0 || word.wrong > word.correct) {
    return WordLearningState.needsReview;
  }

  return WordLearningState.known;
}

GuideLessonStatus nextLessonProgressStatus(GuideLessonStatus status) {
  switch (status) {
    case GuideLessonStatus.unread:
      return GuideLessonStatus.studying;
    case GuideLessonStatus.studying:
      return GuideLessonStatus.read;
    case GuideLessonStatus.read:
      return GuideLessonStatus.unread;
  }
}

class FlashcardFocusSnapshot {
  const FlashcardFocusSnapshot({
    required this.total,
    required this.withContexts,
    required this.needsReview,
    required this.known,
  });

  factory FlashcardFocusSnapshot.fromWords(List<LearningWord> words) {
    var withContexts = 0;
    var needsReview = 0;
    var known = 0;

    for (final word in words) {
      if (word.contexts.isNotEmpty) {
        withContexts += 1;
      }

      switch (classifyWordLearningState(word)) {
        case WordLearningState.unseen:
          break;
        case WordLearningState.known:
          known += 1;
        case WordLearningState.needsReview:
          needsReview += 1;
      }
    }

    return FlashcardFocusSnapshot(
      total: words.length,
      withContexts: withContexts,
      needsReview: needsReview,
      known: known,
    );
  }

  final int total;
  final int withContexts;
  final int needsReview;
  final int known;
}

WritingLearningState classifyWritingLearningState(LearningWord word) {
  final attempts = word.writingCorrect + word.writingWrong;
  if (attempts == 0) {
    return WritingLearningState.unseen;
  }

  if (word.writingWrong > 0 || word.writingWrong > word.writingCorrect) {
    return WritingLearningState.needsReview;
  }

  return WritingLearningState.known;
}

enum WritingLearningState { unseen, known, needsReview }

class StudyProgressSnapshot {
  const StudyProgressSnapshot({
    required this.total,
    required this.seen,
    required this.known,
    required this.needsReview,
    required this.unseen,
  });

  factory StudyProgressSnapshot.fromWords(List<LearningWord> words) {
    var seen = 0;
    var known = 0;
    var needsReview = 0;

    for (final word in words) {
      switch (classifyWordLearningState(word)) {
        case WordLearningState.unseen:
          break;
        case WordLearningState.known:
          seen += 1;
          known += 1;
        case WordLearningState.needsReview:
          seen += 1;
          needsReview += 1;
      }
    }

    return StudyProgressSnapshot(
      total: words.length,
      seen: seen,
      known: known,
      needsReview: needsReview,
      unseen: words.length - seen,
    );
  }

  final int total;
  final int seen;
  final int known;
  final int needsReview;
  final int unseen;

  double get completionRatio => total == 0 ? 0 : seen / total;
}

class WritingProgressSnapshot {
  const WritingProgressSnapshot({
    required this.total,
    required this.practiced,
    required this.known,
    required this.needsReview,
    required this.unseen,
  });

  factory WritingProgressSnapshot.fromWords(List<LearningWord> words) {
    var practiced = 0;
    var known = 0;
    var needsReview = 0;

    for (final word in words) {
      switch (classifyWritingLearningState(word)) {
        case WritingLearningState.unseen:
          break;
        case WritingLearningState.known:
          practiced += 1;
          known += 1;
        case WritingLearningState.needsReview:
          practiced += 1;
          needsReview += 1;
      }
    }

    return WritingProgressSnapshot(
      total: words.length,
      practiced: practiced,
      known: known,
      needsReview: needsReview,
      unseen: words.length - practiced,
    );
  }

  final int total;
  final int practiced;
  final int known;
  final int needsReview;
  final int unseen;

  double get completionRatio => total == 0 ? 0 : practiced / total;
}

class LessonProgressSnapshot {
  const LessonProgressSnapshot({
    required this.total,
    required this.read,
    required this.studying,
    required this.unread,
  });

  factory LessonProgressSnapshot.fromStatuses({
    required int total,
    required Iterable<GuideLessonStatus> statuses,
  }) {
    var read = 0;
    var studying = 0;

    for (final status in statuses) {
      switch (status) {
        case GuideLessonStatus.read:
          read += 1;
        case GuideLessonStatus.studying:
          studying += 1;
        case GuideLessonStatus.unread:
          break;
      }
    }

    final unread = (total - read - studying).clamp(0, total);
    return LessonProgressSnapshot(
      total: total,
      read: read,
      studying: studying,
      unread: unread,
    );
  }

  factory LessonProgressSnapshot.fromLessons({
    required Iterable<LessonEntry> lessons,
    required Map<String, GuideLessonStatus> lessonStatuses,
  }) {
    final lessonList = lessons.toList(growable: false);
    return LessonProgressSnapshot.fromStatuses(
      total: lessonList.length,
      statuses: lessonList.map(
        (lesson) => lessonStatuses[lesson.assetPath] ?? GuideLessonStatus.unread,
      ),
    );
  }

  final int total;
  final int read;
  final int studying;
  final int unread;

  double get completionRatio => total == 0 ? 0 : read / total;

  String completedLabel(String noun) => 'Прочитано $read із $total $noun';
}
