import 'package:flutter/material.dart';

import '../../../theme/app_theme.dart';

class GuideAdjacentLessonsCard extends StatelessWidget {
  const GuideAdjacentLessonsCard({
    super.key,
    this.previousLessonTitle,
    this.nextLessonTitle,
    this.onOpenPrevious,
    this.onOpenNext,
  });

  final String? previousLessonTitle;
  final String? nextLessonTitle;
  final VoidCallback? onOpenPrevious;
  final VoidCallback? onOpenNext;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: GuideNavigationButton(
            label: 'Попередня тема',
            title: previousLessonTitle,
            icon: Icons.arrow_back_rounded,
            onPressed: onOpenPrevious,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: GuideNavigationButton(
            label: 'Наступна тема',
            title: nextLessonTitle,
            icon: Icons.arrow_forward_rounded,
            iconTrailing: true,
            onPressed: onOpenNext,
          ),
        ),
      ],
    );
  }
}

class GuideNavigationButton extends StatelessWidget {
  const GuideNavigationButton({
    super.key,
    required this.label,
    required this.title,
    required this.icon,
    required this.onPressed,
    this.iconTrailing = false,
  });

  final String label;
  final String? title;
  final IconData icon;
  final VoidCallback? onPressed;
  final bool iconTrailing;

  @override
  Widget build(BuildContext context) {
    final tokens = Theme.of(context).appTokens;
    return Container(
      decoration: BoxDecoration(
        color: tokens.elevatedSurface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: tokens.outlineSoft),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: onPressed,
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: Theme.of(context).textTheme.labelLarge?.copyWith(
                  color: const Color(0xFF8C6A2A),
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  if (!iconTrailing)
                    Icon(
                      icon,
                      size: 18,
                      color: onPressed == null
                          ? const Color(0xFFB7ADA1)
                          : const Color(0xFFB45309),
                    ),
                  if (!iconTrailing) const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      title ?? 'Немає',
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: onPressed == null
                            ? tokens.mutedText.withValues(alpha: 0.75)
                            : tokens.secondaryText,
                        fontWeight: FontWeight.w600,
                        height: 1.35,
                      ),
                    ),
                  ),
                  if (iconTrailing) const SizedBox(width: 8),
                  if (iconTrailing)
                    Icon(
                      icon,
                      size: 18,
                      color: onPressed == null
                          ? const Color(0xFFB7ADA1)
                          : const Color(0xFFB45309),
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
