import 'package:flutter/material.dart';

import '../../models/guide_lesson_status.dart';

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

LessonStatusVisuals lessonStatusVisuals(GuideLessonStatus status) {
  switch (status) {
    case GuideLessonStatus.unread:
      return const LessonStatusVisuals(
        label: 'Не прочитано',
        icon: Icons.radio_button_unchecked_rounded,
        color: Color(0xFF8C6A2A),
      );
    case GuideLessonStatus.studying:
      return const LessonStatusVisuals(
        label: 'Вивчається',
        icon: Icons.timelapse_rounded,
        color: Color(0xFF2563EB),
      );
    case GuideLessonStatus.read:
      return const LessonStatusVisuals(
        label: 'Прочитано',
        icon: Icons.check_circle_rounded,
        color: Color(0xFF0F766E),
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
    final visuals = lessonStatusVisuals(status);
    final resolvedForegroundColor = foregroundColor ?? visuals.color;

    return Tooltip(
      message: 'Змінити статус уроку',
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
