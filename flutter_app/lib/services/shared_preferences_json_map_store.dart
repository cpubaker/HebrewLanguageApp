import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SharedPreferencesJsonMapStore<T> {
  const SharedPreferencesJsonMapStore({
    required this.preferencesKey,
    required this.fromJson,
    required this.toJson,
    required this.isUsable,
    required this.debugLabel,
  });

  final String preferencesKey;
  final T Function(Map<String, dynamic> json) fromJson;
  final Map<String, dynamic> Function(T value) toJson;
  final bool Function(T value) isUsable;
  final String debugLabel;

  Future<Map<String, List<T>>> load() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(preferencesKey);
    if (raw == null || raw.trim().isEmpty) {
      return <String, List<T>>{};
    }

    try {
      final decoded = jsonDecode(raw) as Map<String, dynamic>;
      return decoded.map(
        (groupKey, value) => MapEntry(
          groupKey,
          (value as List<dynamic>? ?? const <dynamic>[])
              .whereType<Map<String, dynamic>>()
              .map(fromJson)
              .where(isUsable)
              .toList(growable: false),
        ),
      );
    } on Object catch (error) {
      debugPrint('Failed to load $debugLabel: $error');
      return <String, List<T>>{};
    }
  }

  Future<void> save(Map<String, List<T>> valuesByKey) async {
    final prefs = await SharedPreferences.getInstance();
    final encoded = jsonEncode(
      valuesByKey.map(
        (groupKey, values) => MapEntry(
          groupKey,
          values
              .where(isUsable)
              .map(toJson)
              .toList(growable: false),
        ),
      ),
    );
    await prefs.setString(preferencesKey, encoded);
  }
}
