enum LearningContextSource { curated, aiGenerated }

class LearningContext {
  const LearningContext({
    required this.contextId,
    required this.hebrew,
    required this.translation,
    this.source = LearningContextSource.curated,
    this.isNew = false,
    this.createdAt,
    this.model,
    this.promptVersion,
  });

  factory LearningContext.fromJson(Map<String, dynamic> json) {
    return LearningContext(
      contextId: json['id'] as String? ?? '',
      hebrew: json['hebrew'] as String? ?? '',
      translation: json['translation'] as String? ?? '',
      source: _parseSource(json['source']),
      isNew: json['is_new'] as bool? ?? json['isNew'] as bool? ?? false,
      createdAt: json['created_at'] as String? ?? json['createdAt'] as String?,
      model: json['model'] as String?,
      promptVersion:
          json['prompt_version'] as String? ?? json['promptVersion'] as String?,
    );
  }

  final String contextId;
  final String hebrew;
  final String translation;
  final LearningContextSource source;
  final bool isNew;
  final String? createdAt;
  final String? model;
  final String? promptVersion;

  bool get isAiGenerated => source == LearningContextSource.aiGenerated;

  LearningContext copyWith({
    String? contextId,
    String? hebrew,
    String? translation,
    LearningContextSource? source,
    bool? isNew,
    String? createdAt,
    String? model,
    String? promptVersion,
  }) {
    return LearningContext(
      contextId: contextId ?? this.contextId,
      hebrew: hebrew ?? this.hebrew,
      translation: translation ?? this.translation,
      source: source ?? this.source,
      isNew: isNew ?? this.isNew,
      createdAt: createdAt ?? this.createdAt,
      model: model ?? this.model,
      promptVersion: promptVersion ?? this.promptVersion,
    );
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'id': contextId,
      'hebrew': hebrew,
      'translation': translation,
      'source': switch (source) {
        LearningContextSource.curated => 'curated',
        LearningContextSource.aiGenerated => 'ai',
      },
      'is_new': isNew,
      if (createdAt != null) 'created_at': createdAt,
      if (model != null) 'model': model,
      if (promptVersion != null) 'prompt_version': promptVersion,
    };
  }

  static LearningContextSource _parseSource(Object? value) {
    if (value is! String) {
      return LearningContextSource.curated;
    }

    return switch (value.trim().toLowerCase()) {
      'ai' ||
      'ai_generated' ||
      'aigenerated' => LearningContextSource.aiGenerated,
      _ => LearningContextSource.curated,
    };
  }
}
