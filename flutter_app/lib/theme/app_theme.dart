import 'dart:ui' show lerpDouble;

import 'package:flutter/material.dart';

@immutable
class AppThemeTokens extends ThemeExtension<AppThemeTokens> {
  const AppThemeTokens({
    required this.pagePadding,
    required this.sectionRadius,
    required this.panelRadius,
    required this.elevatedSurface,
    required this.subtleSurface,
    required this.mutedText,
    required this.secondaryText,
    required this.outlineSoft,
    required this.shadowColor,
  });

  const AppThemeTokens.fallback()
    : pagePadding = const EdgeInsets.fromLTRB(20, 20, 20, 0),
      sectionRadius = 24,
      panelRadius = 18,
      elevatedSurface = Colors.white,
      subtleSurface = const Color(0xFFF7F3E8),
      mutedText = const Color(0xFF5F5A52),
      secondaryText = const Color(0xFF6C665D),
      outlineSoft = const Color(0x1F8C6A2A),
      shadowColor = const Color(0x14000000);

  final EdgeInsets pagePadding;
  final double sectionRadius;
  final double panelRadius;
  final Color elevatedSurface;
  final Color subtleSurface;
  final Color mutedText;
  final Color secondaryText;
  final Color outlineSoft;
  final Color shadowColor;

  @override
  AppThemeTokens copyWith({
    EdgeInsets? pagePadding,
    double? sectionRadius,
    double? panelRadius,
    Color? elevatedSurface,
    Color? subtleSurface,
    Color? mutedText,
    Color? secondaryText,
    Color? outlineSoft,
    Color? shadowColor,
  }) {
    return AppThemeTokens(
      pagePadding: pagePadding ?? this.pagePadding,
      sectionRadius: sectionRadius ?? this.sectionRadius,
      panelRadius: panelRadius ?? this.panelRadius,
      elevatedSurface: elevatedSurface ?? this.elevatedSurface,
      subtleSurface: subtleSurface ?? this.subtleSurface,
      mutedText: mutedText ?? this.mutedText,
      secondaryText: secondaryText ?? this.secondaryText,
      outlineSoft: outlineSoft ?? this.outlineSoft,
      shadowColor: shadowColor ?? this.shadowColor,
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
      elevatedSurface: Color.lerp(elevatedSurface, other.elevatedSurface, t)!,
      subtleSurface: Color.lerp(subtleSurface, other.subtleSurface, t)!,
      mutedText: Color.lerp(mutedText, other.mutedText, t)!,
      secondaryText: Color.lerp(secondaryText, other.secondaryText, t)!,
      outlineSoft: Color.lerp(outlineSoft, other.outlineSoft, t)!,
      shadowColor: Color.lerp(shadowColor, other.shadowColor, t)!,
    );
  }
}

extension AppThemeLookup on ThemeData {
  AppThemeTokens get appTokens =>
      extension<AppThemeTokens>() ?? const AppThemeTokens.fallback();
}

ThemeData buildAppTheme() {
  const seed = Color(0xFF2B5D4F);
  const tokens = AppThemeTokens(
    pagePadding: EdgeInsets.fromLTRB(20, 20, 20, 0),
    sectionRadius: 24,
    panelRadius: 18,
    elevatedSurface: Colors.white,
    subtleSurface: Color(0xFFF7F3E8),
    mutedText: Color(0xFF5F5A52),
    secondaryText: Color(0xFF6C665D),
    outlineSoft: Color(0x1F8C6A2A),
    shadowColor: Color(0x14000000),
  );
  final colorScheme = ColorScheme.fromSeed(
    seedColor: seed,
    brightness: Brightness.light,
  );

  return ThemeData(
    colorScheme: colorScheme,
    scaffoldBackgroundColor: const Color(0xFFF2EBDD),
    useMaterial3: true,
    extensions: const [tokens],
    textTheme: Typography.blackMountainView.copyWith(
      headlineMedium: Typography.blackMountainView.headlineMedium?.copyWith(
        fontWeight: FontWeight.w800,
      ),
      titleLarge: Typography.blackMountainView.titleLarge?.copyWith(
        fontWeight: FontWeight.w700,
      ),
      bodyLarge: Typography.blackMountainView.bodyLarge?.copyWith(
        color: const Color(0xFF2D2A24),
      ),
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.transparent,
      surfaceTintColor: Colors.transparent,
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(999),
        ),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
        side: const BorderSide(color: Color(0xFF9F9484)),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(999),
        ),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(20),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(20),
        borderSide: const BorderSide(color: Color(0x1F8C6A2A)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(20),
        borderSide: const BorderSide(color: Color(0xFF8C6A2A), width: 1.5),
      ),
    ),
  );
}
