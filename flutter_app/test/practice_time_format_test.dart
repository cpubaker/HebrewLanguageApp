import 'package:flutter_test/flutter_test.dart';
import 'package:hebrew_language_flutter/services/practice_time_format.dart';

void main() {
  test('formatPracticeTimestamp formats local timestamps for practice UI', () {
    expect(formatPracticeTimestamp('2026-03-25T11:15:00'), '25.03.2026 11:15');
  });

  test('formatPracticeTimestamp leaves invalid values unchanged', () {
    expect(formatPracticeTimestamp('not-a-date'), 'not-a-date');
  });
}
