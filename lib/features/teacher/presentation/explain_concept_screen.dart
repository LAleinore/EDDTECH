import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/widgets/buttons.dart';
import '../../../core/widgets/cards.dart';
import '../../../core/widgets/inputs.dart';
import '../data/teacher_repository.dart';

class ExplainConceptScreen extends ConsumerStatefulWidget {
  const ExplainConceptScreen({super.key});

  @override
  ConsumerState<ExplainConceptScreen> createState() =>
      _ExplainConceptScreenState();
}

class _ExplainConceptScreenState extends ConsumerState<ExplainConceptScreen> {
  final _subjectController = TextEditingController(text: 'Астрономия');
  final _topicController = TextEditingController(text: 'Гравитационные волны');
  final _gradeController = TextEditingController(text: '10');
  bool _isLoading = false;
  Map<String, dynamic>? _explanation;

  @override
  void dispose() {
    _subjectController.dispose();
    _topicController.dispose();
    _gradeController.dispose();
    super.dispose();
  }

  Future<void> _explain() async {
    if (_topicController.text.trim().isEmpty) return;
    setState(() => _isLoading = true);

    try {
      final repo = ref.read(teacherRepositoryProvider);
      final res = await repo.explainConcept(
        subject: _subjectController.text.trim(),
        topic: _topicController.text.trim(),
        grade: _gradeController.text.trim(),
      );
      setState(() {
        _explanation = res;
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
      appBar: AppBar(title: const Text('Объяснить сложную тему')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              CustomTextField(controller: _subjectController, label: 'Предмет'),
              const SizedBox(height: 12),
              CustomTextField(
                controller: _topicController,
                label: 'Сложный термин или тема',
                hint: 'Например, Квантовая суперпозиция',
              ),
              const SizedBox(height: 12),
              CustomTextField(
                controller: _gradeController,
                label: 'Уровень понимания (Класс)',
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 18),
              PrimaryButton(
                text: 'Сгенерировать понятное объяснение',
                icon: Icons.lightbulb_outline_rounded,
                isLoading: _isLoading,
                onPressed: _explain,
              ),

              if (_explanation != null) ...[
                const SizedBox(height: 24),
                AppCard(
                  padding: const EdgeInsets.all(18),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _explanation!['title'] ?? 'Объяснение темы',
                        style: const TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        _explanation!['simpleExplanation'] ?? '',
                        style: const TextStyle(fontSize: 14, height: 1.5),
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'Пошаговый разбор:',
                        style: TextStyle(fontWeight: FontWeight.w700),
                      ),
                      const SizedBox(height: 6),
                      ...((_explanation!['stepByStepGuide'] as List? ?? []).map(
                        (step) => Padding(
                          padding: const EdgeInsets.symmetric(vertical: 2),
                          child: Text(
                            '• $step',
                            style: const TextStyle(fontSize: 13, height: 1.4),
                          ),
                        ),
                      )),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
