import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../app/theme/app_colors.dart';
import '../../../core/widgets/cards.dart';

class LearningHubScreen extends ConsumerStatefulWidget {
  const LearningHubScreen({super.key});

  @override
  ConsumerState<LearningHubScreen> createState() => _LearningHubScreenState();
}

class _LearningHubScreenState extends ConsumerState<LearningHubScreen> {
  String _selectedCategory = 'Все';

  final List<Map<String, dynamic>> _courses = [
    {
      'id': 'course-math-01',
      'title': 'Алгебра: Квадратные уравнения и функции',
      'category': 'Математика',
      'grade': '8-9 классы',
      'icon': Icons.calculate_rounded,
      'color': AppColors.primary,
      'progress': 0.85,
      'lessonsCount': 12,
      'completedCount': 10,
      'description': 'Полный разбор дискриминанта, теоремы Виета и графиков парабол с практическими тестами.',
    },
    {
      'id': 'course-ai-02',
      'title': 'Информатика: Python и введение в ИИ',
      'category': 'Информатика',
      'grade': '9-11 классы',
      'icon': Icons.code_rounded,
      'color': AppColors.teacherAccent,
      'progress': 0.50,
      'lessonsCount': 16,
      'completedCount': 8,
      'description': 'Алгоритмы, списки, функции и основы работы нейросетевых моделей на практике.',
    },
    {
      'id': 'course-phys-03',
      'title': 'Физика: Механика и законы движения',
      'category': 'Физика',
      'grade': '10 класс',
      'icon': Icons.bolt_rounded,
      'color': AppColors.warning,
      'progress': 0.30,
      'lessonsCount': 10,
      'completedCount': 3,
      'description': 'Кинематика, динамика Ньютона, импульс и закон сохранения энергии.',
    },
    {
      'id': 'course-eng-04',
      'title': 'Академический английский: B2-C1 Grammar & Essay',
      'category': 'Языки',
      'grade': '10-11 классы',
      'icon': Icons.translate_rounded,
      'color': AppColors.success,
      'progress': 0.15,
      'lessonsCount': 14,
      'completedCount': 2,
      'description': 'Подготовка к эссе, расширенный словарный запас и грамматические структуры.',
    },
  ];

  @override
  Widget build(BuildContext context) {
    final categories = ['Все', 'Математика', 'Информатика', 'Физика', 'Языки'];

    final filtered = _selectedCategory == 'Все'
        ? _courses
        : _courses.where((c) => c['category'] == _selectedCategory).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Учебный центр EduMind',
          style: TextStyle(fontWeight: FontWeight.w800),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Learning Banner
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [AppColors.primaryDark, AppColors.primary],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withOpacity(0.25),
                    blurRadius: 16,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Row(
                          children: [
                            Icon(Icons.auto_stories_rounded, color: Colors.white, size: 14),
                            SizedBox(width: 4),
                            Text(
                              'ИНТЕРАКТИВНОЕ ОБУЧЕНИЕ',
                              style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'Учебная программа и тренажеры',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Изучайте материалы, проходите интерактивные тесты с автоматической оценкой и задавайте вопросы AI Тьютору.',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.9),
                      fontSize: 12,
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Category Chips
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: categories.map((cat) {
                  final isSelected = _selectedCategory == cat;
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: FilterChip(
                      selected: isSelected,
                      label: Text(cat),
                      labelStyle: TextStyle(
                        fontSize: 13,
                        fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                        color: isSelected ? Colors.white : AppColors.textLight,
                      ),
                      selectedColor: AppColors.primary,
                      backgroundColor: Theme.of(context).cardColor,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      onSelected: (val) {
                        setState(() => _selectedCategory = cat);
                      },
                    ),
                  );
                }).toList(),
              ),
            ),
            const SizedBox(height: 16),

            // Courses List
            Text(
              'Доступные курсы (${filtered.length})',
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 12),

            ...filtered.map((c) => _buildCourseCard(context, c)),
          ],
        ),
      ),
    );
  }

  Widget _buildCourseCard(BuildContext context, Map<String, dynamic> c) {
    final double progress = c['progress'] as double;
    final Color color = c['color'] as Color;

    return AppCard(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(18),
      onTap: () {
        _showLessonModal(context, c);
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(c['icon'] as IconData, color: color, size: 24),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: Colors.grey.withOpacity(0.12),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            c['grade'] as String,
                            style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w600),
                          ),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          c['category'] as String,
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: color,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      c['title'] as String,
                      style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right_rounded, color: AppColors.secondaryTextLight),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            c['description'] as String,
            style: const TextStyle(fontSize: 12, color: AppColors.secondaryTextLight, height: 1.3),
          ),
          const SizedBox(height: 14),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Пройдено: ${c['completedCount']}/${c['lessonsCount']} уроков',
                style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600),
              ),
              Text(
                '${(progress * 100).toInt()}%',
                style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: color),
              ),
            ],
          ),
          const SizedBox(height: 6),
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: LinearProgressIndicator(
              value: progress,
              backgroundColor: color.withOpacity(0.12),
              valueColor: AlwaysStoppedAnimation<Color>(color),
              minHeight: 6,
            ),
          ),
        ],
      ),
    );
  }

  void _showLessonModal(BuildContext context, Map<String, dynamic> c) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return DraggableScrollableSheet(
          initialChildSize: 0.85,
          maxChildSize: 0.95,
          minChildSize: 0.5,
          expand: false,
          builder: (_, scrollCtrl) {
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              child: ListView(
                controller: scrollCtrl,
                children: [
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade400,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    c['title'] as String,
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${c['category']} • ${c['grade']} • Модуль 1',
                    style: const TextStyle(fontSize: 12, color: AppColors.secondaryTextLight),
                  ),
                  const SizedBox(height: 16),
                  const Divider(),
                  const SizedBox(height: 10),

                  // Interactive Lesson Material
                  const Text(
                    'Теория урока: Основные понятия',
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.06),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.primary.withOpacity(0.2)),
                    ),
                    child: const Text(
                      'Квадратным уравнением называется уравнение вида ax² + bx + c = 0, где a ≠ 0.\n\n'
                      '• Дискриминант: D = b² - 4ac\n'
                      '• Если D > 0: два различных корня: x₁,₂ = (-b ± √D) / (2a)\n'
                      '• Если D = 0: один корень: x = -b / (2a)\n'
                      '• Если D < 0: действительных корней нет',
                      style: TextStyle(fontSize: 13, height: 1.4),
                    ),
                  ),
                  const SizedBox(height: 16),

                  const Text(
                    'Интерактивное закрепление',
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 8),
                  _buildInteractiveTask(),

                  const SizedBox(height: 20),
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      minimumSize: const Size.fromHeight(48),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    onPressed: () {
                      Navigator.pop(ctx);
                      context.push('/assistant');
                    },
                    icon: const Icon(Icons.help_outline_rounded),
                    label: const Text('Задать вопрос AI Тьютору по теме'),
                  ),
                  const SizedBox(height: 12),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildInteractiveTask() {
    int? selectedOption;
    bool? isCorrect;

    return StatefulBuilder(
      builder: (context, setInnerState) {
        return Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey.withOpacity(0.25)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Вопрос 1: Сколько действительных корней имеет уравнение x² - 6x + 9 = 0?',
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 10),
              ...[
                {'val': 0, 'text': '2 корня'},
                {'val': 1, 'text': '1 корень (D = 0)'},
                {'val': 2, 'text': '0 корней (D < 0)'},
              ].map((opt) {
                final val = opt['val'] as int;
                final isSelected = selectedOption == val;
                return Container(
                  margin: const EdgeInsets.only(bottom: 6),
                  child: ListTile(
                    dense: true,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                      side: BorderSide(
                        color: isSelected
                            ? (isCorrect == true ? AppColors.success : (isCorrect == false ? AppColors.error : AppColors.primary))
                            : Colors.grey.withOpacity(0.2),
                      ),
                    ),
                    tileColor: isSelected
                        ? (isCorrect == true
                            ? AppColors.success.withOpacity(0.1)
                            : (isCorrect == false ? AppColors.error.withOpacity(0.1) : AppColors.primary.withOpacity(0.08)))
                        : null,
                    title: Text(opt['text'] as String, style: const TextStyle(fontSize: 12)),
                    onTap: () {
                      setInnerState(() {
                        selectedOption = val;
                        isCorrect = val == 1;
                      });
                    },
                  ),
                );
              }),
              if (isCorrect != null) ...[
                const SizedBox(height: 6),
                Text(
                  isCorrect!
                      ? 'Правильно! D = (-6)² - 4*1*9 = 36 - 36 = 0, значит уравнение имеет один корень x = 3.'
                      : 'Неверно. Вычислите дискриминант: D = b² - 4ac = 36 - 36 = 0.',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: isCorrect! ? AppColors.success : AppColors.error,
                  ),
                ),
              ],
            ],
          ),
        );
      },
    );
  }
}
