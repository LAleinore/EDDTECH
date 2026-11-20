import 'package:flutter/material.dart';
import '../../../app/theme/app_colors.dart';
import '../../../core/widgets/buttons.dart';
import '../../../core/widgets/cards.dart';
import '../domain/quiz_model.dart';

class QuizTakingScreen extends StatefulWidget {
  final Map<String, dynamic>? quizData;

  const QuizTakingScreen({super.key, this.quizData});

  @override
  State<QuizTakingScreen> createState() => _QuizTakingScreenState();
}

class _QuizTakingScreenState extends State<QuizTakingScreen> {
  late QuizModel _quiz;
  final Map<int, String> _selectedAnswers = {};
  bool _isFinished = false;
  int _score = 0;

  @override
  void initState() {
    super.initState();
    if (widget.quizData != null) {
      _quiz = QuizModel.fromMap(widget.quizData!);
    } else {
      // Default sample quiz
      _quiz = QuizModel(
        title: 'Тест по основам физики',
        subject: 'Физика',
        grade: '9',
        topic: 'Законы Ньютона',
        language: 'ru',
        createdAt: DateTime.now(),
        questions: [
          QuizQuestionModel(
            id: 'q1',
            text: 'Какой закон связывает силу, массу и ускорение (F = ma)?',
            type: 'single_choice',
            options: [
              QuizOptionModel(id: 'a', text: 'Первый закон Ньютона'),
              QuizOptionModel(id: 'b', text: 'Второй закон Ньютона'),
              QuizOptionModel(id: 'c', text: 'Третий закон Ньютона'),
              QuizOptionModel(id: 'd', text: 'Закон всемирного тяготения'),
            ],
            correctOptionIds: ['b'],
            explanation:
                'Второй закон Ньютона гласит, что ускорение тела прямо пропорционально силе и обратно пропорционально массе.',
          ),
          QuizQuestionModel(
            id: 'q2',
            text: 'В каких единицах измеряется сила в системе СИ?',
            type: 'single_choice',
            options: [
              QuizOptionModel(id: 'a', text: 'Джоуль (Дж)'),
              QuizOptionModel(id: 'b', text: 'Ватт (Вт)'),
              QuizOptionModel(id: 'c', text: 'Ньютон (Н)'),
              QuizOptionModel(id: 'd', text: 'Паскаль (Па)'),
            ],
            correctOptionIds: ['c'],
            explanation: 'Единица измерения силы в СИ — Ньютон (Н = кг·м/с²).',
          ),
        ],
      );
    }
  }

  void _finishQuiz() {
    int correctCount = 0;
    for (int i = 0; i < _quiz.questions.length; i++) {
      final q = _quiz.questions[i];
      final chosen = _selectedAnswers[i];
      if (chosen != null && q.correctOptionIds.contains(chosen)) {
        correctCount++;
      }
    }
    setState(() {
      _score = correctCount;
      _isFinished = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(_quiz.title)),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (_isFinished) ...[
                // Result Banner
                AppCard(
                  padding: const EdgeInsets.all(20),
                  color: AppColors.successLight,
                  border: Border.all(color: AppColors.success, width: 1.5),
                  child: Column(
                    children: [
                      const Icon(
                        Icons.emoji_events_rounded,
                        size: 54,
                        color: AppColors.success,
                      ),
                      const SizedBox(height: 10),
                      const Text(
                        'Тест успешно пройден!',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textLight,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'Ваш результат: $_score из ${_quiz.questions.length} правильных ответов',
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: AppColors.success,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
              ],

              // Questions List
              ..._quiz.questions.asMap().entries.map((entry) {
                final index = entry.key;
                final q = entry.value;
                final selectedOpt = _selectedAnswers[index];

                return Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: AppCard(
                    padding: const EdgeInsets.all(18),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Вопрос ${index + 1} из ${_quiz.questions.length}',
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: AppColors.secondaryTextLight,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          q.text,
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 14),

                        ...q.options.map((opt) {
                          final isSelected = selectedOpt == opt.id;
                          Color? optColor;
                          if (_isFinished) {
                            if (q.correctOptionIds.contains(opt.id)) {
                              optColor = AppColors.successLight;
                            } else if (isSelected) {
                              optColor = AppColors.errorLight;
                            }
                          } else if (isSelected) {
                            optColor = AppColors.primaryLight;
                          }

                          return Padding(
                            padding: const EdgeInsets.only(bottom: 8),
                            child: InkWell(
                              onTap: _isFinished
                                  ? null
                                  : () {
                                      setState(() {
                                        _selectedAnswers[index] = opt.id;
                                      });
                                    },
                              borderRadius: BorderRadius.circular(12),
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 14,
                                  vertical: 12,
                                ),
                                decoration: BoxDecoration(
                                  color: optColor,
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: isSelected
                                        ? AppColors.primary
                                        : AppColors.dividerLight,
                                    width: isSelected ? 1.5 : 1,
                                  ),
                                ),
                                child: Row(
                                  children: [
                                    Icon(
                                      isSelected
                                          ? Icons.check_circle_rounded
                                          : Icons.radio_button_unchecked,
                                      color: isSelected
                                          ? AppColors.primary
                                          : AppColors.secondaryTextLight,
                                      size: 20,
                                    ),
                                    const SizedBox(width: 10),
                                    Expanded(
                                      child: Text(
                                        opt.text,
                                        style: TextStyle(
                                          fontSize: 13,
                                          fontWeight: isSelected
                                              ? FontWeight.w600
                                              : FontWeight.w400,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        }),

                        if (_isFinished) ...[
                          const SizedBox(height: 8),
                          Text(
                            'Пояснение: ${q.explanation}',
                            style: const TextStyle(
                              fontSize: 12,
                              color: AppColors.secondaryTextLight,
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                );
              }),

              if (!_isFinished) ...[
                PrimaryButton(
                  text: 'Завершить и проверить',
                  icon: Icons.check_rounded,
                  onPressed: _selectedAnswers.length == _quiz.questions.length
                      ? _finishQuiz
                      : null,
                ),
              ] else ...[
                SecondaryButton(
                  text: 'Пройти снова',
                  icon: Icons.refresh_rounded,
                  onPressed: () {
                    setState(() {
                      _selectedAnswers.clear();
                      _isFinished = false;
                      _score = 0;
                    });
                  },
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
