class LessonDocument {
  const LessonDocument({
    required this.title,
    required this.body,
    this.glossary = const <String, String>{},
  });

  final String title;
  final String body;
  final Map<String, String> glossary;
}
