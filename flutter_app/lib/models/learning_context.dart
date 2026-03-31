class LearningContext {
  const LearningContext({
    required this.contextId,
    required this.hebrew,
    required this.translation,
  });

  factory LearningContext.fromJson(Map<String, dynamic> json) {
    return LearningContext(
      contextId: json['id'] as String? ?? '',
      hebrew: json['hebrew'] as String? ?? '',
      translation: json['translation'] as String? ?? '',
    );
  }

  final String contextId;
  final String hebrew;
  final String translation;
}
