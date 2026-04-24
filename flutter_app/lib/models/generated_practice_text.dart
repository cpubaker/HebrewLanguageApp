enum GeneratedPracticeTextSource { aiGenerated }

class GeneratedPracticeText {
  const GeneratedPracticeText({
    required this.textId,
    required this.title,
    required this.hebrew,
    required this.translation,
    this.wordIds = const <String>[],
    this.source = GeneratedPracticeTextSource.aiGenerated,
    this.isNew = true,
    this.createdAt,
    this.model,
    this.promptVersion,
  });

  factory GeneratedPracticeText.fromJson(Map<String, dynamic> json) {
    return GeneratedPracticeText(
      textId: json['id'] as String? ?? json['text_id'] as String? ?? '',
      title: json['title'] as String? ?? '',
      hebrew: json['hebrew'] as String? ?? '',
      translation:
          json['ukrainian'] as String? ?? json['translation'] as String? ?? '',
      wordIds: (json['word_ids'] as List<dynamic>? ?? const <dynamic>[])
          .whereType<String>()
          .toList(growable: false),
      isNew: json['is_new'] as bool? ?? json['isNew'] as bool? ?? true,
      createdAt: json['created_at'] as String? ?? json['createdAt'] as String?,
      model: json['model'] as String?,
      promptVersion:
          json['prompt_version'] as String? ?? json['promptVersion'] as String?,
    );
  }

  final String textId;
  final String title;
  final String hebrew;
  final String translation;
  final List<String> wordIds;
  final GeneratedPracticeTextSource source;
  final bool isNew;
  final String? createdAt;
  final String? model;
  final String? promptVersion;

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'id': textId,
      'title': title,
      'hebrew': hebrew,
      'translation': translation,
      'word_ids': wordIds,
      'source': 'ai',
      'is_new': isNew,
      if (createdAt != null) 'created_at': createdAt,
      if (model != null) 'model': model,
      if (promptVersion != null) 'prompt_version': promptVersion,
    };
  }
}
