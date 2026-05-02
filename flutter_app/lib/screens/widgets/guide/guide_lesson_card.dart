import 'package:flutter/material.dart';

import '../../../models/guide_lesson_status.dart';
import '../../../models/learning_bundle.dart';
import '../../../services/progress_snapshot.dart';
import '../../../theme/app_theme.dart';
import '../lesson_status_controls.dart';
import 'guide_section_pill.dart';

class GuideLessonCard extends StatelessWidget {
  const GuideLessonCard({
    super.key,
    required this.lesson,
    required this.status,
    required this.resolvedTitle,
    required this.resolvedSummary,
    required this.onTap,
    required this.onStatusSelected,
  });

  final LessonEntry lesson;
  final GuideLessonStatus status;
  final String resolvedTitle;
  final String resolvedSummary;
  final VoidCallback onTap;
  final ValueChanged<GuideLessonStatus> onStatusSelected;

  @override
  Widget build(BuildContext context) {
    final tokens = Theme.of(context).appTokens;
    final statusTheme = lessonStatusVisuals(status);
    final orderMatch = RegExp(r'^(\d+)').firstMatch(lesson.displayName);
    final orderLabel = orderMatch?.group(1) ?? '*';

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(22),
        onTap: onTap,
        child: Ink(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: tokens.elevatedSurface,
            borderRadius: BorderRadius.circular(22),
            boxShadow: [
              BoxShadow(
                color: tokens.shadowColor,
                blurRadius: 16,
                offset: Offset(0, 8),
              ),
            ],
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 44,
                height: 44,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: statusTheme.color.withValues(alpha: 0.14),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Text(
                  orderLabel,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                    color: statusTheme.color,
                  ),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (lesson.sectionLabel != null) ...[
                      GuideSectionPill(label: lesson.sectionLabel!),
                      const SizedBox(height: 8),
                    ],
                    Text(
                      resolvedTitle,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: Theme.of(context).brightness == Brightness.dark
                            ? const Color(0xFFE2D0A3)
                            : null,
                      ),
                    ),
                    if (resolvedSummary.isNotEmpty) ...[
                      const SizedBox(height: 6),
                      Text(
                        resolvedSummary,
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: tokens.mutedText,
                          height: 1.35,
                        ),
                      ),
                    ],
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Icon(
                          statusTheme.icon,
                          size: 18,
                          color: statusTheme.color,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          statusTheme.label,
                          style: Theme.of(context).textTheme.bodyMedium
                              ?.copyWith(
                                color: statusTheme.color,
                                fontWeight: FontWeight.w600,
                              ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Column(
                children: [
                  LessonStatusToggleButton(
                    status: status,
                    compact: true,
                    onPressed: () {
                      onStatusSelected(nextLessonProgressStatus(status));
                    },
                  ),
                  const SizedBox(height: 18),
                  const Icon(
                    Icons.arrow_forward_ios_rounded,
                    size: 18,
                    color: Color(0xFF8C6A2A),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
