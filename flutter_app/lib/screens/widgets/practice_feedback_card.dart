import 'package:flutter/material.dart';

import '../../theme/app_theme.dart';

enum PracticeFeedbackTone { neutral, success, error }

class PracticeFeedbackCard extends StatelessWidget {
  const PracticeFeedbackCard({
    super.key,
    required this.tone,
    required this.message,
    this.title,
    this.primaryText,
    this.primaryTextDirection,
    this.footerText,
    this.extraContent,
    this.compact = false,
    this.showMessage = true,
  });

  final PracticeFeedbackTone tone;
  final String message;
  final String? title;
  final String? primaryText;
  final TextDirection? primaryTextDirection;
  final String? footerText;
  final Widget? extraContent;
  final bool compact;
  final bool showMessage;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final tokens = theme.appTokens;
    final visuals = _PracticeFeedbackVisuals.resolve(
      tone: tone,
      neutralBackground: tokens.subtleSurface,
      neutralForeground: tokens.secondaryText,
      successBackground: tokens.successSurface,
      errorBackground: tokens.dangerSurface,
      successAccent: tokens.successAccent,
      dangerAccent: tokens.dangerAccent,
    );

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: visuals.background,
        borderRadius: BorderRadius.circular(compact ? 22 : 24),
      ),
      child: compact
          ? _CompactPracticeFeedback(
              icon: visuals.icon,
              accent: visuals.accent,
              message: message,
            )
          : _DetailedPracticeFeedback(
              icon: visuals.icon,
              accent: visuals.accent,
              title: title,
              message: message,
              showMessage: showMessage,
              primaryText: primaryText,
              primaryTextDirection: primaryTextDirection,
              footerText: footerText,
              extraContent: extraContent,
            ),
    );
  }
}

class _CompactPracticeFeedback extends StatelessWidget {
  const _CompactPracticeFeedback({
    required this.icon,
    required this.accent,
    required this.message,
  });

  final IconData icon;
  final Color accent;
  final String message;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: accent),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            message,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: accent,
              fontWeight: FontWeight.w700,
              height: 1.4,
            ),
          ),
        ),
      ],
    );
  }
}

class _DetailedPracticeFeedback extends StatelessWidget {
  const _DetailedPracticeFeedback({
    required this.icon,
    required this.accent,
    required this.message,
    required this.showMessage,
    this.title,
    this.primaryText,
    this.primaryTextDirection,
    this.footerText,
    this.extraContent,
  });

  final IconData icon;
  final Color accent;
  final String message;
  final bool showMessage;
  final String? title;
  final String? primaryText;
  final TextDirection? primaryTextDirection;
  final String? footerText;
  final Widget? extraContent;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final tokens = theme.appTokens;

    return Column(
      children: [
        if (title != null) ...[
          Wrap(
            alignment: WrapAlignment.center,
            crossAxisAlignment: WrapCrossAlignment.center,
            spacing: 8,
            runSpacing: 6,
            children: [
              Icon(icon, color: accent, size: 22),
              Text(
                title!,
                textAlign: TextAlign.center,
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w800,
                  color: tokens.mutedText,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
        ],
        if (primaryText != null) ...[
          Text(
            primaryText!,
            textDirection: primaryTextDirection,
            textAlign: TextAlign.center,
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.w800,
              color: theme.colorScheme.onSurface,
            ),
          ),
          if (extraContent != null) ...[
            const SizedBox(height: 10),
            extraContent!,
          ],
          if (showMessage || footerText != null) const SizedBox(height: 8),
        ],
        if (showMessage)
          Text(
            message,
            textAlign: TextAlign.center,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: tokens.secondaryText,
              height: 1.45,
            ),
          ),
        if (footerText != null) ...[
          if (showMessage) const SizedBox(height: 10),
          Text(
            footerText!,
            textAlign: TextAlign.center,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: tokens.secondaryText,
            ),
          ),
        ],
      ],
    );
  }
}

class _PracticeFeedbackVisuals {
  const _PracticeFeedbackVisuals({
    required this.background,
    required this.accent,
    required this.icon,
  });

  final Color background;
  final Color accent;
  final IconData icon;

  static _PracticeFeedbackVisuals resolve({
    required PracticeFeedbackTone tone,
    required Color neutralBackground,
    required Color neutralForeground,
    required Color successBackground,
    required Color errorBackground,
    required Color successAccent,
    required Color dangerAccent,
  }) {
    return switch (tone) {
      PracticeFeedbackTone.success => _PracticeFeedbackVisuals(
        background: successBackground,
        accent: successAccent,
        icon: Icons.check_circle_rounded,
      ),
      PracticeFeedbackTone.error => _PracticeFeedbackVisuals(
        background: errorBackground,
        accent: dangerAccent,
        icon: Icons.cancel_rounded,
      ),
      PracticeFeedbackTone.neutral => _PracticeFeedbackVisuals(
        background: neutralBackground,
        accent: neutralForeground,
        icon: Icons.info_outline_rounded,
      ),
    };
  }
}
