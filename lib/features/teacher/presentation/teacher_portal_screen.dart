import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../app/theme/app_colors.dart';
import '../../../core/widgets/cards.dart';
import '../../admin/data/admin_repository.dart';
import '../../admin/domain/teacher_application.dart';
import '../../auth/data/auth_repository.dart';

class TeacherPortalScreen extends ConsumerStatefulWidget {
  const TeacherPortalScreen({super.key});

  @override
  ConsumerState<TeacherPortalScreen> createState() => _TeacherPortalScreenState();
}

class _TeacherPortalScreenState extends ConsumerState<TeacherPortalScreen> {
  final _schoolController = TextEditingController();
  final _teacherCodeController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    _schoolController.dispose();
    _teacherCodeController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(authNotifierProvider).user;
    final applications = ref.watch(adminApplicationsProvider);

    // Check if this teacher is approved in the accreditation registry
    final currentApp = applications.firstWhere(
      (a) =>
          a.email == user?.email ||
          (user?.teacherCode != null && a.teacherCode == user?.teacherCode),
      orElse: () => TeacherApplication(
        id: 'mock-curr',
        fullName: user?.name ?? 'Преподаватель',
        email: user?.email ?? '',
        school: user?.school ?? 'Назарбаев Интеллектуальная школа (ФМН)',
        city: user?.city ?? 'г. Астана',
        subject: user?.subject ?? 'Математика',
        teacherCode: user?.teacherCode ?? 'TCH-2026-AST',
        status: ApplicationStatus.approved,
        appliedAt: DateTime.now(),
      ),
    );

    final isApproved = currentApp.status == ApplicationStatus.approved;
    final isPending = currentApp.status == ApplicationStatus.pending;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Платформа Учителей • Daryn Ustaz',
          style: TextStyle(fontSize: 17, fontWeight: FontWeight.w800),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Teacher Accreditation Header Badge
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: isApproved
                      ? [AppColors.teacherAccent, AppColors.primary]
                      : [Colors.orange.shade800, Colors.deepOrange],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(18),
                boxShadow: [
                  BoxShadow(
                    color: (isApproved ? AppColors.teacherAccent : Colors.orange)
                        .withOpacity(0.3),
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
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              isApproved ? Icons.verified_rounded : Icons.pending_actions_rounded,
                              color: Colors.white,
                              size: 14,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              isApproved
                                  ? 'ВЕРИФИЦИРОВАННЫЙ ПЕДАГОГ'
                                  : 'АККРЕДИТАЦИЯ НА РАССМОТРЕНИИ',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const Spacer(),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.25),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          currentApp.teacherCode,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.8,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    currentApp.fullName,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(Icons.apartment_rounded, color: Colors.white70, size: 14),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          '${currentApp.school} (${currentApp.city})',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 2),
                  Row(
                    children: [
                      const Icon(Icons.menu_book_rounded, color: Colors.white70, size: 14),
                      const SizedBox(width: 4),
                      Text(
                        'Предмет: ${currentApp.subject}',
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            if (isPending) ...[
              // Verification Warning Card
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.warning.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.warning.withOpacity(0.4)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Row(
                      children: [
                        Icon(Icons.security_update_warning_rounded, color: AppColors.warning),
                        SizedBox(width: 8),
                        Text(
                          'Проверка принадлежности к школе',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            color: AppColors.warning,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Ваша заявка направлена Администрации образовательного округа. Мы сверяем данные преподавателя с реестром школы для предотвращения несанкционированного доступа к генераторам экзаменов.',
                      style: TextStyle(fontSize: 13, height: 1.4),
                    ),
                    const SizedBox(height: 12),
                    ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.warning,
                        foregroundColor: Colors.black87,
                      ),
                      onPressed: () {
                        // Fast test approval
                        ref.read(adminApplicationsProvider.notifier).approve(currentApp.id);
                        setState(() {});
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Статус обновлен: Одобрено Администратором!'),
                            backgroundColor: AppColors.success,
                          ),
                        );
                      },
                      icon: const Icon(Icons.verified, size: 18),
                      label: const Text('Одобрить через Админку (Тест)'),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
            ],

            // Professional Teacher Workstation
            const Text(
              'Инструменты планирования и дидактики',
              style: TextStyle(fontSize: 17, fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 12),

            _buildToolCard(
              title: 'Генератор поурочных планов (ҚМЖ / КСП)',
              description: 'Создание календарно-тематических планов по стандартам ГОСО РК и критериям Блума.',
              icon: Icons.menu_book_rounded,
              color: AppColors.teacherAccent,
              onTap: () => context.push('/teacher/lesson-generator'),
            ),
            const SizedBox(height: 12),

            _buildToolCard(
              title: 'Конструктор критериальных тестов (БЖБ / ТЖБ)',
              description: 'Формирование тестов с 4 вариантами, ключами ответов и шкалой оценивания.',
              icon: Icons.quiz_rounded,
              color: AppColors.primaryDark,
              onTap: () => context.push('/teacher/quiz-generator'),
            ),
            const SizedBox(height: 12),

            _buildToolCard(
              title: 'Объяснение сложных концепций',
              description: 'Адаптация трудных математических и естественнонаучных тем на понятный язык с метафорами.',
              icon: Icons.lightbulb_outline_rounded,
              color: AppColors.warning,
              onTap: () => context.push('/teacher/explain'),
            ),
            const SizedBox(height: 12),

            _buildToolCard(
              title: 'Архив учебных материалов',
              description: 'История ранее сгенерированных уроков, тестов и возможность повторной выгрузки.',
              icon: Icons.folder_open_rounded,
              color: AppColors.success,
              onTap: () => context.push('/teacher/history'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildToolCard({
    required String title,
    required String description,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return AppCard(
      padding: const EdgeInsets.all(16),
      onTap: onTap,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withOpacity(0.12),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(icon, color: color, size: 26),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.secondaryTextLight,
                    height: 1.35,
                  ),
                ),
              ],
            ),
          ),
          const Icon(Icons.arrow_forward_ios_rounded, size: 16, color: AppColors.secondaryTextLight),
        ],
      ),
    );
  }
}
