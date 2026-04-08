import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('pubspec declares nested reading asset directories', () async {
    final pubspec = await File('pubspec.yaml').readAsString();

    expect(pubspec, contains('- assets/learning/input/reading/advanced/'));
    expect(pubspec, contains('- assets/learning/input/reading/beginner/'));
    expect(pubspec, contains('- assets/learning/input/reading/intermediate/'));
    expect(
      pubspec,
      contains('- assets/learning/input/reading/pre-intermediate/'),
    );
    expect(pubspec, contains('- assets/learning/input/reading/proficient/'));
    expect(
      pubspec,
      contains('- assets/learning/input/reading/upper-intermediate/'),
    );
    expect(pubspec, contains('- assets/learning/input/guide_metadata.json'));
    expect(pubspec, contains('- assets/learning/input/lesson_catalog.json'));
  });

  test(
    'lesson catalog mirrors synced lesson assets and source content',
    () async {
      final lessonCatalogFile = File(
        'assets/learning/input/lesson_catalog.json',
      );
      expect(await lessonCatalogFile.exists(), isTrue);

      final lessonCatalog =
          jsonDecode(await lessonCatalogFile.readAsString())
              as Map<String, dynamic>;

      _expectCatalogSectionMatches(
        lessonCatalog: lessonCatalog,
        sectionName: 'guide',
        sourceDirectory: Directory('../data/input/guide'),
        syncedDirectory: Directory('assets/learning/input/guide'),
      );
      _expectCatalogSectionMatches(
        lessonCatalog: lessonCatalog,
        sectionName: 'verbs',
        sourceDirectory: Directory('../data/input/verbs'),
        syncedDirectory: Directory('assets/learning/input/verbs'),
      );
      _expectCatalogSectionMatches(
        lessonCatalog: lessonCatalog,
        sectionName: 'reading',
        sourceDirectory: Directory('../data/input/reading'),
        syncedDirectory: Directory('assets/learning/input/reading'),
      );
    },
  );

  test('guide metadata asset mirrors source metadata', () async {
    final sourceFile = File('../data/input/guide_metadata.json');
    final assetFile = File('assets/learning/input/guide_metadata.json');

    expect(await sourceFile.exists(), isTrue);
    expect(await assetFile.exists(), isTrue);
    expect(await assetFile.readAsString(), await sourceFile.readAsString());
  });
}

void _expectCatalogSectionMatches({
  required Map<String, dynamic> lessonCatalog,
  required String sectionName,
  required Directory sourceDirectory,
  required Directory syncedDirectory,
}) {
  final sourceLessonPaths = _collectRelativeLessonPaths(sourceDirectory);
  final syncedLessonPaths = _collectRelativeLessonPaths(syncedDirectory);
  final catalogLessonPaths =
      ((lessonCatalog[sectionName] as List<dynamic>?) ?? const [])
          .whereType<String>()
          .toList()
        ..sort();

  expect(
    syncedLessonPaths,
    sourceLessonPaths,
    reason: 'Synced Flutter assets for $sectionName are out of date.',
  );
  expect(
    catalogLessonPaths,
    sourceLessonPaths,
    reason: 'Lesson catalog for $sectionName does not match source content.',
  );
}

List<String> _collectRelativeLessonPaths(Directory directory) {
  return directory
      .listSync(recursive: true)
      .whereType<File>()
      .where((file) => file.path.toLowerCase().endsWith('.md'))
      .where((file) => _basename(file.path).toLowerCase() != 'agents.md')
      .map(
        (file) => file.path
            .substring(directory.path.length + 1)
            .replaceAll('\\', '/'),
      )
      .toList()
    ..sort();
}

String _basename(String path) {
  final normalizedPath = path.replaceAll('\\', '/');
  return normalizedPath.split('/').last;
}
