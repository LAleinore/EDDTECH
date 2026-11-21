import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../app/theme/app_colors.dart';
import '../../../core/widgets/cards.dart';

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final notifications = [
      {
        'title': 'Внимание: стрик может сгореть!',
        'desc':
            'Вы еще не занимались сегодня. Решите хотя бы 1 задачу до конца дня, чтобы защитить серию и получить +50 XP.',
        'time': '2 часа назад',
        'icon': Icons.local_fire_department_rounded,
        'color': const Color(0xFFE8590C),
        'route': '/learning',
        'isUnread': true,
      },
      {
        'title': 'Новая тема: Квадратные уравнения и теорема Виета',
        'desc':
            'В модуле «Алгебра» открыт доступ к новому практическому уроку с экспресс-тестом и подсказками AI Тьютора.',
        'time': 'Сегодня, 10:15',
        'icon': Icons.calculate_rounded,
        'color': AppColors.primary,
        'route': '/learning',
        'isUnread': true,
      },
      {
        'title': 'Практикум: Алгоритмы и функции на Python',
        'desc':
            'Доступны 5 практических задач по программированию. Проверьте свой код в интерактивном тренажере.',
        'time': 'Вчера',
        'icon': Icons.code_rounded,
        'color': AppColors.teacherAccent,
        'route': '/learning',
        'isUnread': false,
      },
      {
        'title': 'Подъём в рейтинге учеников!',
        'desc':
            'Поздравляем! За решение задач вы получили дополнительные XP и поднялись в таблице лидеров.',
        'time': 'Вчера',
        'icon': Icons.trending_up_rounded,
        'color': AppColors.success,
        'route': '/achievements',
        'isUnread': false,
      },
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Уведомления',
          style: TextStyle(fontWeight: FontWeight.w700),
        ),
      ),
      body: SafeArea(
        child: ListView.separated(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          itemCount: notifications.length,
          separatorBuilder: (_, __) => const SizedBox(height: 12),
          itemBuilder: (context, index) {
            final item = notifications[index];
            final isUnread = item['isUnread'] as bool? ?? false;

            return AppCard(
              padding: const EdgeInsets.all(16),
              color: isUnread ? (item['color'] as Color).withOpacity(0.04) : null,
              border: isUnread
                  ? Border.all(color: (item['color'] as Color).withOpacity(0.3), width: 1.2)
                  : null,
              onTap: () => context.push(item['route'] as String),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: (item['color'] as Color).withOpacity(0.12),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      item['icon'] as IconData,
                      color: item['color'] as Color,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                item['title'] as String,
                                style: TextStyle(
                                  fontWeight: isUnread ? FontWeight.w800 : FontWeight.w700,
                                  fontSize: 14,
                                ),
                              ),
                            ),
                            if (isUnread) ...[
                              const SizedBox(width: 6),
                              Container(
                                width: 8,
                                height: 8,
                                decoration: BoxDecoration(
                                  color: item['color'] as Color,
                                  shape: BoxShape.circle,
                                ),
                              ),
                            ],
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          item['desc'] as String,
                          style: const TextStyle(
                            fontSize: 12,
                            color: AppColors.secondaryTextLight,
                            height: 1.35,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          item['time'] as String,
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w500,
                            color: isUnread ? (item['color'] as Color) : AppColors.secondaryTextLight,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
