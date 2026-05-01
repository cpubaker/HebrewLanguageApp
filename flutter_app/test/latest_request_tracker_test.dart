import 'package:flutter_test/flutter_test.dart';
import 'package:hebrew_language_flutter/services/latest_request_tracker.dart';

void main() {
  test('tracks the latest request per key independently', () {
    final tracker = LatestRequestTracker();

    final firstWordToken = tracker.start('word_peace');
    final secondWordToken = tracker.start('word_peace');
    final guideToken = tracker.start('guide_intro');

    expect(tracker.isLatest('word_peace', firstWordToken), isFalse);
    expect(tracker.isLatest('word_peace', secondWordToken), isTrue);
    expect(tracker.isLatest('guide_intro', guideToken), isTrue);
  });

  test('unknown keys are never latest', () {
    final tracker = LatestRequestTracker();

    expect(tracker.isLatest('missing', 1), isFalse);
  });
}
