import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('pubspec declares only approved learning asset roots', () async {
    final pubspec = await File('pubspec.yaml').readAsString();
    final declaredAssets = _pubspecLearningAssets(pubspec);

    expect(declaredAssets, <String>[
      'assets/learning/input/hebrew_words.json',
      'assets/learning/input/guide_metadata.json',
      'assets/learning/input/lesson_catalog.json',
      'assets/learning/input/contexts/',
      'assets/learning/input/guide/',
      'assets/learning/input/verbs/',
      'assets/learning/input/reading/',
      'assets/learning/input/reading/advanced/',
      'assets/learning/input/reading/beginner/',
      'assets/learning/input/reading/intermediate/',
      'assets/learning/input/reading/pre-intermediate/',
      'assets/learning/input/reading/proficient/',
      'assets/learning/input/reading/upper-intermediate/',
      'assets/learning/input/audio/verbs/',
      'assets/learning/input/audio/words/',
      'assets/learning/input/images/verbs/',
    ]);
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

  test('core synced JSON assets mirror source content', () async {
    await _expectFilesMatch(
      sourceFile: File('../data/input/hebrew_words.json'),
      assetFile: File('assets/learning/input/hebrew_words.json'),
    );
    await _expectFilesMatch(
      sourceFile: File('../data/input/guide_metadata.json'),
      assetFile: File('assets/learning/input/guide_metadata.json'),
    );
  });

  test('context assets mirror source content', () {
    expect(
      _collectRelativeFilePaths(Directory('assets/learning/input/contexts')),
      _collectRelativeFilePaths(Directory('../data/input/contexts')),
    );
  });

  test('synced runtime assets do not include hidden placeholder files', () {
    final hiddenFiles =
        Directory('assets/learning/input')
            .listSync(recursive: true)
            .whereType<File>()
            .map((file) => file.path.replaceAll('\\', '/'))
            .where((path) => _basename(path).startsWith('.'))
            .toList()
          ..sort();

    expect(hiddenFiles, isEmpty);
  });

  test('packaged word audio is referenced by the vocabulary source', () async {
    final wordsJson =
        jsonDecode(
              await File(
                'assets/learning/input/hebrew_words.json',
              ).readAsString(),
            )
            as List<dynamic>;
    final referencedAudio = wordsJson
        .whereType<Map<String, dynamic>>()
        .map((word) => word['audio_file'])
        .whereType<String>()
        .map(_normalizeAssetPath)
        .where((path) => path.startsWith('words/') && path.endsWith('.mp3'))
        .toSet();

    final packagedAudio = _collectMediaFilenames(
      Directory('assets/learning/input/audio/words'),
      extension: '.mp3',
    ).map((filename) => 'words/$filename').toList();

    expect(
      packagedAudio.where((path) => !referencedAudio.contains(path)).toList(),
      isEmpty,
      reason:
          'Every packaged word audio file should be referenced by hebrew_words.json.',
    );
  });

  test('packaged verb media is referenced by verb lessons', () {
    final expectedVerbMediaStems = _collectRelativeLessonPaths(
      Directory('assets/learning/input/verbs'),
    ).map(_mediaStemForLessonPath).toSet();

    final packagedVerbAudio = _collectMediaFilenames(
      Directory('assets/learning/input/audio/verbs'),
      extension: '.mp3',
    );
    final packagedVerbImages = _collectMediaFilenames(
      Directory('assets/learning/input/images/verbs'),
      extension: '.png',
    );

    expect(
      packagedVerbAudio
          .where(
            (filename) =>
                !expectedVerbMediaStems.contains(_stripExtension(filename)),
          )
          .toList(),
      isEmpty,
      reason:
          'Every packaged verb audio file should map to a verb lesson filename.',
    );
    expect(
      packagedVerbImages
          .where(
            (filename) =>
                !expectedVerbMediaStems.contains(_stripExtension(filename)),
          )
          .toList(),
      isEmpty,
      reason:
          'Every packaged verb image file should map to a verb lesson filename.',
    );
  });
}

List<String> _pubspecLearningAssets(String pubspec) {
  return pubspec
      .split('\n')
      .map((line) => RegExp(r'^\s{4}-\s+(.+?)\s*$').firstMatch(line))
      .whereType<RegExpMatch>()
      .map((match) => match.group(1)!)
      .where((path) => path.startsWith('assets/learning/'))
      .toList(growable: false);
}

Future<void> _expectFilesMatch({
  required File sourceFile,
  required File assetFile,
}) async {
  expect(await sourceFile.exists(), isTrue);
  expect(await assetFile.exists(), isTrue);
  expect(await assetFile.readAsString(), await sourceFile.readAsString());
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

List<String> _collectRelativeFilePaths(Directory directory) {
  return directory
      .listSync(recursive: true)
      .whereType<File>()
      .where((file) => !_isIgnoredSourceFile(file.path))
      .map(
        (file) => file.path
            .substring(directory.path.length + 1)
            .replaceAll('\\', '/'),
      )
      .toList()
    ..sort();
}

List<String> _collectMediaFilenames(
  Directory directory, {
  required String extension,
}) {
  return directory
      .listSync()
      .whereType<File>()
      .where((file) => file.path.toLowerCase().endsWith(extension))
      .map((file) => _basename(file.path))
      .toList()
    ..sort();
}

String _mediaStemForLessonPath(String path) {
  final filename = _basename(path);
  final withoutExtension = filename.replaceFirst(RegExp(r'\.md$'), '');
  return withoutExtension.replaceFirst(RegExp(r'^\d+[_-]*'), '');
}

String _stripExtension(String filename) {
  final separatorIndex = filename.lastIndexOf('.');
  return separatorIndex <= 0 ? filename : filename.substring(0, separatorIndex);
}

String _normalizeAssetPath(String path) {
  return path.trim().replaceAll('\\', '/').replaceFirst(RegExp(r'^/+'), '');
}

String _basename(String path) {
  final normalizedPath = path.replaceAll('\\', '/');
  return normalizedPath.split('/').last;
}

bool _isIgnoredSourceFile(String path) {
  final basename = _basename(path).toLowerCase();
  return basename == 'agents.md' || basename == '.gitkeep';
}
