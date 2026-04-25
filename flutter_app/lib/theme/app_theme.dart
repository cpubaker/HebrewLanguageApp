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
    required this.heroGradientStart,
    required this.heroGradientMiddle,
    required this.heroGradientEnd,
    required this.heroChipBackground,
    required this.heroText,
    required this.heroMutedText,
    required this.heroShadowColor,
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
      heroGradientStart = const Color(0xFF163832),
      heroGradientMiddle = const Color(0xFF2B5D4F),
      heroGradientEnd = const Color(0xFF8C6A2A),
      heroChipBackground = const Color(0x29FFFFFF),
      heroText = Colors.white,
      heroMutedText = const Color(0xFFF7F3E8),
      heroShadowColor = const Color(0x22000000);

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
  final Color heroGradientStart;
  final Color heroGradientMiddle;
  final Color heroGradientEnd;
  final Color heroChipBackground;
  final Color heroText;
  final Color heroMutedText;
  final Color heroShadowColor;

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
    Color? heroGradientStart,
    Color? heroGradientMiddle,
    Color? heroGradientEnd,
    Color? heroChipBackground,
    Color? heroText,
    Color? heroMutedText,
    Color? heroShadowColor,
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
      heroGradientStart: heroGradientStart ?? this.heroGradientStart,
      heroGradientMiddle: heroGradientMiddle ?? this.heroGradientMiddle,
      heroGradientEnd: heroGradientEnd ?? this.heroGradientEnd,
      heroChipBackground: heroChipBackground ?? this.heroChipBackground,
      heroText: heroText ?? this.heroText,
      heroMutedText: heroMutedText ?? this.heroMutedText,
      heroShadowColor: heroShadowColor ?? this.heroShadowColor,
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
        heroGradientStart: Color(0xFF163832),
        heroGradientMiddle: Color(0xFF2B5D4F),
        heroGradientEnd: Color(0xFF8C6A2A),
        heroChipBackground: Color(0x29FFFFFF),
        heroText: Colors.white,
        heroMutedText: Color(0xFFF7F3E8),
        heroShadowColor: Color(0x22000000),
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
        heroGradientStart: Color(0xFF081411),
        heroGradientMiddle: Color(0xFF18352C),
        heroGradientEnd: Color(0xFF5B4824),
        heroChipBackground: Color(0x24FFF8EE),
        heroText: Color(0xFFDAD1C3),
        heroMutedText: Color(0xFFC8BDAF),
        heroShadowColor: Color(0x44000000),
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
