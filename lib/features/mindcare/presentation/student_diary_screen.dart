import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../app/theme/app_colors.dart';
import '../../../core/widgets/buttons.dart';
import '../../../core/widgets/cards.dart';
import '../../../core/widgets/inputs.dart';
import '../data/student_diary_repository.dart';
import '../domain/student_diary_model.dart';

class StudentDiaryScreen extends ConsumerStatefulWidget {
  const StudentDiaryScreen({super.key});

  @override
  ConsumerState<StudentDiaryScreen> createState() => _StudentDiaryScreenState();
}

class _StudentDiaryScreenState extends ConsumerState<StudentDiaryScreen> {
  final _titleController = TextEditingController();
  final _contentController = TextEditingController();
  String _selectedCategory = 'Переживания';
  int _selectedMood = 4;
  bool _isLoading = false;

  final List<String> _categories = [
    'Переживания',
    'Учеба',
    'Оценки',
    'Стресс',
    'Победа дня',
    'Личные мысли',
  ];

  final List<Map<String, dynamic>> _moodEmojis = [
    {'score': 1, 'emoji': '😞', 'label': 'Тяжело'},
    {'score': 2, 'emoji': '🙁', 'label': 'Тревожно'},
    {'score': 3, 'emoji': '😐', 'label': 'Обычно'},
    {'score': 4, 'emoji': '🙂', 'label': 'Хорошо'},
    {'score': 5, 'emoji': '😄', 'label': 'Отлично'},
  ];

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  Future<void> _saveEntry() async {
    final content = _contentController.text.trim();
    if (content.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Пожалуйста, напишите ваши мысли перед сохранением')),
      );
      return;
    }

    setState(() => _isLoading = true);
    await ref.read(studentDiaryProvider.notifier).addEntry(
          title: _titleController.text.trim(),
          content: content,
          category: _selectedCategory,
          moodScore: _selectedMood,
        );

    _titleController.clear();
    _contentController.clear();
    setState(() => _isLoading = false);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Запись сохранена в вашем личном дневнике!'),
          backgroundColor: AppColors.success,
        ),
      );
    }
  }

  void _confirmDelete(String id) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Удалить запись?'),
        content: const Text('Эта мысль будет безвозвратно удалена из дневника.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Отмена'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
            onPressed: () {
              ref.read(studentDiaryProvider.notifier).deleteEntry(id);
              Navigator.pop(ctx);
            },
            child: const Text('Удалить', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final entries = ref.watch(studentDiaryProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Личный дневник мыслей',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            Text(
              'Безопасное пространство для ваших переживаний и идей',
              style: TextStyle(fontSize: 11, color: AppColors.secondaryTextLight),
            ),
          ],
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Composer Box
            AppCard(
              padding: const EdgeInsets.all(18),
              border: Border.all(color: AppColors.primary.withOpacity(0.3)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    children: [
                      Icon(Icons.edit_note_rounded, color: AppColors.primary, size: 22),
                      SizedBox(width: 8),
                      Text(
                        'Что вас сейчас беспокоит или радует?',
                        style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  // Mood Selector
                  const Text(
                    'Ваше состояние сейчас:',
                    style: TextStyle(fontSize: 12, color: AppColors.secondaryTextLight),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: _moodEmojis.map((m) {
                      final isSelected = m['score'] == _selectedMood;
                      return GestureDetector(
                        onTap: () => setState(() => _selectedMood = m['score'] as int),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? AppColors.primary.withOpacity(0.15)
                                : Colors.transparent,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: isSelected
                                  ? AppColors.primary
                                  : Colors.grey.withOpacity(0.2),
                              width: isSelected ? 1.5 : 1,
                            ),
                          ),
                          child: Column(
                            children: [
                              Text(m['emoji'] as String, style: const TextStyle(fontSize: 22)),
                              const SizedBox(height: 2),
                              Text(
                                m['label'] as String,
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 14),

                  // Category Selector
                  const Text(
                    'Тема записи:',
                    style: TextStyle(fontSize: 12, color: AppColors.secondaryTextLight),
                  ),
                  const SizedBox(height: 6),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: _categories.map((c) {
                        final isSelected = c == _selectedCategory;
                        return Padding(
                          padding: const EdgeInsets.only(right: 6),
                          child: ChoiceChip(
                            label: Text(c, style: const TextStyle(fontSize: 11)),
                            selected: isSelected,
                            selectedColor: AppColors.primary.withOpacity(0.2),
                            onSelected: (_) => setState(() => _selectedCategory = c),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                  const SizedBox(height: 14),

                  CustomTextField(
                    controller: _titleController,
                    label: 'Тема записи',
                    hint: 'Например: Мысли о СОР по алгебре или усталость',
                  ),
                  const SizedBox(height: 10),

                  CustomTextField(
                    controller: _contentController,
                    label: 'Текст записи',
                    hint: 'Запишите свободно всё, что на душе... Никто, кроме вас, не увидит эту запись.',
                    maxLines: 4,
                  ),
                  const SizedBox(height: 14),

                  PrimaryButton(
                    text: 'Сохранить запись в дневник',
                    icon: Icons.bookmark_add_rounded,
                    isLoading: _isLoading,
                    onPressed: _saveEntry,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Entries List
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Мои сохраненные мысли',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                Text(
                  '${entries.length} записей',
                  style: const TextStyle(fontSize: 12, color: AppColors.secondaryTextLight),
                ),
              ],
            ),
            const SizedBox(height: 12),

            if (entries.isEmpty)
              Container(
                padding: const EdgeInsets.all(28),
                alignment: Alignment.center,
                child: Column(
                  children: [
                    Icon(Icons.auto_stories_outlined, size: 48, color: Colors.grey.withOpacity(0.35)),
                    const SizedBox(height: 10),
                    const Text(
                      'Дневник пока пуст. Запишите сюда первую мысль или тревогу, чтобы стало легче.',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 12, color: AppColors.secondaryTextLight),
                    ),
                  ],
                ),
              )
            else
              ...entries.map((entry) => _buildEntryCard(entry)),
          ],
        ),
      ),
    );
  }

  Widget _buildEntryCard(StudentDiaryEntryModel entry) {
    final emoji = _moodEmojis.firstWhere(
      (m) => m['score'] == entry.moodScore,
      orElse: () => {'emoji': '🙂', 'label': 'Хорошо'},
    )['emoji'];

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: AppCard(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Text(emoji as String, style: const TextStyle(fontSize: 20)),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        entry.category,
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primary,
                        ),
                      ),
                    ),
                  ],
                ),
                Row(
                  children: [
                    Text(
                      '${entry.createdAt.day}.${entry.createdAt.month}.${entry.createdAt.year}',
                      style: const TextStyle(fontSize: 11, color: AppColors.secondaryTextLight),
                    ),
                    const SizedBox(width: 4),
                    IconButton(
                      icon: const Icon(Icons.delete_outline_rounded, size: 18, color: AppColors.error),
                      onPressed: () => _confirmDelete(entry.id),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              entry.title,
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 6),
            Text(
              entry.content,
              style: const TextStyle(fontSize: 13, height: 1.45),
            ),
          ],
        ),
      ),
    );
  }
}
