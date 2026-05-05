import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hebrew_language_flutter/theme/app_theme.dart';

void main() {
  test('light theme exposes semantic accent tokens', () {
    final tokens = buildLightAppTheme().appTokens;

    expect(tokens.successAccent, const Color(0xFF0F766E));
    expect(tokens.dangerAccent, const Color(0xFFB91C1C));
    expect(tokens.warningAccent, const Color(0xFFB45309));
    expect(tokens.vocabularyAccent, const Color(0xFF8C6A2A));
    expect(tokens.readingAccent, const Color(0xFF1D4ED8));
    expect(tokens.infoAccent, const Color(0xFF1D4ED8));
    expect(tokens.aiAccent, const Color(0xFF8C3E9F));
  });

  test('dark theme uses night-mode accent variants', () {
    final tokens = buildDarkAppTheme().appTokens;

    expect(tokens.successAccent, const Color(0xFF38B2A5));
    expect(tokens.dangerAccent, const Color(0xFFE06B65));
    expect(tokens.warningAccent, const Color(0xFFD6A451));
    expect(tokens.vocabularyAccent, const Color(0xFFC5965A));
    expect(tokens.readingAccent, const Color(0xFF7EA4F4));
    expect(tokens.infoAccent, const Color(0xFF7EA4F4));
    expect(tokens.aiAccent, const Color(0xFFD08AE3));
  });
}
