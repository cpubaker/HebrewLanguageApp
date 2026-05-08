class PracticeWordStats {
  const PracticeWordStats({
    required this.correct,
    required this.wrong,
    required this.total,
    required this.lastCorrect,
  });

  static const empty = PracticeWordStats(
    correct: 0,
    wrong: 0,
    total: 0,
    lastCorrect: null,
  );

  final int correct;
  final int wrong;
  final int total;
  final String? lastCorrect;
}
