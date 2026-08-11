import 'package:flutter/material.dart';

import '../../../l10n/generated/app_localizations.dart';
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
            label: AppLocalizations.of(context).guidePreviousTopic,
            title: previousLessonTitle,
            icon: Icons.arrow_back_rounded,
            onPressed: onOpenPrevious,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: GuideNavigationButton(
            label: AppLocalizations.of(context).guideNextTopic,
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
                  color: tokens.guideSecondaryAccent,
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
                          ? tokens.disabledAccent
                          : tokens.guideAccent,
                    ),
                  if (!iconTrailing) const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      title ?? AppLocalizations.of(context).guideNoTopic,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: onPressed == null
                            ? tokens.disabledForeground(tokens.mutedText)
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
                          ? tokens.disabledAccent
                          : tokens.guideAccent,
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
