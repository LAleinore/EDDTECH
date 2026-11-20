import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../app/theme/app_colors.dart';
import '../../../core/widgets/cards.dart';
import '../data/teacher_repository.dart';
import '../domain/material_model.dart';

class MaterialsHistoryScreen extends ConsumerStatefulWidget {
  const MaterialsHistoryScreen({super.key});

  @override
  ConsumerState<MaterialsHistoryScreen> createState() =>
      _MaterialsHistoryScreenState();
}

class _MaterialsHistoryScreenState
    extends ConsumerState<MaterialsHistoryScreen> {
  late Future<List<MaterialItemModel>> _historyFuture;

  @override
  void initState() {
    super.initState();
    _load();
  }

  void _load() {
    _historyFuture = ref.read(teacherRepositoryProvider).getHistory();
  }

  Future<void> _delete(String id) async {
    await ref.read(teacherRepositoryProvider).deleteMaterial(id);
    setState(() {
      _load();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('История материалов')),
      body: SafeArea(
        child: FutureBuilder<List<MaterialItemModel>>(
          future: _historyFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            final items = snapshot.data ?? [];
            if (items.isEmpty) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.folder_open_rounded,
                        size: 64,
                        color: AppColors.secondaryTextLight,
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'Нет сохраненных материалов',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 6),
                      const Text(
                        'Сгенерируйте поурочный план или тест, чтобы они появились здесь.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 13,
                          color: AppColors.secondaryTextLight,
                        ),
                      ),
                      const SizedBox(height: 20),
                      ElevatedButton(
                        onPressed: () =>
                            context.push('/teacher/lesson-generator'),
                        child: const Text('Создать урок'),
                      ),
                    ],
                  ),
                ),
              );
            }

            return ListView.separated(
              padding: const EdgeInsets.all(20),
              itemCount: items.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final item = items[index];
                final isQuiz = item.materialType == 'quiz';

                return AppCard(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color:
                              (isQuiz
                                      ? AppColors.primaryDark
                                      : AppColors.teacherAccent)
                                  .withOpacity(0.12),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(
                          isQuiz ? Icons.quiz_rounded : Icons.menu_book_rounded,
                          color: isQuiz
                              ? AppColors.primaryDark
                              : AppColors.teacherAccent,
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              item.title,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontWeight: FontWeight.w700,
                                fontSize: 14,
                              ),
                            ),
                            const SizedBox(height: 3),
                            Text(
                              '${item.subject} • ${item.grade} класс',
                              style: const TextStyle(
                                fontSize: 12,
                                color: AppColors.secondaryTextLight,
                              ),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        icon: const Icon(
                          Icons.delete_outline_rounded,
                          color: AppColors.error,
                          size: 20,
                        ),
                        onPressed: () => _delete(item.id),
                      ),
                    ],
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}
