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
      final lessonCatalog = await _readJsonObject(
        File('assets/learning/input/lesson_catalog.json'),
      );

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

  test('lesson catalog output uses a normalized schema', () async {
    final lessonCatalog = await _readJsonObject(
      File('assets/learning/input/lesson_catalog.json'),
    );

    expect(
      lessonCatalog.keys,
      unorderedEquals(<String>['guide', 'verbs', 'reading']),
    );

    for (final sectionName in lessonCatalog.keys) {
      final entries = _catalogEntries(lessonCatalog, sectionName);

      expect(entries, isNotEmpty, reason: '$sectionName catalog is empty.');
      expect(
        entries.toSet().length,
        entries.length,
        reason: '$sectionName catalog contains duplicate paths.',
      );

      for (final entry in entries) {
        expect(
          entry,
          endsWith('.md'),
          reason: '$sectionName catalog contains a non-markdown entry.',
        );
        expect(
          entry,
          isNot(contains(r'\')),
          reason: '$sectionName catalog must use forward slashes.',
        );
        expect(
          entry,
          isNot(startsWith('/')),
          reason: '$sectionName catalog paths must be relative.',
        );
        expect(
          entry,
          isNot(contains('..')),
          reason:
              '$sectionName catalog paths must stay within the source root.',
        );
        expect(
          _basename(entry).toLowerCase(),
          isNot('agents.md'),
          reason: '$sectionName catalog must not expose repo instructions.',
        );
      }
    }
  });

  test(
    'guide metadata references existing lessons and valid lesson IDs',
    () async {
      final metadata = await _readJsonObject(
        File('../data/input/guide_metadata.json'),
      );
      final sections = _stringMap(metadata['sections']);
      final lessons = _objectMap(metadata['lessons']);
      final guideLessonFilenames = _collectRelativeLessonPaths(
        Directory('../data/input/guide'),
      );

      expect(sections, isNotEmpty);
      for (final section in sections.entries) {
        expect(
          section.key,
          matches(RegExp(r'^[a-z0-9_]+$')),
          reason: 'Guide section ids should stay stable.',
        );
        expect(
          section.value,
          section.value.trim(),
          reason: '${section.key} section label should be trimmed.',
        );
        expect(
          section.value,
          isNotEmpty,
          reason: '${section.key} section label should not be empty.',
        );
      }
      expect(
        lessons.keys,
        unorderedEquals(guideLessonFilenames),
        reason: 'Every guide lesson needs exactly one metadata entry.',
      );

      final lessonIdsByFilename = <String, String>{};
      final sortOrders = <int>{};
      final duplicateLessonIds = <String>{};
      final duplicateSortOrders = <int>{};

      for (final entry in lessons.entries) {
        final filename = entry.key;
        final value = entry.value;
        final lessonId = _requiredTrimmedString(value, 'id', owner: filename);
        final sectionId = _requiredTrimmedString(
          value,
          'section',
          owner: filename,
        );
        final sortOrder = value['order'];

        expect(
          lessonId,
          matches(RegExp(r'^[a-z0-9_]+$')),
          reason: '$filename has an unstable lesson id.',
        );
        if (lessonIdsByFilename.containsValue(lessonId)) {
          duplicateLessonIds.add(lessonId);
        }
        lessonIdsByFilename[filename] = lessonId;

        expect(
          sections.keys,
          contains(sectionId),
          reason: '$filename references an unknown guide section.',
        );
        expect(
          sortOrder,
          isA<int>(),
          reason: '$filename order must be an int.',
        );
        expect(
          sortOrder as int,
          greaterThan(0),
          reason: '$filename order must be positive.',
        );
        if (!sortOrders.add(sortOrder)) {
          duplicateSortOrders.add(sortOrder);
        }

        _expectStringListContract(
          value['aliases'],
          owner: filename,
          field: 'aliases',
        );
        _expectStringListContract(
          value['related_ids'],
          owner: filename,
          field: 'related_ids',
        );
      }

      expect(
        duplicateLessonIds,
        isEmpty,
        reason: 'Guide lesson ids must be unique.',
      );
      expect(
        duplicateSortOrders,
        isEmpty,
        reason: 'Guide lesson sort orders must be unique.',
      );

      final knownLessonIds = lessonIdsByFilename.values.toSet();
      for (final entry in lessons.entries) {
        final filename = entry.key;
        final lessonId = lessonIdsByFilename[filename]!;
        final relatedIds = _stringList(entry.value['related_ids']);
        final missingRelatedIds = relatedIds
            .where((relatedId) => !knownLessonIds.contains(relatedId))
            .toList();

        expect(
          relatedIds,
          isNot(contains(lessonId)),
          reason: '$filename should not list itself as a related lesson.',
        );
        expect(
          missingRelatedIds,
          isEmpty,
          reason: '$filename references unknown related guide lesson ids.',
        );
      }
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

  test('reading lesson directories use known level keys', () {
    const expectedLevelDirectories = <String>[
      'advanced',
      'beginner',
      'intermediate',
      'pre-intermediate',
      'proficient',
      'upper-intermediate',
    ];

    expect(
      _collectDirectoryNames(Directory('../data/input/reading')),
      expectedLevelDirectories,
      reason:
          'Reading source levels must match the UI grouping contract. Update '
          'reading_lesson_catalog.dart and pubspec.yaml before adding a new '
          'level.',
    );
    expect(
      _collectDirectoryNames(Directory('assets/learning/input/reading')),
      expectedLevelDirectories,
      reason: 'Synced reading assets should expose the same known levels.',
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

  test(
    'synced runtime assets do not include repo instruction or audit files',
    () {
      final runtimeNoise =
          Directory('assets/learning/input')
              .listSync(recursive: true)
              .whereType<File>()
              .map((file) => file.path.replaceAll('\\', '/'))
              .where((path) {
                final basename = _basename(path).toLowerCase();
                return basename == 'agents.md' ||
                    basename == 'rewrite_candidates.md';
              })
              .toList()
            ..sort();

      expect(runtimeNoise, isEmpty);
    },
  );

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

Future<Map<String, dynamic>> _readJsonObject(File file) async {
  expect(await file.exists(), isTrue, reason: '${file.path} is missing.');
  final decoded = jsonDecode(await file.readAsString());
  expect(decoded, isA<Map<String, dynamic>>());
  return decoded as Map<String, dynamic>;
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

List<String> _catalogEntries(
  Map<String, dynamic> lessonCatalog,
  String sectionName,
) {
  final entries = lessonCatalog[sectionName];
  expect(
    entries,
    isA<List<dynamic>>(),
    reason: '$sectionName catalog entries must be a list.',
  );
  expect(
    entries as List<dynamic>,
    everyElement(isA<String>()),
    reason: '$sectionName catalog entries must all be strings.',
  );
  return entries.cast<String>().toList(growable: false);
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

Map<String, String> _stringMap(Object? value) {
  expect(value, isA<Map<String, dynamic>>());
  return (value as Map<String, dynamic>).map((key, value) {
    expect(value, isA<String>(), reason: '$key must be a string.');
    return MapEntry(key, value as String);
  });
}

Map<String, Map<String, dynamic>> _objectMap(Object? value) {
  expect(value, isA<Map<String, dynamic>>());
  return (value as Map<String, dynamic>).map((key, value) {
    expect(
      value,
      isA<Map<String, dynamic>>(),
      reason: '$key must be an object.',
    );
    return MapEntry(key, value as Map<String, dynamic>);
  });
}

String _requiredTrimmedString(
  Map<String, dynamic> value,
  String field, {
  required String owner,
}) {
  final rawValue = value[field];
  expect(rawValue, isA<String>(), reason: '$owner.$field must be a string.');
  final resolvedValue = (rawValue as String).trim();
  expect(resolvedValue, isNotEmpty, reason: '$owner.$field must not be empty.');
  return resolvedValue;
}

void _expectStringListContract(
  Object? value, {
  required String owner,
  required String field,
}) {
  final values = _stringList(value);

  expect(
    values,
    hasLength(values.toSet().length),
    reason: '$owner.$field contains duplicate values.',
  );
  for (final item in values) {
    expect(
      item.trim(),
      isNotEmpty,
      reason: '$owner.$field has an empty value.',
    );
    expect(item, item.trim(), reason: '$owner.$field values must be trimmed.');
  }
}

List<String> _stringList(Object? value) {
  if (value == null) {
    return const <String>[];
  }

  expect(value, isA<List<dynamic>>());
  expect(value as List<dynamic>, everyElement(isA<String>()));
  return value.cast<String>().toList(growable: false);
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

List<String> _collectDirectoryNames(Directory directory) {
  return directory
      .listSync()
      .whereType<Directory>()
      .map((directory) => _basename(directory.path))
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
