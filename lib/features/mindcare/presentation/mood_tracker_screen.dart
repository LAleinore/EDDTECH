import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../app/theme/app_colors.dart';
import '../../../core/widgets/buttons.dart';
import '../../../core/widgets/cards.dart';
import '../../../core/widgets/inputs.dart';
import '../data/mindcare_repository.dart';
import '../domain/mood_model.dart';

class MoodTrackerScreen extends ConsumerStatefulWidget {
  const MoodTrackerScreen({super.key});

  @override
  ConsumerState<MoodTrackerScreen> createState() => _MoodTrackerScreenState();
}

class _MoodTrackerScreenState extends ConsumerState<MoodTrackerScreen> {
  int _selectedScore = 4; // 1 to 5
  final List<String> _selectedEmotions = [];
  final _noteController = TextEditingController();
  bool _isLoading = false;
  late Future<List<MoodModel>> _moodHistoryFuture;

  final List<Map<String, dynamic>> _moodGrades = [
    {
      'score': 1,
      'state': 'terrible',
      'label': 'Очень плохо',
      'icon': Icons.sentiment_very_dissatisfied_rounded,
      'color': AppColors.error,
    },
    {
      'score': 2,
      'state': 'bad',
      'label': 'Плохо',
      'icon': Icons.sentiment_dissatisfied_rounded,
      'color': AppColors.warning,
    },
    {
      'score': 3,
      'state': 'neutral',
      'label': 'Нейтрально',
      'icon': Icons.sentiment_neutral_rounded,
      'color': Colors.blueGrey,
    },
    {
      'score': 4,
      'state': 'good',
      'label': 'Хорошо',
      'icon': Icons.sentiment_satisfied_rounded,
      'color': AppColors.mindcareAccent,
    },
    {
      'score': 5,
      'state': 'excellent',
      'label': 'Отлично',
      'icon': Icons.sentiment_very_satisfied_rounded,
      'color': AppColors.success,
    },
  ];

  final List<String> _availableEmotions = [
    'Спокойствие',
    'Вдохновение',
    'Радость',
    'Уверенность',
    'Усталость',
    'Тревога',
    'Апатия',
    'Сфокусированность',
  ];

  @override
  void initState() {
    super.initState();
    _loadHistory();
  }

  void _loadHistory() {
    _moodHistoryFuture = ref.read(mindcareRepositoryProvider).getMoodEntries();
  }

  @override
  void dispose() {
    _noteController.dispose();
    super.dispose();
  }

  Future<void> _saveMood() async {
    setState(() => _isLoading = true);
    final stateStr = _moodGrades.firstWhere(
      (g) => g['score'] == _selectedScore,
    )['state'];

    await ref
        .read(mindcareRepositoryProvider)
        .saveMoodEntry(
          score: _selectedScore,
          moodState: stateStr,
          emotions: _selectedEmotions,
          note: _noteController.text.trim(),
        );

    setState(() {
      _isLoading = false;
      _selectedEmotions.clear();
      _noteController.clear();
      _loadHistory();
    });

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Настроение успешно сохранено!')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Трекер настроения')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                'Как ваше настроение сегодня?',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 16),

              // 5 Mood Emoji Selector
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: _moodGrades.map((grade) {
                  final isSelected = _selectedScore == grade['score'];
                  return GestureDetector(
                    onTap: () =>
                        setState(() => _selectedScore = grade['score']),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 12,
                      ),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? (grade['color'] as Color).withOpacity(0.18)
                            : null,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: isSelected
                              ? grade['color'] as Color
                              : AppColors.dividerLight,
                          width: isSelected ? 2 : 1,
                        ),
                      ),
                      child: Column(
                        children: [
                          Icon(
                            grade['icon'] as IconData,
                            size: 30,
                            color: isSelected ? (grade['color'] as Color) : Colors.grey,
                          ),
                          const SizedBox(height: 6),
                          Text(
                            grade['label'],
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: isSelected
                                  ? FontWeight.bold
                                  : FontWeight.normal,
                              color: isSelected
                                  ? grade['color'] as Color
                                  : AppColors.secondaryTextLight,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 20),

              // Emotions Selector
              const Text(
                'Что вы чувствуете?',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _availableEmotions.map((emotion) {
                  final isSelected = _selectedEmotions.contains(emotion);
                  return FilterChip(
                    label: Text(
                      emotion,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: isSelected
                            ? FontWeight.bold
                            : FontWeight.normal,
                      ),
                    ),
                    selected: isSelected,
                    selectedColor: AppColors.mindcareAccent.withOpacity(0.2),
                    onSelected: (selected) {
                      setState(() {
                        if (selected) {
                          _selectedEmotions.add(emotion);
                        } else {
                          _selectedEmotions.remove(emotion);
                        }
                      });
                    },
                  );
                }).toList(),
              ),
              const SizedBox(height: 14),

              CustomTextField(
                controller: _noteController,
                label: 'Заметка (необязательно)',
                hint: 'Что повлияло на ваше состояние?',
                maxLines: 2,
              ),
              const SizedBox(height: 16),

              PrimaryButton(
                text: 'Зафиксировать настроение',
                backgroundColor: AppColors.mindcareAccent,
                isLoading: _isLoading,
                onPressed: _saveMood,
              ),
              const SizedBox(height: 28),

              // Dynamic Mood History Section
              const Divider(),
              const SizedBox(height: 14),
              const Text(
                'Динамика за последнее время',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 12),

              FutureBuilder<List<MoodModel>>(
                future: _moodHistoryFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  final list = snapshot.data ?? [];
                  if (list.isEmpty) {
                    return const Text(
                      'Записей пока нет.',
                      style: TextStyle(color: AppColors.secondaryTextLight),
                    );
                  }

                  return Column(
                    children: list.map((m) {
                      final grade = _moodGrades.firstWhere(
                        (g) => g['score'] == m.score,
                        orElse: () => _moodGrades[3],
                      );
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: AppCard(
                          padding: const EdgeInsets.all(14),
                          child: Row(
                            children: [
                              Icon(
                                grade['icon'] as IconData,
                                size: 28,
                                color: grade['color'] as Color,
                              ),
                              const SizedBox(width: 14),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          grade['label'],
                                          style: const TextStyle(
                                            fontWeight: FontWeight.w700,
                                            fontSize: 14,
                                          ),
                                        ),
                                        Text(
                                          '${m.score}/5',
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            color: grade['color'] as Color,
                                          ),
                                        ),
                                      ],
                                    ),
                                    if (m.emotions.isNotEmpty) ...[
                                      const SizedBox(height: 3),
                                      Text(
                                        m.emotions.join(', '),
                                        style: const TextStyle(
                                          fontSize: 12,
                                          color: AppColors.mindcareAccent,
                                        ),
                                      ),
                                    ],
                                    if (m.note.isNotEmpty) ...[
                                      const SizedBox(height: 2),
                                      Text(
                                        m.note,
                                        style: const TextStyle(
                                          fontSize: 12,
                                          color: AppColors.secondaryTextLight,
                                        ),
                                      ),
                                    ],
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }).toList(),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
