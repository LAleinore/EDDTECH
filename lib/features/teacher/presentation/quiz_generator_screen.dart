import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../app/theme/app_colors.dart';
import '../../../core/widgets/buttons.dart';
import '../../../core/widgets/cards.dart';
import '../../../core/widgets/inputs.dart';
import '../data/teacher_repository.dart';
import '../domain/quiz_model.dart';

class QuizGeneratorScreen extends ConsumerStatefulWidget {
  const QuizGeneratorScreen({super.key});

  @override
  ConsumerState<QuizGeneratorScreen> createState() =>
      _QuizGeneratorScreenState();
}

class _QuizGeneratorScreenState extends ConsumerState<QuizGeneratorScreen> {
  final _formKey = GlobalKey<FormState>();
  final _subjectController = TextEditingController(text: 'Физика');
  final _topicController = TextEditingController(text: 'Законы динамики');
  final _gradeController = TextEditingController(text: '9');
  int _questionsCount = 5;
  final String _difficulty = 'medium';
  bool _isLoading = false;
  QuizModel? _generatedQuiz;

  @override
  void dispose() {
    _subjectController.dispose();
    _topicController.dispose();
    _gradeController.dispose();
    super.dispose();
  }

  Future<void> _generate() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    setState(() => _isLoading = true);

    try {
      final repo = ref.read(teacherRepositoryProvider);
      final quiz = await repo.generateQuiz(
        subject: _subjectController.text.trim(),
        topic: _topicController.text.trim(),
        grade: _gradeController.text.trim(),
        count: _questionsCount,
        difficulty: _difficulty,
      );
      setState(() {
        _generatedQuiz = quiz;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Ошибка: $e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Конструктор тестов')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Form(
                key: _formKey,
                child: Column(
                  children: [
                    CustomTextField(
                      controller: _subjectController,
                      label: 'Предмет',
                      hint: 'Биология / Физика / История',
                      validator: (v) =>
                          v?.isEmpty == true ? 'Обязательно' : null,
                    ),
                    const SizedBox(height: 14),
                    CustomTextField(
                      controller: _topicController,
                      label: 'Тема теста',
                      hint: 'Например, Строение клетки',
                      validator: (v) =>
                          v?.isEmpty == true ? 'Обязательно' : null,
                    ),
                    const SizedBox(height: 14),
                    Row(
                      children: [
                        Expanded(
                          child: CustomTextField(
                            controller: _gradeController,
                            label: 'Класс',
                            keyboardType: TextInputType.number,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Количество',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(height: 8),
                              DropdownButtonFormField<int>(
                                value: _questionsCount,
                                decoration: const InputDecoration(
                                  contentPadding: EdgeInsets.symmetric(
                                    horizontal: 14,
                                    vertical: 14,
                                  ),
                                ),
                                items: const [
                                  DropdownMenuItem(
                                    value: 3,
                                    child: Text('3 вопроса'),
                                  ),
                                  DropdownMenuItem(
                                    value: 5,
                                    child: Text('5 вопросов'),
                                  ),
                                  DropdownMenuItem(
                                    value: 10,
                                    child: Text('10 вопросов'),
                                  ),
                                ],
                                onChanged: (v) {
                                  if (v != null)
                                    setState(() => _questionsCount = v);
                                },
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 18),
                    PrimaryButton(
                      text: 'Создать интерактивный тест',
                      icon: Icons.quiz_rounded,
                      isLoading: _isLoading,
                      onPressed: _generate,
                    ),
                  ],
                ),
              ),

              if (_generatedQuiz != null) ...[
                const SizedBox(height: 28),
                const Divider(),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        _generatedQuiz!.title,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.success,
                        minimumSize: const Size(0, 40),
                        padding: const EdgeInsets.symmetric(horizontal: 14),
                      ),
                      onPressed: () {
                        context.push(
                          '/teacher/quiz-take',
                          extra: _generatedQuiz!.toMap(),
                        );
                      },
                      icon: const Icon(Icons.play_arrow_rounded, size: 20),
                      label: const Text(
                        'Пройти тест',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Question Cards
                ..._generatedQuiz!.questions.asMap().entries.map((entry) {
                  final idx = entry.key + 1;
                  final q = entry.value;
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 14),
                    child: AppCard(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '$idx. ${q.text}',
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 10),
                          ...q.options.map(
                            (opt) => Padding(
                              padding: const EdgeInsets.symmetric(vertical: 3),
                              child: Row(
                                children: [
                                  const Icon(
                                    Icons.radio_button_unchecked,
                                    size: 16,
                                    color: AppColors.secondaryTextLight,
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      opt.text,
                                      style: const TextStyle(fontSize: 13),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            '💡 Пояснение: ${q.explanation}',
                            style: const TextStyle(
                              fontSize: 11,
                              color: AppColors.secondaryTextLight,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
