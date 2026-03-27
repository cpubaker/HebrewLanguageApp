import 'package:flutter/material.dart';

ThemeData buildAppTheme() {
  const seed = Color(0xFF2B5D4F);
  final colorScheme = ColorScheme.fromSeed(
    seedColor: seed,
    brightness: Brightness.light,
  );

  return ThemeData(
    colorScheme: colorScheme,
    scaffoldBackgroundColor: const Color(0xFFF2EBDD),
    useMaterial3: true,
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
  );
}
