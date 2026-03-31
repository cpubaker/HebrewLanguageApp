import 'learning_context.dart';

class LearningWord {
  const LearningWord({
    required this.wordId,
    required this.hebrew,
    required this.english,
    required this.transcription,
    required this.correct,
    required this.wrong,
    this.lastCorrect,
    this.contexts = const <LearningContext>[],
  });

  factory LearningWord.fromJson(Map<String, dynamic> json) {
    return LearningWord(
      wordId: json['word_id'] as String? ?? '',
      hebrew: json['hebrew'] as String? ?? '',
      english: json['english'] as String? ?? '',
      transcription: json['transcription'] as String? ?? '',
      correct: (json['correct'] as num?)?.toInt() ?? 0,
      wrong: (json['wrong'] as num?)?.toInt() ?? 0,
      lastCorrect: _parseLastCorrect(json['last_correct']),
      contexts: (json['_contexts'] as List<dynamic>? ?? const <dynamic>[])
          .whereType<Map<String, dynamic>>()
          .map(LearningContext.fromJson)
          .toList(growable: false),
    );
  }

  final String wordId;
  final String hebrew;
  final String english;
  final String transcription;
  final int correct;
  final int wrong;
  final String? lastCorrect;
  final List<LearningContext> contexts;

  LearningWord copyWith({
    String? wordId,
    String? hebrew,
    String? english,
    String? transcription,
    int? correct,
    int? wrong,
    String? lastCorrect,
    List<LearningContext>? contexts,
  }) {
    return LearningWord(
      wordId: wordId ?? this.wordId,
      hebrew: hebrew ?? this.hebrew,
      english: english ?? this.english,
      transcription: transcription ?? this.transcription,
      correct: correct ?? this.correct,
      wrong: wrong ?? this.wrong,
      lastCorrect: lastCorrect ?? this.lastCorrect,
      contexts: contexts ?? this.contexts,
    );
  }

  static String? _parseLastCorrect(Object? value) {
    if (value is String && value.trim().isNotEmpty) {
      return value;
    }

    return null;
  }
}
