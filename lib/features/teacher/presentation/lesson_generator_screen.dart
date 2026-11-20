import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../app/theme/app_colors.dart';
import '../../../core/widgets/buttons.dart';
import '../../../core/widgets/cards.dart';
import '../../../core/widgets/inputs.dart';
import '../data/teacher_repository.dart';
import '../domain/lesson_model.dart';

class LessonGeneratorScreen extends ConsumerStatefulWidget {
  const LessonGeneratorScreen({super.key});

  @override
  ConsumerState<LessonGeneratorScreen> createState() =>
      _LessonGeneratorScreenState();
}

class _LessonGeneratorScreenState extends ConsumerState<LessonGeneratorScreen> {
  final _formKey = GlobalKey<FormState>();
  final _subjectController = TextEditingController(text: 'Физика');
  final _gradeController = TextEditingController(text: '9');
  final _topicController = TextEditingController(text: 'Законы Ньютона');
  final _durationController = TextEditingController(text: '45');
  final _objectivesController = TextEditingController();

  String _difficulty = 'medium';
  final String _language = 'ru';
  bool _isLoading = false;
  LessonPlanModel? _generatedPlan;

  @override
  void dispose() {
    _subjectController.dispose();
    _gradeController.dispose();
    _topicController.dispose();
    _durationController.dispose();
    _objectivesController.dispose();
    super.dispose();
  }

  Future<void> _generate() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    setState(() => _isLoading = true);

    try {
      final repo = ref.read(teacherRepositoryProvider);
      final plan = await repo.generateLesson(
        subject: _subjectController.text.trim(),
        grade: _gradeController.text.trim(),
        topic: _topicController.text.trim(),
        durationMinutes: int.tryParse(_durationController.text) ?? 45,
        difficulty: _difficulty,
        language: _language,
        learningObjectives: _objectivesController.text.trim().isNotEmpty
            ? _objectivesController.text.trim()
            : null,
      );

      setState(() {
        _generatedPlan = plan;
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
      appBar: AppBar(
        title: const Text('Генератор уроков'),
        actions: [
          IconButton(
            icon: const Icon(Icons.history_rounded),
            onPressed: () => context.push('/teacher/history'),
          ),
        ],
      ),
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
                    Row(
                      children: [
                        Expanded(
                          flex: 2,
                          child: CustomTextField(
                            controller: _subjectController,
                            label: 'Предмет',
                            hint: 'Например, Алгебра',
                            validator: (v) =>
                                v?.isEmpty == true ? 'Обязательно' : null,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: CustomTextField(
                            controller: _gradeController,
                            label: 'Класс',
                            hint: '9',
                            keyboardType: TextInputType.number,
                            validator: (v) =>
                                v?.isEmpty == true ? 'Обязательно' : null,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    CustomTextField(
                      controller: _topicController,
                      label: 'Тема урока',
                      hint: 'Например, Первые шаги в кинематике',
                      validator: (v) =>
                          v?.isEmpty == true ? 'Обязательно' : null,
                    ),
                    const SizedBox(height: 14),
                    Row(
                      children: [
                        Expanded(
                          child: CustomTextField(
                            controller: _durationController,
                            label: 'Длительность (мин)',
                            keyboardType: TextInputType.number,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Сложность',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(height: 8),
                              DropdownButtonFormField<String>(
                                value: _difficulty,
                                decoration: const InputDecoration(
                                  contentPadding: EdgeInsets.symmetric(
                                    horizontal: 14,
                                    vertical: 14,
                                  ),
                                ),
                                items: const [
                                  DropdownMenuItem(
                                    value: 'easy',
                                    child: Text('Базовая'),
                                  ),
                                  DropdownMenuItem(
                                    value: 'medium',
                                    child: Text('Средняя'),
                                  ),
                                  DropdownMenuItem(
                                    value: 'hard',
                                    child: Text('Углубленная'),
                                  ),
                                ],
                                onChanged: (v) {
                                  if (v != null)
                                    setState(() => _difficulty = v);
                                },
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    CustomTextField(
                      controller: _objectivesController,
                      label: 'Цели обучения (необязательно)',
                      hint: 'Особые пожелания к уроку...',
                      maxLines: 2,
                    ),
                    const SizedBox(height: 18),
                    PrimaryButton(
                      text: 'Сгенерировать поурочный план',
                      icon: Icons.auto_awesome,
                      isLoading: _isLoading,
                      onPressed: _generate,
                    ),
                  ],
                ),
              ),

              if (_generatedPlan != null) ...[
                const SizedBox(height: 28),
                const Divider(),
                const SizedBox(height: 16),
                Row(
                  children: [
                    const Icon(
                      Icons.check_circle_rounded,
                      color: AppColors.success,
                      size: 24,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        _generatedPlan!.title,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Objectives
                _SectionCard(
                  title: 'Цели урока (Критерии успеха)',
                  content: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: _generatedPlan!.objectives
                        .map(
                          (o) => Padding(
                            padding: const EdgeInsets.symmetric(vertical: 2),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  '• ',
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                                Expanded(
                                  child: Text(
                                    o,
                                    style: const TextStyle(
                                      fontSize: 13,
                                      height: 1.4,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        )
                        .toList(),
                  ),
                ),
                const SizedBox(height: 12),

                // Introduction
                _SectionCard(
                  title: '1. Вводная часть',
                  content: Text(
                    _generatedPlan!.introduction,
                    style: const TextStyle(fontSize: 13, height: 1.45),
                  ),
                ),
                const SizedBox(height: 12),

                // Main Body
                _SectionCard(
                  title: '2. Основная часть',
                  content: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: _generatedPlan!.mainBody
                        .map(
                          (b) => Padding(
                            padding: const EdgeInsets.symmetric(vertical: 3),
                            child: Text(
                              '• $b',
                              style: const TextStyle(fontSize: 13, height: 1.4),
                            ),
                          ),
                        )
                        .toList(),
                  ),
                ),
                const SizedBox(height: 12),

                // Practical Tasks
                _SectionCard(
                  title: '3. Практические задания',
                  content: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: _generatedPlan!.practicalTasks
                        .map(
                          (t) => Padding(
                            padding: const EdgeInsets.symmetric(vertical: 3),
                            child: Text(
                              '✏️ $t',
                              style: const TextStyle(fontSize: 13, height: 1.4),
                            ),
                          ),
                        )
                        .toList(),
                  ),
                ),
                const SizedBox(height: 12),

                // Conclusion & Homework
                _SectionCard(
                  title: '4. Итоги и домашнее задание',
                  content: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Рефлексия: ${_generatedPlan!.conclusion}',
                        style: const TextStyle(fontSize: 13, height: 1.4),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Домашнее задание: ${_generatedPlan!.homework}',
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: AppColors.primary,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                SecondaryButton(
                  text: 'Создать тест по этой теме',
                  icon: Icons.quiz_rounded,
                  onPressed: () {
                    context.push('/teacher/quiz-generator');
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

class _SectionCard extends StatelessWidget {
  final String title;
  final Widget content;

  const _SectionCard({required this.title, required this.content});

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 8),
          content,
        ],
      ),
    );
  }
}
