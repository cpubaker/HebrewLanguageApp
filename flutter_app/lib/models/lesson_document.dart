class LessonDocument {
  const LessonDocument({
    required this.title,
    required this.body,
    this.glossary = const <String, String>{},
    this.summary = '',
    this.headings = const <String>[],
    this.relatedTopics = const <String>[],
  });

  final String title;
  final String body;
  final Map<String, String> glossary;
  final String summary;
  final List<String> headings;
  final List<String> relatedTopics;
}
