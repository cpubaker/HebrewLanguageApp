import 'package:flutter/material.dart';

import '../../../models/guide_lesson_status.dart';
import '../../../models/learning_bundle.dart';
import '../../../theme/app_theme.dart';
import '../lesson_status_controls.dart';
import 'guide_section_pill.dart';

class GuideDetailHeader extends StatelessWidget {
  const GuideDetailHeader({
    super.key,
    required this.lesson,
    required this.title,
    required this.summary,
    required this.status,
    required this.onStatusPressed,
  });

  final LessonEntry lesson;
  final String title;
  final String summary;
  final GuideLessonStatus status;
  final VoidCallback onStatusPressed;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final tokens = theme.appTokens;
    final heroForeground = tokens.heroText;
    final heroMutedForeground = tokens.heroMutedText;
    final trimmedSummary = summary.trim();

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),
        gradient: LinearGradient(
          colors: [tokens.guideSecondaryAccent, tokens.guideAccent],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              if (lesson.sectionLabel != null)
                GuideSectionPill(
                  label: lesson.sectionLabel!,
                  foregroundColor: heroForeground,
                  backgroundColor: tokens.heroControlSurface(heroForeground),
                ),
              const Spacer(),
              LessonStatusToggleButton(
                status: status,
                onPressed: onStatusPressed,
                foregroundColor: heroForeground,
                backgroundColor: tokens.heroControlSurface(heroForeground),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Text(
            title,
            style: theme.textTheme.headlineMedium?.copyWith(
              color: heroForeground,
              fontWeight: FontWeight.w800,
            ),
          ),
          if (trimmedSummary.isNotEmpty) ...[
            const SizedBox(height: 14),
            Text(
              trimmedSummary,
              style: theme.textTheme.bodyLarge?.copyWith(
                color: heroMutedForeground,
                height: 1.45,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
