import 'package:flutter_test/flutter_test.dart';
import 'package:hebrew_language_flutter/models/learning_bundle.dart';
import 'package:hebrew_language_flutter/models/lesson_document.dart';
import 'package:hebrew_language_flutter/services/guide_detail_links.dart';
import 'package:hebrew_language_flutter/services/lesson_document_loader.dart';

void main() {
  const intro = LessonEntry(
    assetPath: 'guide/01_intro.md',
    displayName: '01 Intro Alphabet',
    lessonId: 'intro',
  );
  const reading = LessonEntry(
    assetPath: 'guide/02_reading.md',
    displayName: '02 Reading Rules',
    lessonId: 'reading',
  );
  const smixut = LessonEntry(
    assetPath: 'guide/03_smixut.md',
    displayName: '03 Smixut',
    lessonId: 'smixut',
    aliases: ['Construct state'],
  );
  const verbs = LessonEntry(
    assetPath: 'guide/04_verbs.md',
    displayName: '04 Verb Patterns',
    lessonId: 'verbs',
  );

  test('resolves adjacent titles and skips failed optional titles', () async {
    final resolver = GuideDetailLinkResolver(
      lesson: reading,
      allLessons: const [intro, reading, smixut],
      documentLoader: _MapLessonDocumentLoader(
        documents: const {
          'guide/01_intro.md': LessonDocument(
            title: 'Alphabet Basics',
            body: 'Body',
          ),
        },
        failingAssetPaths: const {'guide/03_smixut.md'},
      ),
    );

    final titlesByAssetPath = await resolver.resolveAdjacentLessonTitles();

    expect(titlesByAssetPath, const {'guide/01_intro.md': 'Alphabet Basics'});
  });

  test('resolves related IDs and markdown topics with dedupe', () async {
    final resolver = GuideDetailLinkResolver(
      lesson: const LessonEntry(
        assetPath: 'guide/01_intro.md',
        displayName: '01 Intro Alphabet',
        lessonId: 'intro',
        relatedIds: ['smixut'],
      ),
      allLessons: const [intro, reading, smixut, verbs],
      documentLoader: _MapLessonDocumentLoader(
        documents: const {
          'guide/01_intro.md': LessonDocument(
            title: 'Intro Alphabet',
            body: 'Body',
            relatedTopics: [
              'Construct State',
              'Verb Patterns',
              'Missing Topic',
            ],
          ),
          'guide/02_reading.md': LessonDocument(
            title: 'Reading Rules',
            body: 'Body',
          ),
          'guide/03_smixut.md': LessonDocument(title: 'Smixut', body: 'Body'),
          'guide/04_verbs.md': LessonDocument(
            title: 'Verb Patterns',
            body: 'Body',
          ),
        },
      ),
    );

    final resolution = await resolver.resolveRelatedTopics();

    expect(resolution.resolvedTopics.map((topic) => topic.label), [
      'Smixut',
      'Verb Patterns',
    ]);
  });

  test('excludes current and adjacent lessons from related topics', () async {
    final resolver = GuideDetailLinkResolver(
      lesson: const LessonEntry(
        assetPath: 'guide/02_reading.md',
        displayName: '02 Reading Rules',
        lessonId: 'reading',
        relatedIds: ['intro', 'smixut', 'verbs'],
      ),
      allLessons: const [intro, reading, smixut, verbs],
      documentLoader: _MapLessonDocumentLoader(
        documents: const {
          'guide/01_intro.md': LessonDocument(
            title: 'Intro Alphabet',
            body: 'Body',
          ),
          'guide/02_reading.md': LessonDocument(
            title: 'Reading Rules',
            body: 'Body',
            relatedTopics: ['Reading Rules', 'Smixut', 'Verb Patterns'],
          ),
          'guide/03_smixut.md': LessonDocument(title: 'Smixut', body: 'Body'),
          'guide/04_verbs.md': LessonDocument(
            title: 'Verb Patterns',
            body: 'Body',
          ),
        },
      ),
    );

    final resolution = await resolver.resolveRelatedTopics();

    expect(resolution.resolvedTopics.map((topic) => topic.lesson.assetPath), [
      'guide/04_verbs.md',
    ]);
  });

  test('uses fallback labels when related lesson documents fail', () async {
    final resolver = GuideDetailLinkResolver(
      lesson: const LessonEntry(
        assetPath: 'guide/01_intro.md',
        displayName: '01 Intro Alphabet',
        lessonId: 'intro',
        relatedIds: ['verbs'],
      ),
      allLessons: const [intro, reading, smixut, verbs],
      documentLoader: _MapLessonDocumentLoader(
        documents: const {
          'guide/01_intro.md': LessonDocument(
            title: 'Intro Alphabet',
            body: 'Body',
          ),
          'guide/02_reading.md': LessonDocument(
            title: 'Reading Rules',
            body: 'Body',
          ),
          'guide/03_smixut.md': LessonDocument(title: 'Smixut', body: 'Body'),
        },
        failingAssetPaths: const {'guide/04_verbs.md'},
      ),
    );

    final resolution = await resolver.resolveRelatedTopics();

    expect(resolution.resolvedTopics.single.label, 'Verb Patterns');
  });

  test('normalizes niqqud and punctuation for topic matching', () {
    expect(
      normalizeForGuideTopicMatching('שָׁלוֹם / Construct-State!'),
      'שלום construct state',
    );
  });
}

class _MapLessonDocumentLoader implements LessonDocumentLoader {
  const _MapLessonDocumentLoader({
    required this.documents,
    this.failingAssetPaths = const <String>{},
  });

  final Map<String, LessonDocument> documents;
  final Set<String> failingAssetPaths;

  @override
  Future<LessonDocument> load(String assetPath) async {
    if (failingAssetPaths.contains(assetPath)) {
      throw StateError('Failed to load $assetPath');
    }

    final document = documents[assetPath];
    if (document == null) {
      throw StateError('Missing $assetPath');
    }

    return document;
  }
}
