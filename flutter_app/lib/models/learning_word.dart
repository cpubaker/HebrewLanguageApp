import 'learning_context.dart';

class LearningWord {
  const LearningWord({
    required this.wordId,
    required this.hebrew,
    required this.english,
    this.ukrainian = '',
    required this.transcription,
    required this.correct,
    required this.wrong,
    this.writingCorrect = 0,
    this.writingWrong = 0,
    this.lastCorrect,
    this.writingLastCorrect,
    this.contexts = const <LearningContext>[],
  });

  factory LearningWord.fromJson(Map<String, dynamic> json) {
    return LearningWord(
      wordId: json['word_id'] as String? ?? '',
      hebrew: json['hebrew'] as String? ?? '',
      english: json['english'] as String? ?? '',
      ukrainian: json['ukrainian'] as String? ?? '',
      transcription: json['transcription'] as String? ?? '',
      correct: (json['correct'] as num?)?.toInt() ?? 0,
      wrong: (json['wrong'] as num?)?.toInt() ?? 0,
      lastCorrect: _parseLastCorrect(json['last_correct']),
      writingCorrect: (json['writing_correct'] as num?)?.toInt() ?? 0,
      writingWrong: (json['writing_wrong'] as num?)?.toInt() ?? 0,
      writingLastCorrect: _parseLastCorrect(json['writing_last_correct']),
      contexts: (json['_contexts'] as List<dynamic>? ?? const <dynamic>[])
          .whereType<Map<String, dynamic>>()
          .map(LearningContext.fromJson)
          .toList(growable: false),
    );
  }

  final String wordId;
  final String hebrew;
  final String english;
  final String ukrainian;
  final String transcription;
  final int correct;
  final int wrong;
  final String? lastCorrect;
  final int writingCorrect;
  final int writingWrong;
  final String? writingLastCorrect;
  final List<LearningContext> contexts;

  LearningWord copyWith({
    String? wordId,
    String? hebrew,
    String? english,
    String? ukrainian,
    String? transcription,
    int? correct,
    int? wrong,
    String? lastCorrect,
    int? writingCorrect,
    int? writingWrong,
    String? writingLastCorrect,
    List<LearningContext>? contexts,
  }) {
    return LearningWord(
      wordId: wordId ?? this.wordId,
      hebrew: hebrew ?? this.hebrew,
      english: english ?? this.english,
      ukrainian: ukrainian ?? this.ukrainian,
      transcription: transcription ?? this.transcription,
      correct: correct ?? this.correct,
      wrong: wrong ?? this.wrong,
      lastCorrect: lastCorrect ?? this.lastCorrect,
      writingCorrect: writingCorrect ?? this.writingCorrect,
      writingWrong: writingWrong ?? this.writingWrong,
      writingLastCorrect: writingLastCorrect ?? this.writingLastCorrect,
      contexts: contexts ?? this.contexts,
    );
  }

  String get translation {
    final normalizedUkrainian = ukrainian.trim();
    if (normalizedUkrainian.isNotEmpty) {
      return normalizedUkrainian;
    }

    return english;
  }

  static String? _parseLastCorrect(Object? value) {
    if (value is String && value.trim().isNotEmpty) {
      return value;
    }

    return null;
  }
}
