import '../models/learning_bundle.dart';
import '../models/lesson_document.dart';
import 'lesson_document_loader.dart';

class GuideDetailLinkResolver {
  const GuideDetailLinkResolver({
    required this.lesson,
    required this.allLessons,
    required this.documentLoader,
  });

  final LessonEntry lesson;
  final List<LessonEntry> allLessons;
  final LessonDocumentLoader documentLoader;

  int get currentLessonIndex {
    return allLessons.indexWhere(
      (candidate) => candidate.assetPath == lesson.assetPath,
    );
  }

  LessonEntry? get previousLesson {
    final index = currentLessonIndex;
    if (index <= 0) {
      return null;
    }

    return allLessons[index - 1];
  }

  LessonEntry? get nextLesson {
    final index = currentLessonIndex;
    if (index < 0 || index >= allLessons.length - 1) {
      return null;
    }

    return allLessons[index + 1];
  }

  Future<Map<String, String>> resolveAdjacentLessonTitles() async {
    final titlesByAssetPath = <String, String>{};
    final adjacentLessons = [
      previousLesson,
      nextLesson,
    ].whereType<LessonEntry>();

    for (final adjacentLesson in adjacentLessons) {
      try {
        final document = await documentLoader.load(adjacentLesson.assetPath);
        final title = document.title.trim();
        if (title.isNotEmpty) {
          titlesByAssetPath[adjacentLesson.assetPath] = title;
        }
      } catch (_) {
        // Keep navigation usable even if an optional adjacent title fails.
      }
    }

    return titlesByAssetPath;
  }

  Future<GuideRelatedTopicsResolution> resolveRelatedTopics({
    LessonDocument? currentDocument,
  }) async {
    final resolvedCurrentDocument =
        currentDocument ?? await documentLoader.load(lesson.assetPath);
    if (allLessons.isEmpty) {
      return const GuideRelatedTopicsResolution.empty();
    }

    final titlesByAssetPath = <String, String>{};
    final lessonsById = <String, LessonEntry>{};
    for (final candidateLesson in allLessons) {
      if (candidateLesson.assetPath == lesson.assetPath) {
        titlesByAssetPath[candidateLesson.assetPath] =
            resolvedCurrentDocument.title;
      } else {
        try {
          final document = await documentLoader.load(candidateLesson.assetPath);
          titlesByAssetPath[candidateLesson.assetPath] = document.title;
        } catch (_) {
          // Ignore broken optional documents and keep other links working.
        }
      }

      final lessonId = candidateLesson.lessonId;
      if (lessonId != null && lessonId.trim().isNotEmpty) {
        lessonsById[lessonId] = candidateLesson;
      }
    }

    final resolvedTopics = <GuideResolvedTopic>[];
    final usedAssetPaths = <String>{};
    final usedTopicKeys = <String>{};
    final currentLessonTitle =
        titlesByAssetPath[lesson.assetPath] ?? fallbackLessonTitle(lesson);
    final normalizedCurrentLessonTitle = normalizeForGuideTopicMatching(
      currentLessonTitle,
    );

    void addResolvedTopic(LessonEntry candidateLesson) {
      final resolvedLabel =
          titlesByAssetPath[candidateLesson.assetPath] ??
          fallbackLessonTitle(candidateLesson);
      final normalizedResolvedLabel = normalizeForGuideTopicMatching(
        resolvedLabel,
      );
      final isAdjacentLesson =
          candidateLesson.assetPath == previousLesson?.assetPath ||
          candidateLesson.assetPath == nextLesson?.assetPath;
      if (candidateLesson.assetPath == lesson.assetPath ||
          isAdjacentLesson ||
          !usedAssetPaths.add(candidateLesson.assetPath) ||
          normalizedResolvedLabel.isEmpty ||
          !usedTopicKeys.add(normalizedResolvedLabel)) {
        return;
      }

      resolvedTopics.add(
        GuideResolvedTopic(label: resolvedLabel, lesson: candidateLesson),
      );
    }

    for (final relatedId in lesson.relatedIds) {
      final matchingLesson = lessonsById[relatedId];
      if (matchingLesson != null) {
        addResolvedTopic(matchingLesson);
      }
    }

    if (resolvedCurrentDocument.relatedTopics.isEmpty) {
      return GuideRelatedTopicsResolution(resolvedTopics: resolvedTopics);
    }

    for (final topic in resolvedCurrentDocument.relatedTopics) {
      if (normalizeForGuideTopicMatching(topic) ==
          normalizedCurrentLessonTitle) {
        continue;
      }

      final matchingLesson = matchGuideRelatedTopic(
        topic,
        allLessons: allLessons,
        titlesByAssetPath: titlesByAssetPath,
      );
      if (matchingLesson != null) {
        addResolvedTopic(matchingLesson);
      }
    }

    return GuideRelatedTopicsResolution(resolvedTopics: resolvedTopics);
  }
}

class GuideRelatedTopicsResolution {
  const GuideRelatedTopicsResolution({required this.resolvedTopics});

  const GuideRelatedTopicsResolution.empty()
    : resolvedTopics = const <GuideResolvedTopic>[];

  final List<GuideResolvedTopic> resolvedTopics;
}

class GuideResolvedTopic {
  const GuideResolvedTopic({required this.label, required this.lesson});

  final String label;
  final LessonEntry lesson;
}

LessonEntry? matchGuideRelatedTopic(
  String topic, {
  required List<LessonEntry> allLessons,
  required Map<String, String> titlesByAssetPath,
}) {
  final normalizedTopic = normalizeForGuideTopicMatching(topic);
  if (normalizedTopic.isEmpty) {
    return null;
  }

  final topicTokens = normalizedTopic
      .split(' ')
      .where((token) => token.isNotEmpty)
      .toSet();
  LessonEntry? bestLesson;
  var bestScore = 0;

  for (final lesson in allLessons) {
    final candidates = <String>[
      titlesByAssetPath[lesson.assetPath] ?? '',
      fallbackLessonTitle(lesson),
      ...lesson.aliases,
    ];

    for (final candidate in candidates) {
      final score = guideTopicMatchScore(
        normalizedTopic: normalizedTopic,
        topicTokens: topicTokens,
        candidate: candidate,
      );
      if (score > bestScore) {
        bestScore = score;
        bestLesson = lesson;
      }
    }
  }

  if (bestScore < 20) {
    return null;
  }

  return bestLesson;
}

int guideTopicMatchScore({
  required String normalizedTopic,
  required Set<String> topicTokens,
  required String candidate,
}) {
  final normalizedCandidate = normalizeForGuideTopicMatching(candidate);
  if (normalizedCandidate.isEmpty) {
    return 0;
  }

  if (normalizedCandidate == normalizedTopic) {
    return 100;
  }

  if (normalizedCandidate.contains(normalizedTopic) ||
      normalizedTopic.contains(normalizedCandidate)) {
    return 80;
  }

  final candidateTokens = normalizedCandidate
      .split(' ')
      .where((token) => token.isNotEmpty)
      .toSet();
  final overlap = topicTokens.intersection(candidateTokens).length;
  if (overlap == 0) {
    return 0;
  }

  var score = overlap * 10;
  if (topicTokens.every(candidateTokens.contains)) {
    score += 20;
  }
  if (candidateTokens.every(topicTokens.contains)) {
    score += 15;
  }

  return score;
}

String normalizeForGuideTopicMatching(String value) {
  return value
      .toLowerCase()
      .replaceAll(RegExp(r'[\u0591-\u05C7]'), '')
      .replaceAll(RegExp(r'[^0-9a-z\u0400-\u04ff\u0590-\u05ff]+'), ' ')
      .trim()
      .replaceAll(RegExp(r'\s+'), ' ');
}

String fallbackLessonTitle(LessonEntry lesson) {
  return lesson.displayName.replaceFirst(RegExp(r'^\d+\s+'), '').trim();
}
