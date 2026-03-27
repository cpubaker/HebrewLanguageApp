class LearningWord {
  const LearningWord({
    required this.wordId,
    required this.hebrew,
    required this.english,
    required this.transcription,
    required this.correct,
    required this.wrong,
  });

  factory LearningWord.fromJson(Map<String, dynamic> json) {
    return LearningWord(
      wordId: json['word_id'] as String? ?? '',
      hebrew: json['hebrew'] as String? ?? '',
      english: json['english'] as String? ?? '',
      transcription: json['transcription'] as String? ?? '',
      correct: (json['correct'] as num?)?.toInt() ?? 0,
      wrong: (json['wrong'] as num?)?.toInt() ?? 0,
    );
  }

  final String wordId;
  final String hebrew;
  final String english;
  final String transcription;
  final int correct;
  final int wrong;
}
