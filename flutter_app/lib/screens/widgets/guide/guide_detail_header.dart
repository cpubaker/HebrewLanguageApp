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
    final heroForeground = theme.brightness == Brightness.dark
        ? tokens.heroText
        : Colors.white;
    final heroMutedForeground = theme.brightness == Brightness.dark
        ? tokens.heroMutedText
        : Colors.white.withValues(alpha: 0.92);
    final trimmedSummary = summary.trim();

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),
        gradient: const LinearGradient(
          colors: [Color(0xFF8C6A2A), Color(0xFFB45309)],
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
                  backgroundColor: heroForeground.withValues(alpha: 0.18),
                ),
              const Spacer(),
              LessonStatusToggleButton(
                status: status,
                onPressed: onStatusPressed,
                foregroundColor: heroForeground,
                backgroundColor: heroForeground.withValues(alpha: 0.18),
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
