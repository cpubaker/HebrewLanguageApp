import 'package:flutter_test/flutter_test.dart';
import 'package:hebrew_language_flutter/models/guide_lesson_status.dart';
import 'package:hebrew_language_flutter/services/lesson_status_updates.dart';

void main() {
  test('adds a lesson status without mutating the original map', () {
    final original = <String, GuideLessonStatus>{
      'intro': GuideLessonStatus.read,
    };

    final updated = applyLessonStatus(
      original,
      lessonKey: 'alphabet',
      status: GuideLessonStatus.studying,
    );

    expect(updated, <String, GuideLessonStatus>{
      'intro': GuideLessonStatus.read,
      'alphabet': GuideLessonStatus.studying,
    });
    expect(original, <String, GuideLessonStatus>{
      'intro': GuideLessonStatus.read,
    });
  });

  test('replaces an existing lesson status', () {
    final updated = applyLessonStatus(
      const <String, GuideLessonStatus>{'intro': GuideLessonStatus.studying},
      lessonKey: 'intro',
      status: GuideLessonStatus.read,
    );

    expect(updated, const <String, GuideLessonStatus>{
      'intro': GuideLessonStatus.read,
    });
  });

  test('removes a lesson status when applying unread', () {
    final updated = applyLessonStatus(
      const <String, GuideLessonStatus>{
        'intro': GuideLessonStatus.read,
        'alphabet': GuideLessonStatus.studying,
      },
      lessonKey: 'intro',
      status: GuideLessonStatus.unread,
    );

    expect(updated, const <String, GuideLessonStatus>{
      'alphabet': GuideLessonStatus.studying,
    });
  });

  test('returns a new map when removing a missing key', () {
    const original = <String, GuideLessonStatus>{
      'intro': GuideLessonStatus.read,
    };

    final updated = applyLessonStatus(
      original,
      lessonKey: 'missing',
      status: GuideLessonStatus.unread,
    );

    expect(updated, original);
    expect(identical(updated, original), isFalse);
  });
}
