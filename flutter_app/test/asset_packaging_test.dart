import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('pubspec declares nested reading asset directories', () async {
    final pubspec = await File('pubspec.yaml').readAsString();

    expect(
      pubspec,
      contains('- assets/learning/input/reading/advanced/'),
    );
    expect(
      pubspec,
      contains('- assets/learning/input/reading/beginner/'),
    );
    expect(
      pubspec,
      contains('- assets/learning/input/reading/intermediate/'),
    );
    expect(
      pubspec,
      contains('- assets/learning/input/reading/pre-intermediate/'),
    );
    expect(
      pubspec,
      contains('- assets/learning/input/reading/proficient/'),
    );
    expect(
      pubspec,
      contains('- assets/learning/input/reading/upper-intermediate/'),
    );
  });
}
