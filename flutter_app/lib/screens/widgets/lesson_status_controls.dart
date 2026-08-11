import 'package:flutter/material.dart';

import '../../l10n/generated/app_localizations.dart';
import '../../models/guide_lesson_status.dart';
import '../../theme/app_theme.dart';

class LessonStatusVisuals {
  const LessonStatusVisuals({
    required this.label,
    required this.icon,
    required this.color,
  });

  final String label;
  final IconData icon;
  final Color color;
}

LessonStatusVisuals lessonStatusVisuals(
  GuideLessonStatus status, {
  AppThemeTokens? tokens,
  AppLocalizations? localizations,
}) {
  final resolvedTokens = tokens ?? const AppThemeTokens.fallback();

  switch (status) {
    case GuideLessonStatus.unread:
      return LessonStatusVisuals(
        label: localizations?.lessonStatusUnread ?? 'Unread',
        icon: Icons.radio_button_unchecked_rounded,
        color: resolvedTokens.warningAccent,
      );
    case GuideLessonStatus.studying:
      return LessonStatusVisuals(
        label: localizations?.lessonStatusLearning ?? 'Learning',
        icon: Icons.timelapse_rounded,
        color: resolvedTokens.infoAccent,
      );
    case GuideLessonStatus.read:
      return LessonStatusVisuals(
        label: localizations?.lessonStatusRead ?? 'Read',
        icon: Icons.check_circle_rounded,
        color: resolvedTokens.successAccent,
      );
  }
}

class LessonStatusToggleButton extends StatelessWidget {
  const LessonStatusToggleButton({
    super.key,
    required this.status,
    required this.onPressed,
    this.foregroundColor,
    this.backgroundColor,
    this.compact = false,
  });

  final GuideLessonStatus status;
  final VoidCallback onPressed;
  final Color? foregroundColor;
  final Color? backgroundColor;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final tokens = Theme.of(context).appTokens;
    final visuals = lessonStatusVisuals(
      status,
      tokens: tokens,
      localizations: AppLocalizations.of(context),
    );
    final resolvedForegroundColor = foregroundColor ?? visuals.color;

    return Tooltip(
      message: AppLocalizations.of(context).lessonStatusChange,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(999),
          onTap: onPressed,
          child: Container(
            padding: compact
                ? const EdgeInsets.all(6)
                : const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: backgroundColor ?? Colors.transparent,
              borderRadius: BorderRadius.circular(999),
            ),
            child: compact
                ? Icon(visuals.icon, color: resolvedForegroundColor)
                : Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(visuals.icon, color: resolvedForegroundColor),
                      const SizedBox(width: 6),
                      Text(
                        visuals.label,
                        style: Theme.of(context).textTheme.labelLarge?.copyWith(
                          color: resolvedForegroundColor,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ],
                  ),
          ),
        ),
      ),
    );
  }
}
