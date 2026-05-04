import 'package:flutter_test/flutter_test.dart';
import 'package:hebrew_language_flutter/services/lesson_glossary_matcher.dart';

void main() {
  test('matches glossary phrases while ignoring niqqud and punctuation', () {
    const text = 'שלום, בֹּקֶר טוֹב!';

    final segments = matchLessonGlossaryText(text, const <String, String>{
      'בקר טוב': 'good morning',
    });

    expect(segments, isNotNull);
    expect(segments!.map((segment) => segment.text).join(), text);

    final matchedSegment = segments.singleWhere(
      (segment) => segment.match != null,
    );
    expect(matchedSegment.text, 'בֹּקֶר טוֹב!');
    expect(matchedSegment.match!.source, 'בקר טוב');
    expect(matchedSegment.match!.translation, 'good morning');
  });

  test('prefers the longest glossary phrase at a matching start word', () {
    final segments = matchLessonGlossaryText(
      'בוקר טוב לכם',
      const <String, String>{'בוקר': 'morning', 'בוקר טוב': 'good morning'},
    );

    final matchedSegment = segments!.singleWhere(
      (segment) => segment.match != null,
    );
    expect(matchedSegment.text, 'בוקר טוב');
    expect(matchedSegment.match!.source, 'בוקר טוב');
    expect(matchedSegment.match!.translation, 'good morning');
  });

  test('returns null when text has no glossary matches', () {
    final segments = matchLessonGlossaryText('שלום', const <String, String>{
      'בוקר': 'morning',
    });

    expect(segments, isNull);
  });
}
