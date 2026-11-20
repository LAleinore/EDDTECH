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
        'title': 'Daryn Ustaz готов к работе',
        'desc': 'Сгенерируйте поурочный план или тест для любого класса.',
        'time': '10 мин назад',
        'icon': Icons.school,
        'color': AppColors.teacherAccent,
        'route': '/teacher/lesson-generator',
      },
      {
        'title': 'MindCare: время для чекина',
        'desc': 'Как вы чувствуете себя сегодня? Зафиксируйте настроение.',
        'time': '1 час назад',
        'icon': Icons.spa,
        'color': AppColors.mindcareAccent,
        'route': '/mindcare/mood',
      },
      {
        'title': 'Специальные возможности активированы',
        'desc':
            'Настройки контрастности и озвучивания применены ко всем экранам.',
        'time': 'Вчера',
        'icon': Icons.accessibility_new,
        'color': AppColors.inclusiveAccent,
        'route': '/inclusive/accessibility',
      },
    ];

    return Scaffold(
      appBar: AppBar(title: const Text('Уведомления')),
      body: SafeArea(
        child: ListView.separated(
          padding: const EdgeInsets.all(20),
          itemCount: notifications.length,
          separatorBuilder: (_, __) => const SizedBox(height: 12),
          itemBuilder: (context, index) {
            final item = notifications[index];
            return AppCard(
              padding: const EdgeInsets.all(16),
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
                      size: 22,
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item['title'] as String,
                          style: const TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          item['desc'] as String,
                          style: const TextStyle(
                            fontSize: 12,
                            color: AppColors.secondaryTextLight,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          item['time'] as String,
                          style: const TextStyle(
                            fontSize: 10,
                            color: AppColors.secondaryTextLight,
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
