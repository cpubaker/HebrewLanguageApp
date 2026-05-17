import 'dart:ui' show lerpDouble;

import 'package:flutter/material.dart';

@immutable
class AppThemeTokens extends ThemeExtension<AppThemeTokens> {
  const AppThemeTokens({
    required this.pagePadding,
    required this.sectionRadius,
    required this.panelRadius,
    required this.navBarBackground,
    required this.elevatedSurface,
    required this.subtleSurface,
    required this.mutedText,
    required this.secondaryText,
    required this.outlineSoft,
    required this.shadowColor,
    required this.progressTrack,
    required this.primaryAccent,
    required this.heroGradientStart,
    required this.heroGradientMiddle,
    required this.heroGradientEnd,
    required this.heroChipBackground,
    required this.heroText,
    required this.heroMutedText,
    required this.heroShadowColor,
    required this.successAccent,
    required this.dangerAccent,
    required this.warningAccent,
    required this.vocabularyAccent,
    required this.readingAccent,
    required this.infoAccent,
    required this.aiAccent,
    required this.newContentAccent,
    required this.contextAccent,
    required this.guideAccent,
    required this.guideSecondaryAccent,
    required this.guideChipBackground,
    required this.guideTitleText,
    required this.disabledAccent,
    required this.verbAccent,
    required this.verbAccentStrong,
    required this.verbImageGradientStart,
    required this.verbImageGradientMiddle,
    required this.verbImageGradientEnd,
    required this.practicePromptGradientStart,
    required this.practicePromptGradientEnd,
    required this.practiceChoiceGradientStart,
    required this.practiceChoiceGradientEnd,
    required this.successSurface,
    required this.dangerSurface,
    required this.warningSurface,
    required this.flashcardWrongSurface,
    required this.contextPanelSurface,
    required this.constructorActiveSurface,
    required this.constructorIdleSurface,
    required this.constructorIdleAccent,
    required this.wordNewSurface,
    required this.wordKnownSurface,
    required this.wordReviewSurface,
  });

  const AppThemeTokens.fallback()
    : pagePadding = const EdgeInsets.fromLTRB(20, 20, 20, 0),
      sectionRadius = 24,
      panelRadius = 18,
      navBarBackground = const Color(0xFFDCE9E1),
      elevatedSurface = Colors.white,
      subtleSurface = const Color(0xFFF7F3E8),
      mutedText = const Color(0xFF5F5A52),
      secondaryText = const Color(0xFF6C665D),
      outlineSoft = const Color(0x1F8C6A2A),
      shadowColor = const Color(0x14000000),
      progressTrack = const Color(0xFFEAE2D2),
      primaryAccent = const Color(0xFF2B5D4F),
      heroGradientStart = const Color(0xFF163832),
      heroGradientMiddle = const Color(0xFF2B5D4F),
      heroGradientEnd = const Color(0xFF8C6A2A),
      heroChipBackground = const Color(0x29FFFFFF),
      heroText = Colors.white,
      heroMutedText = const Color(0xFFF7F3E8),
      heroShadowColor = const Color(0x22000000),
      successAccent = const Color(0xFF0F766E),
      dangerAccent = const Color(0xFFB91C1C),
      warningAccent = const Color(0xFFB45309),
      vocabularyAccent = const Color(0xFF8C6A2A),
      readingAccent = const Color(0xFF1D4ED8),
      infoAccent = const Color(0xFF1D4ED8),
      aiAccent = const Color(0xFF8C3E9F),
      newContentAccent = const Color(0xFF5F6B2D),
      contextAccent = const Color(0xFF708244),
      guideAccent = const Color(0xFFB45309),
      guideSecondaryAccent = const Color(0xFF8C6A2A),
      guideChipBackground = const Color(0xFFFDE7D4),
      guideTitleText = const Color(0xFF2D2A24),
      disabledAccent = const Color(0xFFB7ADA1),
      verbAccent = const Color(0xFF7C3AED),
      verbAccentStrong = const Color(0xFF5B21B6),
      verbImageGradientStart = const Color(0xFFF7F1FF),
      verbImageGradientMiddle = const Color(0xFFF3ECFF),
      verbImageGradientEnd = const Color(0xFFF9F6ED),
      practicePromptGradientStart = const Color(0xFFF1F6F2),
      practicePromptGradientEnd = const Color(0xFFF7F3E8),
      practiceChoiceGradientStart = const Color(0xFFF6EFE1),
      practiceChoiceGradientEnd = const Color(0xFFEAF4EF),
      successSurface = const Color(0xFFEAF6F2),
      dangerSurface = const Color(0xFFFCECE8),
      warningSurface = const Color(0xFFF9EFE4),
      flashcardWrongSurface = const Color(0xFFEFD7CC),
      contextPanelSurface = const Color(0x0F163832),
      constructorActiveSurface = const Color(0xFFEEDDBA),
      constructorIdleSurface = const Color(0xFFFFFBF4),
      constructorIdleAccent = const Color(0xFFBCA67B),
      wordNewSurface = const Color(0xFFE6E7D6),
      wordKnownSurface = const Color(0xFFE7F8F2),
      wordReviewSurface = const Color(0xFFFFF1E6);

  final EdgeInsets pagePadding;
  final double sectionRadius;
  final double panelRadius;
  final Color navBarBackground;
  final Color elevatedSurface;
  final Color subtleSurface;
  final Color mutedText;
  final Color secondaryText;
  final Color outlineSoft;
  final Color shadowColor;
  final Color progressTrack;
  final Color primaryAccent;
  final Color heroGradientStart;
  final Color heroGradientMiddle;
  final Color heroGradientEnd;
  final Color heroChipBackground;
  final Color heroText;
  final Color heroMutedText;
  final Color heroShadowColor;
  final Color successAccent;
  final Color dangerAccent;
  final Color warningAccent;
  final Color vocabularyAccent;
  final Color readingAccent;
  final Color infoAccent;
  final Color aiAccent;
  final Color newContentAccent;
  final Color contextAccent;
  final Color guideAccent;
  final Color guideSecondaryAccent;
  final Color guideChipBackground;
  final Color guideTitleText;
  final Color disabledAccent;
  final Color verbAccent;
  final Color verbAccentStrong;
  final Color verbImageGradientStart;
  final Color verbImageGradientMiddle;
  final Color verbImageGradientEnd;
  final Color practicePromptGradientStart;
  final Color practicePromptGradientEnd;
  final Color practiceChoiceGradientStart;
  final Color practiceChoiceGradientEnd;
  final Color successSurface;
  final Color dangerSurface;
  final Color warningSurface;
  final Color flashcardWrongSurface;
  final Color contextPanelSurface;
  final Color constructorActiveSurface;
  final Color constructorIdleSurface;
  final Color constructorIdleAccent;
  final Color wordNewSurface;
  final Color wordKnownSurface;
  final Color wordReviewSurface;

  Color accentSubtleSurface(Color accent) => accent.withValues(alpha: 0.08);
  Color accentMutedSurface(Color accent) => accent.withValues(alpha: 0.10);
  Color accentSurface(Color accent) => accent.withValues(alpha: 0.12);
  Color accentMediumSurface(Color accent) => accent.withValues(alpha: 0.14);
  Color accentSoftBorder(Color accent) => accent.withValues(alpha: 0.16);
  Color accentBorder(Color accent) => accent.withValues(alpha: 0.18);
  Color accentStrongBorder(Color accent) => accent.withValues(alpha: 0.24);
  Color accentSelectedBorder(Color accent) => accent.withValues(alpha: 0.30);
  Color accentHandle(Color accent) => accent.withValues(alpha: 0.35);
  Color accentDecoration(Color accent) => accent.withValues(alpha: 0.40);
  Color disabledForeground(Color foreground) =>
      foreground.withValues(alpha: 0.75);
  Color inactiveForeground(Color foreground) =>
      foreground.withValues(alpha: 0.80);
  Color disabledHeroForeground(Color foreground) =>
      foreground.withValues(alpha: 0.65);
  Color heroButtonSurface(Color foreground) =>
      foreground.withValues(alpha: 0.16);
  Color heroControlSurface(Color foreground) =>
      foreground.withValues(alpha: 0.18);

  Color get guideBorder => accentSoftBorder(guideAccent);
  Color get guideIconSurface => accentMutedSurface(guideAccent);
  Color get guideSelectedSurface => accentSubtleSurface(guideAccent);
  Color get guideSelectedBorder => accentSelectedBorder(guideAccent);
  Color get verbSurface => accentSurface(verbAccent);

  @override
  AppThemeTokens copyWith({
    EdgeInsets? pagePadding,
    double? sectionRadius,
    double? panelRadius,
    Color? navBarBackground,
    Color? elevatedSurface,
    Color? subtleSurface,
    Color? mutedText,
    Color? secondaryText,
    Color? outlineSoft,
    Color? shadowColor,
    Color? progressTrack,
    Color? primaryAccent,
    Color? heroGradientStart,
    Color? heroGradientMiddle,
    Color? heroGradientEnd,
    Color? heroChipBackground,
    Color? heroText,
    Color? heroMutedText,
    Color? heroShadowColor,
    Color? successAccent,
    Color? dangerAccent,
    Color? warningAccent,
    Color? vocabularyAccent,
    Color? readingAccent,
    Color? infoAccent,
    Color? aiAccent,
    Color? newContentAccent,
    Color? contextAccent,
    Color? guideAccent,
    Color? guideSecondaryAccent,
    Color? guideChipBackground,
    Color? guideTitleText,
    Color? disabledAccent,
    Color? verbAccent,
    Color? verbAccentStrong,
    Color? verbImageGradientStart,
    Color? verbImageGradientMiddle,
    Color? verbImageGradientEnd,
    Color? practicePromptGradientStart,
    Color? practicePromptGradientEnd,
    Color? practiceChoiceGradientStart,
    Color? practiceChoiceGradientEnd,
    Color? successSurface,
    Color? dangerSurface,
    Color? warningSurface,
    Color? flashcardWrongSurface,
    Color? contextPanelSurface,
    Color? constructorActiveSurface,
    Color? constructorIdleSurface,
    Color? constructorIdleAccent,
    Color? wordNewSurface,
    Color? wordKnownSurface,
    Color? wordReviewSurface,
  }) {
    return AppThemeTokens(
      pagePadding: pagePadding ?? this.pagePadding,
      sectionRadius: sectionRadius ?? this.sectionRadius,
      panelRadius: panelRadius ?? this.panelRadius,
      navBarBackground: navBarBackground ?? this.navBarBackground,
      elevatedSurface: elevatedSurface ?? this.elevatedSurface,
      subtleSurface: subtleSurface ?? this.subtleSurface,
      mutedText: mutedText ?? this.mutedText,
      secondaryText: secondaryText ?? this.secondaryText,
      outlineSoft: outlineSoft ?? this.outlineSoft,
      shadowColor: shadowColor ?? this.shadowColor,
      progressTrack: progressTrack ?? this.progressTrack,
      primaryAccent: primaryAccent ?? this.primaryAccent,
      heroGradientStart: heroGradientStart ?? this.heroGradientStart,
      heroGradientMiddle: heroGradientMiddle ?? this.heroGradientMiddle,
      heroGradientEnd: heroGradientEnd ?? this.heroGradientEnd,
      heroChipBackground: heroChipBackground ?? this.heroChipBackground,
      heroText: heroText ?? this.heroText,
      heroMutedText: heroMutedText ?? this.heroMutedText,
      heroShadowColor: heroShadowColor ?? this.heroShadowColor,
      successAccent: successAccent ?? this.successAccent,
      dangerAccent: dangerAccent ?? this.dangerAccent,
      warningAccent: warningAccent ?? this.warningAccent,
      vocabularyAccent: vocabularyAccent ?? this.vocabularyAccent,
      readingAccent: readingAccent ?? this.readingAccent,
      infoAccent: infoAccent ?? this.infoAccent,
      aiAccent: aiAccent ?? this.aiAccent,
      newContentAccent: newContentAccent ?? this.newContentAccent,
      contextAccent: contextAccent ?? this.contextAccent,
      guideAccent: guideAccent ?? this.guideAccent,
      guideSecondaryAccent: guideSecondaryAccent ?? this.guideSecondaryAccent,
      guideChipBackground: guideChipBackground ?? this.guideChipBackground,
      guideTitleText: guideTitleText ?? this.guideTitleText,
      disabledAccent: disabledAccent ?? this.disabledAccent,
      verbAccent: verbAccent ?? this.verbAccent,
      verbAccentStrong: verbAccentStrong ?? this.verbAccentStrong,
      verbImageGradientStart:
          verbImageGradientStart ?? this.verbImageGradientStart,
      verbImageGradientMiddle:
          verbImageGradientMiddle ?? this.verbImageGradientMiddle,
      verbImageGradientEnd: verbImageGradientEnd ?? this.verbImageGradientEnd,
      practicePromptGradientStart:
          practicePromptGradientStart ?? this.practicePromptGradientStart,
      practicePromptGradientEnd:
          practicePromptGradientEnd ?? this.practicePromptGradientEnd,
      practiceChoiceGradientStart:
          practiceChoiceGradientStart ?? this.practiceChoiceGradientStart,
      practiceChoiceGradientEnd:
          practiceChoiceGradientEnd ?? this.practiceChoiceGradientEnd,
      successSurface: successSurface ?? this.successSurface,
      dangerSurface: dangerSurface ?? this.dangerSurface,
      warningSurface: warningSurface ?? this.warningSurface,
      flashcardWrongSurface:
          flashcardWrongSurface ?? this.flashcardWrongSurface,
      contextPanelSurface: contextPanelSurface ?? this.contextPanelSurface,
      constructorActiveSurface:
          constructorActiveSurface ?? this.constructorActiveSurface,
      constructorIdleSurface:
          constructorIdleSurface ?? this.constructorIdleSurface,
      constructorIdleAccent:
          constructorIdleAccent ?? this.constructorIdleAccent,
      wordNewSurface: wordNewSurface ?? this.wordNewSurface,
      wordKnownSurface: wordKnownSurface ?? this.wordKnownSurface,
      wordReviewSurface: wordReviewSurface ?? this.wordReviewSurface,
    );
  }

  @override
  AppThemeTokens lerp(ThemeExtension<AppThemeTokens>? other, double t) {
    if (other is! AppThemeTokens) {
      return this;
    }

    return AppThemeTokens(
      pagePadding: EdgeInsets.lerp(pagePadding, other.pagePadding, t)!,
      sectionRadius: lerpDouble(sectionRadius, other.sectionRadius, t)!,
      panelRadius: lerpDouble(panelRadius, other.panelRadius, t)!,
      navBarBackground: Color.lerp(
        navBarBackground,
        other.navBarBackground,
        t,
      )!,
      elevatedSurface: Color.lerp(elevatedSurface, other.elevatedSurface, t)!,
      subtleSurface: Color.lerp(subtleSurface, other.subtleSurface, t)!,
      mutedText: Color.lerp(mutedText, other.mutedText, t)!,
      secondaryText: Color.lerp(secondaryText, other.secondaryText, t)!,
      outlineSoft: Color.lerp(outlineSoft, other.outlineSoft, t)!,
      shadowColor: Color.lerp(shadowColor, other.shadowColor, t)!,
      progressTrack: Color.lerp(progressTrack, other.progressTrack, t)!,
      primaryAccent: Color.lerp(primaryAccent, other.primaryAccent, t)!,
      heroGradientStart: Color.lerp(
        heroGradientStart,
        other.heroGradientStart,
        t,
      )!,
      heroGradientMiddle: Color.lerp(
        heroGradientMiddle,
        other.heroGradientMiddle,
        t,
      )!,
      heroGradientEnd: Color.lerp(heroGradientEnd, other.heroGradientEnd, t)!,
      heroChipBackground: Color.lerp(
        heroChipBackground,
        other.heroChipBackground,
        t,
      )!,
      heroText: Color.lerp(heroText, other.heroText, t)!,
      heroMutedText: Color.lerp(heroMutedText, other.heroMutedText, t)!,
      heroShadowColor: Color.lerp(heroShadowColor, other.heroShadowColor, t)!,
      successAccent: Color.lerp(successAccent, other.successAccent, t)!,
      dangerAccent: Color.lerp(dangerAccent, other.dangerAccent, t)!,
      warningAccent: Color.lerp(warningAccent, other.warningAccent, t)!,
      vocabularyAccent: Color.lerp(
        vocabularyAccent,
        other.vocabularyAccent,
        t,
      )!,
      readingAccent: Color.lerp(readingAccent, other.readingAccent, t)!,
      infoAccent: Color.lerp(infoAccent, other.infoAccent, t)!,
      aiAccent: Color.lerp(aiAccent, other.aiAccent, t)!,
      newContentAccent: Color.lerp(
        newContentAccent,
        other.newContentAccent,
        t,
      )!,
      contextAccent: Color.lerp(contextAccent, other.contextAccent, t)!,
      guideAccent: Color.lerp(guideAccent, other.guideAccent, t)!,
      guideSecondaryAccent: Color.lerp(
        guideSecondaryAccent,
        other.guideSecondaryAccent,
        t,
      )!,
      guideChipBackground: Color.lerp(
        guideChipBackground,
        other.guideChipBackground,
        t,
      )!,
      guideTitleText: Color.lerp(guideTitleText, other.guideTitleText, t)!,
      disabledAccent: Color.lerp(disabledAccent, other.disabledAccent, t)!,
      verbAccent: Color.lerp(verbAccent, other.verbAccent, t)!,
      verbAccentStrong: Color.lerp(
        verbAccentStrong,
        other.verbAccentStrong,
        t,
      )!,
      verbImageGradientStart: Color.lerp(
        verbImageGradientStart,
        other.verbImageGradientStart,
        t,
      )!,
      verbImageGradientMiddle: Color.lerp(
        verbImageGradientMiddle,
        other.verbImageGradientMiddle,
        t,
      )!,
      verbImageGradientEnd: Color.lerp(
        verbImageGradientEnd,
        other.verbImageGradientEnd,
        t,
      )!,
      practicePromptGradientStart: Color.lerp(
        practicePromptGradientStart,
        other.practicePromptGradientStart,
        t,
      )!,
      practicePromptGradientEnd: Color.lerp(
        practicePromptGradientEnd,
        other.practicePromptGradientEnd,
        t,
      )!,
      practiceChoiceGradientStart: Color.lerp(
        practiceChoiceGradientStart,
        other.practiceChoiceGradientStart,
        t,
      )!,
      practiceChoiceGradientEnd: Color.lerp(
        practiceChoiceGradientEnd,
        other.practiceChoiceGradientEnd,
        t,
      )!,
      successSurface: Color.lerp(successSurface, other.successSurface, t)!,
      dangerSurface: Color.lerp(dangerSurface, other.dangerSurface, t)!,
      warningSurface: Color.lerp(warningSurface, other.warningSurface, t)!,
      flashcardWrongSurface: Color.lerp(
        flashcardWrongSurface,
        other.flashcardWrongSurface,
        t,
      )!,
      contextPanelSurface: Color.lerp(
        contextPanelSurface,
        other.contextPanelSurface,
        t,
      )!,
      constructorActiveSurface: Color.lerp(
        constructorActiveSurface,
        other.constructorActiveSurface,
        t,
      )!,
      constructorIdleSurface: Color.lerp(
        constructorIdleSurface,
        other.constructorIdleSurface,
        t,
      )!,
      constructorIdleAccent: Color.lerp(
        constructorIdleAccent,
        other.constructorIdleAccent,
        t,
      )!,
      wordNewSurface: Color.lerp(wordNewSurface, other.wordNewSurface, t)!,
      wordKnownSurface: Color.lerp(
        wordKnownSurface,
        other.wordKnownSurface,
        t,
      )!,
      wordReviewSurface: Color.lerp(
        wordReviewSurface,
        other.wordReviewSurface,
        t,
      )!,
    );
  }
}

extension AppThemeLookup on ThemeData {
  AppThemeTokens get appTokens =>
      extension<AppThemeTokens>() ?? const AppThemeTokens.fallback();
}

ThemeData buildLightAppTheme() => _buildAppTheme(_AppThemePalette.light());

ThemeData buildDarkAppTheme() => _buildAppTheme(_AppThemePalette.dark());

class _AppThemePalette {
  const _AppThemePalette({
    required this.brightness,
    required this.seedColor,
    required this.secondaryColor,
    required this.scaffoldBackground,
    required this.tokens,
  });

  factory _AppThemePalette.light() {
    return const _AppThemePalette(
      brightness: Brightness.light,
      seedColor: Color(0xFF2B5D4F),
      secondaryColor: Color(0xFF8C6A2A),
      scaffoldBackground: Color(0xFFF2EBDD),
      tokens: AppThemeTokens(
        pagePadding: EdgeInsets.fromLTRB(20, 20, 20, 0),
        sectionRadius: 24,
        panelRadius: 18,
        navBarBackground: Color(0xFFDCE9E1),
        elevatedSurface: Colors.white,
        subtleSurface: Color(0xFFF7F3E8),
        mutedText: Color(0xFF5F5A52),
        secondaryText: Color(0xFF6C665D),
        outlineSoft: Color(0x1F8C6A2A),
        shadowColor: Color(0x14000000),
        progressTrack: Color(0xFFEAE2D2),
        primaryAccent: Color(0xFF2B5D4F),
        heroGradientStart: Color(0xFF163832),
        heroGradientMiddle: Color(0xFF2B5D4F),
        heroGradientEnd: Color(0xFF8C6A2A),
        heroChipBackground: Color(0x29FFFFFF),
        heroText: Colors.white,
        heroMutedText: Color(0xFFF7F3E8),
        heroShadowColor: Color(0x22000000),
        successAccent: Color(0xFF0F766E),
        dangerAccent: Color(0xFFB91C1C),
        warningAccent: Color(0xFFB45309),
        vocabularyAccent: Color(0xFF8C6A2A),
        readingAccent: Color(0xFF1D4ED8),
        infoAccent: Color(0xFF1D4ED8),
        aiAccent: Color(0xFF8C3E9F),
        newContentAccent: Color(0xFF5F6B2D),
        contextAccent: Color(0xFF708244),
        guideAccent: Color(0xFFB45309),
        guideSecondaryAccent: Color(0xFF8C6A2A),
        guideChipBackground: Color(0xFFFDE7D4),
        guideTitleText: Color(0xFF2D2A24),
        disabledAccent: Color(0xFFB7ADA1),
        verbAccent: Color(0xFF7C3AED),
        verbAccentStrong: Color(0xFF5B21B6),
        verbImageGradientStart: Color(0xFFF7F1FF),
        verbImageGradientMiddle: Color(0xFFF3ECFF),
        verbImageGradientEnd: Color(0xFFF9F6ED),
        practicePromptGradientStart: Color(0xFFF1F6F2),
        practicePromptGradientEnd: Color(0xFFF7F3E8),
        practiceChoiceGradientStart: Color(0xFFF6EFE1),
        practiceChoiceGradientEnd: Color(0xFFEAF4EF),
        successSurface: Color(0xFFEAF6F2),
        dangerSurface: Color(0xFFFCECE8),
        warningSurface: Color(0xFFF9EFE4),
        flashcardWrongSurface: Color(0xFFEFD7CC),
        contextPanelSurface: Color(0x0F163832),
        constructorActiveSurface: Color(0xFFEEDDBA),
        constructorIdleSurface: Color(0xFFFFFBF4),
        constructorIdleAccent: Color(0xFFBCA67B),
        wordNewSurface: Color(0xFFE6E7D6),
        wordKnownSurface: Color(0xFFE7F8F2),
        wordReviewSurface: Color(0xFFFFF1E6),
      ),
    );
  }

  factory _AppThemePalette.dark() {
    return const _AppThemePalette(
      brightness: Brightness.dark,
      seedColor: Color(0xFF2B5D4F),
      secondaryColor: Color(0xFFC5965A),
      scaffoldBackground: Color(0xFF0F1715),
      tokens: AppThemeTokens(
        pagePadding: EdgeInsets.fromLTRB(20, 20, 20, 0),
        sectionRadius: 24,
        panelRadius: 18,
        navBarBackground: Color(0xFF18211D),
        elevatedSurface: Color(0xFF17201D),
        subtleSurface: Color(0xFF212D28),
        mutedText: Color(0xFFB8B0A4),
        secondaryText: Color(0xFFC8BDAF),
        outlineSoft: Color(0x335A6C64),
        shadowColor: Color(0x42000000),
        progressTrack: Color(0xFF2B3833),
        primaryAccent: Color(0xFF77BFAF),
        heroGradientStart: Color(0xFF081411),
        heroGradientMiddle: Color(0xFF18352C),
        heroGradientEnd: Color(0xFF5B4824),
        heroChipBackground: Color(0x24FFF8EE),
        heroText: Color(0xFFDAD1C3),
        heroMutedText: Color(0xFFC8BDAF),
        heroShadowColor: Color(0x44000000),
        successAccent: Color(0xFF38B2A5),
        dangerAccent: Color(0xFFE06B65),
        warningAccent: Color(0xFFD6A451),
        vocabularyAccent: Color(0xFFC5965A),
        readingAccent: Color(0xFF7EA4F4),
        infoAccent: Color(0xFF7EA4F4),
        aiAccent: Color(0xFFD08AE3),
        newContentAccent: Color(0xFFB6C36F),
        contextAccent: Color(0xFFA8BB70),
        guideAccent: Color(0xFFD6A451),
        guideSecondaryAccent: Color(0xFFC5965A),
        guideChipBackground: Color(0xFF4C3924),
        guideTitleText: Color(0xFFE2D0A3),
        disabledAccent: Color(0xFFB7ADA1),
        verbAccent: Color(0xFFD08AE3),
        verbAccentStrong: Color(0xFF8C65D8),
        verbImageGradientStart: Color(0xFFD8C4E6),
        verbImageGradientMiddle: Color(0xFFE2D0A3),
        verbImageGradientEnd: Color(0xFFA8BB70),
        practicePromptGradientStart: Color(0xFF17201D),
        practicePromptGradientEnd: Color(0xFF212D28),
        practiceChoiceGradientStart: Color(0xFF212D28),
        practiceChoiceGradientEnd: Color(0xFF17201D),
        successSurface: Color(0xFF17352F),
        dangerSurface: Color(0xFF3A2323),
        warningSurface: Color(0xFF3A2A1F),
        flashcardWrongSurface: Color(0xFF3F2620),
        contextPanelSurface: Color(0x382B5D4F),
        constructorActiveSurface: Color(0xFF5B4824),
        constructorIdleSurface: Color(0xFF17201D),
        constructorIdleAccent: Color(0xFFC5965A),
        wordNewSurface: Color(0xFF303820),
        wordKnownSurface: Color(0xFF17352F),
        wordReviewSurface: Color(0xFF3A2A1F),
      ),
    );
  }

  final Brightness brightness;
  final Color seedColor;
  final Color secondaryColor;
  final Color scaffoldBackground;
  final AppThemeTokens tokens;
}

ThemeData _buildAppTheme(_AppThemePalette palette) {
  final colorScheme =
      ColorScheme.fromSeed(
        seedColor: palette.seedColor,
        brightness: palette.brightness,
      ).copyWith(
        secondary: palette.secondaryColor,
        surface: palette.tokens.elevatedSurface,
        onSurface: palette.brightness == Brightness.dark
            ? const Color(0xFFD8D0C2)
            : const Color(0xFF2D2A24),
        onSurfaceVariant: palette.tokens.secondaryText,
        outline: palette.brightness == Brightness.dark
            ? const Color(0xFF55645E)
            : const Color(0xFF9F9484),
      );
  final baseTextTheme = Typography.blackMountainView.apply(
    bodyColor: colorScheme.onSurface,
    displayColor: colorScheme.onSurface,
  );

  return ThemeData(
    colorScheme: colorScheme,
    scaffoldBackgroundColor: palette.scaffoldBackground,
    useMaterial3: true,
    brightness: palette.brightness,
    extensions: [palette.tokens],
    textTheme: baseTextTheme.copyWith(
      headlineMedium: baseTextTheme.headlineMedium?.copyWith(
        fontWeight: FontWeight.w800,
      ),
      titleLarge: baseTextTheme.titleLarge?.copyWith(
        fontWeight: FontWeight.w700,
      ),
      bodyLarge: baseTextTheme.bodyLarge?.copyWith(
        color: colorScheme.onSurface,
      ),
      bodyMedium: baseTextTheme.bodyMedium?.copyWith(
        color: colorScheme.onSurface,
      ),
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.transparent,
      surfaceTintColor: Colors.transparent,
    ),
    navigationBarTheme: NavigationBarThemeData(
      backgroundColor: palette.tokens.navBarBackground,
      surfaceTintColor: Colors.transparent,
      indicatorColor: colorScheme.primary.withValues(
        alpha: palette.brightness == Brightness.dark ? 0.28 : 0.16,
      ),
      labelTextStyle: WidgetStateProperty.resolveWith((states) {
        final color = states.contains(WidgetState.selected)
            ? colorScheme.primary
            : palette.tokens.secondaryText;
        return baseTextTheme.labelSmall?.copyWith(
          color: color,
          fontWeight: FontWeight.w700,
        );
      }),
      iconTheme: WidgetStateProperty.resolveWith((states) {
        final color = states.contains(WidgetState.selected)
            ? colorScheme.primary
            : palette.tokens.secondaryText;
        return IconThemeData(color: color);
      }),
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
        backgroundColor: colorScheme.primary,
        foregroundColor: colorScheme.onPrimary,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(999)),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
        foregroundColor: colorScheme.primary,
        side: BorderSide(color: palette.tokens.outlineSoft),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(999)),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: palette.tokens.elevatedSurface,
      contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(20),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(20),
        borderSide: BorderSide(color: palette.tokens.outlineSoft),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(20),
        borderSide: BorderSide(color: palette.secondaryColor, width: 1.5),
      ),
    ),
  );
}
