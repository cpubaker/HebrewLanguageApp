import 'package:flutter/material.dart';

import '../../../models/learning_bundle.dart';
import '../../../theme/app_theme.dart';

class GuideRelatedTopicsLoadingCard extends StatelessWidget {
  const GuideRelatedTopicsLoadingCard({super.key});

  @override
  Widget build(BuildContext context) {
    final tokens = Theme.of(context).appTokens;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: tokens.elevatedSurface,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: tokens.outlineSoft),
      ),
      child: Row(
        children: [
          const SizedBox(
            width: 16,
            height: 16,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: Color(0xFFB45309),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'Підбираємо пов’язані теми для швидких переходів.',
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(color: tokens.mutedText),
            ),
          ),
        ],
      ),
    );
  }
}

class GuideRelatedTopicsCard extends StatelessWidget {
  const GuideRelatedTopicsCard({
    super.key,
    required this.resolution,
    required this.onOpenLesson,
  });

  final GuideRelatedTopicsResolution resolution;
  final ValueChanged<LessonEntry> onOpenLesson;

  @override
  Widget build(BuildContext context) {
    final tokens = Theme.of(context).appTokens;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: tokens.elevatedSurface,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: tokens.outlineSoft),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Пов’язані теми',
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 10),
          if (resolution.resolvedTopics.isEmpty)
            Text(
              'Усі найближчі пов\'язані теми вже є в навігації вище.',
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(color: tokens.mutedText),
            )
          else
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                ...resolution.resolvedTopics.map(
                  (topic) => ActionChip(
                    avatar: const Icon(
                      Icons.link_rounded,
                      size: 18,
                      color: Color(0xFFB45309),
                    ),
                    label: Text(topic.label),
                    labelStyle: Theme.of(context).textTheme.labelLarge
                        ?.copyWith(
                          color: const Color(0xFF8C6A2A),
                          fontWeight: FontWeight.w700,
                        ),
                    backgroundColor: const Color(0xFFFDE7D4),
                    onPressed: () => onOpenLesson(topic.lesson),
                  ),
                ),
              ],
            ),
        ],
      ),
    );
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
