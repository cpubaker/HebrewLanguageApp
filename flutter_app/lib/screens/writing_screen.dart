import 'package:flutter/material.dart';

import '../models/learning_word.dart';
import '../services/flashcard_session.dart';
import '../services/writing_session.dart';
import '../theme/app_theme.dart';
import 'widgets/practice_header.dart';
import 'widgets/practice_session_summary.dart';
import 'widgets/practice_stat_pill.dart';

class WritingScreen extends StatefulWidget {
  const WritingScreen({
    super.key,
    required this.words,
    required this.onWordProgressChanged,
  });

  final List<LearningWord> words;
  final WordProgressCallback onWordProgressChanged;

  @override
  State<WritingScreen> createState() => _WritingScreenState();
}

class _WritingScreenState extends State<WritingScreen> {
  late final WritingSession _session;
  late final TextEditingController _answerController;

  WritingPrompt? _currentPrompt;
  WritingAnswerResult? _currentAnswer;
  String? _inlineMessage;

  @override
  void initState() {
    super.initState();
    _session = WritingSession(widget.words);
    _answerController = TextEditingController();
    _moveToNextPrompt();
  }

  @override
  void dispose() {
    _answerController.dispose();
    super.dispose();
  }

  void _moveToNextPrompt() {
    setState(() {
      _currentPrompt = _session.nextPrompt();
      _currentAnswer = null;
      _inlineMessage = null;
      _answerController.clear();
    });
  }

  void _submitAnswer() {
    final result = _session.submitAnswer(_answerController.text);
    if (result == null) {
      return;
    }

    if (result.status == WritingAnswerStatus.empty) {
      setState(() {
        _inlineMessage = 'Введіть слово івритом, щоб перевірити відповідь.';
      });
      return;
    }

    setState(() {
      _currentAnswer = result;
      _inlineMessage = null;
    });

    widget.onWordProgressChanged(result.word);
  }

  @override
  Widget build(BuildContext context) {
    final tokens = Theme.of(context).appTokens;
    final currentPrompt = _currentPrompt;
    if (currentPrompt == null) {
      return const _EmptyWritingState();
    }

    final currentWord = _currentAnswer?.word ?? currentPrompt.word;
    final hasAnswered = _currentAnswer != null;
    final isCorrect = _currentAnswer?.isCorrect == true;
    final stats = _session.currentWordStats();

    return ListView(
      padding: tokens.pagePadding.copyWith(bottom: 32),
      children: [
        const PracticeHeader(
          title: 'Письмо',
          subtitle:
              'Бачите переклад українською, а потім вводите слово івритом з пам’яті.',
        ),
        const SizedBox(height: 18),
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(28),
            boxShadow: const [
              BoxShadow(
                color: Color(0x14000000),
                blurRadius: 22,
                offset: Offset(0, 12),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFFF1F6F2), Color(0xFFF7F3E8)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Column(
                  children: [
                    Text(
                      'РЎР»РѕРІРѕ РґР»СЏ РїРµСЂРµРєР»Р°РґСѓ',
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        color: const Color(0xFF5F5A52),
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      currentPrompt.prompt,
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.headlineSmall
                          ?.copyWith(
                            fontWeight: FontWeight.w800,
                            color: const Color(0xFF163832),
                          ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Підказку не показуємо: тут працюємо саме на пригадування.',
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: const Color(0xFF6C665D),
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 18),
              TextField(
                controller: _answerController,
                enabled: !hasAnswered,
                textDirection: TextDirection.rtl,
                textAlign: TextAlign.center,
                textInputAction: TextInputAction.done,
                onSubmitted: (_) => _submitAnswer(),
                decoration: InputDecoration(
                  hintText: 'Введіть слово івритом',
                  prefixIcon: const Icon(Icons.edit_rounded),
                  filled: true,
                  fillColor: const Color(0xFFF9F5EC),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 18,
                    vertical: 16,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(20),
                    borderSide: BorderSide.none,
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(20),
                    borderSide: const BorderSide(color: Color(0x1F8C6A2A)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(20),
                    borderSide: const BorderSide(
                      color: Color(0xFF8C6A2A),
                      width: 1.5,
                    ),
                  ),
                ),
              ),
              if (_inlineMessage != null) ...[
                const SizedBox(height: 12),
                Text(
                  _inlineMessage!,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: const Color(0xFFB45309),
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
              const SizedBox(height: 18),
              if (hasAnswered)
                _WritingResultCard(
                  isCorrect: isCorrect,
                  correctAnswer:
                      _currentAnswer?.correctAnswer ?? currentWord.hebrew,
                  lastCorrect: stats.lastCorrect == null
                      ? null
                      : _formatTimestamp(stats.lastCorrect!),
                )
              else
                Text(
                  'Натисніть «Перевірити», коли будете готові.',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: const Color(0xFF6C665D),
                  ),
                ),
              const SizedBox(height: 18),
              Row(
                children: [
                  Expanded(
                    child: PracticeStatPill(
                      label: 'РџСЂР°РІРёР»СЊРЅРѕ',
                      value: stats.correct,
                      accent: const Color(0xFF0F766E),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: PracticeStatPill(
                      label: 'РџРѕРјРёР»РєРё',
                      value: stats.wrong,
                      accent: const Color(0xFFB91C1C),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 18),
              Wrap(
                spacing: 12,
                runSpacing: 12,
                alignment: WrapAlignment.center,
                children: [
                  FilledButton.icon(
                    onPressed: hasAnswered ? null : _submitAnswer,
                    icon: const Icon(Icons.check_rounded),
                    label: const Text('РџРµСЂРµРІС–СЂРёС‚Рё'),
                  ),
                  OutlinedButton.icon(
                    onPressed: hasAnswered ? _moveToNextPrompt : null,
                    icon: const Icon(Icons.arrow_forward_rounded),
                    label: const Text('Р”Р°Р»С–'),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              PracticeSessionSummary(
                title: 'Поточна сесія',
                lines: [
                  'Перевірено відповідей: ${_session.answeredCount}',
                  '${widget.words.length} слів доступні для письма на цьому пристрої',
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  String _formatTimestamp(String value) {
    final parsed = DateTime.tryParse(value);
    if (parsed == null) {
      return value;
    }

    final local = parsed.toLocal();
    final month = local.month.toString().padLeft(2, '0');
    final day = local.day.toString().padLeft(2, '0');
    final hour = local.hour.toString().padLeft(2, '0');
    final minute = local.minute.toString().padLeft(2, '0');
    return '$day.$month.${local.year} $hour:$minute';
  }
}

class _WritingResultCard extends StatelessWidget {
  const _WritingResultCard({
    required this.isCorrect,
    required this.correctAnswer,
    this.lastCorrect,
  });

  final bool isCorrect;
  final String correctAnswer;
  final String? lastCorrect;

  @override
  Widget build(BuildContext context) {
    final accent = isCorrect
        ? const Color(0xFF0F766E)
        : const Color(0xFFB91C1C);
    final background = isCorrect
        ? const Color(0xFFEAF5EE)
        : const Color(0xFFF8ECE8);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        children: [
          Wrap(
            alignment: WrapAlignment.center,
            crossAxisAlignment: WrapCrossAlignment.center,
            spacing: 8,
            runSpacing: 6,
            children: [
              Icon(
                isCorrect ? Icons.check_circle_rounded : Icons.cancel_rounded,
                color: accent,
                size: 22,
              ),
              Text(
                isCorrect ? 'Правильно' : 'Потрібно ще раз',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w800,
                  color: const Color(0xFF5F5A52),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            correctAnswer,
            textDirection: TextDirection.rtl,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.w800,
              color: const Color(0xFF163832),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            isCorrect
                ? 'РЎР»РѕРІРѕ Р·Р°РїРёСЃР°РЅРѕ РїСЂР°РІРёР»СЊРЅРѕ. РњРѕР¶РЅР° РїРµСЂРµС…РѕРґРёС‚Рё РґР°Р»С–.'
                : 'Р—РІС–СЂС‚Рµ С„РѕСЂРјСѓ С– РЅР°РїРёС€С–С‚СЊ РЅР°СЃС‚СѓРїРЅРµ СЃР»РѕРІРѕ Р· РїР°РјвЂ™СЏС‚С–.',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: const Color(0xFF6C665D),
              height: 1.45,
            ),
          ),
          if (lastCorrect != null) ...[
            const SizedBox(height: 10),
            Text(
              'Р’РѕСЃС‚Р°РЅРЅС” РїСЂР°РІРёР»СЊРЅРѕ: $lastCorrect',
              textAlign: TextAlign.center,
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(color: const Color(0xFF6C665D)),
            ),
          ],
        ],
      ),
    );
  }
}

class _EmptyWritingState extends StatelessWidget {
  const _EmptyWritingState();

  @override
  Widget build(BuildContext context) {
    final tokens = Theme.of(context).appTokens;
    return ListView(
      padding: tokens.pagePadding.copyWith(bottom: 32),
      children: [
        const PracticeHeader(
          title: 'Письмо',
          subtitle:
              'Коли слова завантажаться, тут можна буде тренувати написання івритом.',
        ),
        const SizedBox(height: 18),
        Container(
          padding: const EdgeInsets.all(22),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(28),
          ),
          child: Text(
            'Щойно у наборі з’являться доступні слова, тут можна буде тренувати письмо окремою сесією.',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              color: const Color(0xFF5F5A52),
              height: 1.45,
            ),
          ),
        ),
      ],
    );
  }
}
