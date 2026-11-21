import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../app/localization/app_localizations.dart';
import '../../../app/theme/app_colors.dart';
import '../../../core/widgets/cards.dart';
import '../../auth/data/auth_repository.dart';
import '../../auth/domain/user_model.dart';

class ModulesScreen extends ConsumerWidget {
  const ModulesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authNotifierProvider).user;
    final loc = AppLocalizations(AppLanguage.fromCode(user?.language ?? 'ru'));
    final role = user?.role ?? UserRole.student;
    final isAdmin = role == UserRole.admin;
    final isTeacher = role == UserRole.teacher;

    return Scaffold(
      appBar: AppBar(title: Text(loc.tr('nav_modules'))),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            // 1. ADMIN ONLY: Only Admin Panel
            if (isAdmin) ...[
              _ModuleCategoryCard(
                title: 'Панель Администратора',
                subtitle: 'Модерация и управление платформой',
                description: 'Проверка преподавательского состава, утверждение заявок аккредитации, реестр всех пользователей и аналитика.',
                icon: Icons.admin_panel_settings_rounded,
                color: AppColors.primaryDark,
                actions: [
                  _ActionItem(
                    'Модерация заявок учителей',
                    Icons.how_to_reg_rounded,
                    () => context.push('/admin'),
                  ),
                  _ActionItem(
                    'Реестр пользователей и школ',
                    Icons.people_alt_rounded,
                    () => context.push('/admin'),
                  ),
                ],
              ),
              const SizedBox(height: 20),
            ]
            // 2. TEACHER ONLY: Only Daryn Ustaz and Дневник и поддержка
            else if (isTeacher) ...[
              // Daryn Ustaz
              _ModuleCategoryCard(
                title: loc.tr('module_teacher_title'),
                subtitle: 'Платформа верифицированных учителей',
                description: 'Аккредитованная рабочая среда преподавателя: генерация ҚМЖ, конструктор БЖБ/ТЖБ и адаптация тем.',
                icon: Icons.school_rounded,
                color: AppColors.teacherAccent,
                actions: [
                  _ActionItem(
                    'Портал преподавателя',
                    Icons.dashboard_customize_rounded,
                    () => context.push('/teacher/portal'),
                  ),
                  _ActionItem(
                    'Генератор уроков (ҚМЖ)',
                    Icons.menu_book,
                    () => context.push('/teacher/lesson-generator'),
                  ),
                  _ActionItem(
                    'Конструктор тестов (БЖБ/ТЖБ)',
                    Icons.quiz,
                    () => context.push('/teacher/quiz-generator'),
                  ),
                  _ActionItem(
                    'Объяснить сложную тему',
                    Icons.lightbulb_outline,
                    () => context.push('/teacher/explain'),
                  ),
                  _ActionItem(
                    'История материалов',
                    Icons.history,
                    () => context.push('/teacher/history'),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Дневник и поддержка
              _ModuleCategoryCard(
                title: 'Дневник и Поддержка',
                subtitle: 'Кураторство подопечных и обратная связь',
                description: 'Просмотр анонимных обращений учеников, ответы и мониторинг успеваемости учащихся.',
                icon: Icons.spa_rounded,
                color: AppColors.mindcareAccent,
                actions: [
                  _ActionItem(
                    'Анонимные обращения учеников',
                    Icons.shield_outlined,
                    () => context.push('/teacher/portal'),
                  ),
                  _ActionItem(
                    'Дневник настроения и чекины',
                    Icons.mood,
                    () => context.push('/mindcare/mood'),
                  ),
                ],
              ),
              const SizedBox(height: 20),
            ]
            // 3. STUDENTS & LEARNERS: Learning Hub, Дневник и поддержка, Inclusive AI (NO Daryn Ustaz, NO Admin Panel)
            else ...[
              // Learning Hub
              _ModuleCategoryCard(
                title: 'Интерактивное Обучение',
                subtitle: 'Учебные курсы, практика и тесты',
                description: 'Учебная программа по математике, физике, программированию и языкам с автоматической проверкой.',
                icon: Icons.menu_book_rounded,
                color: AppColors.primary,
                actions: [
                  _ActionItem(
                    'Каталог курсов',
                    Icons.auto_stories_rounded,
                    () => context.push('/learning'),
                  ),
                  _ActionItem(
                    'Тренажер тестов',
                    Icons.assignment_turned_in_rounded,
                    () => context.push('/learning'),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Дневник и поддержка
              _ModuleCategoryCard(
                title: 'Дневник и Поддержка',
                subtitle: 'Личные записи и анонимный чат с учителями',
                description: 'Приватный дневник для фиксации мыслей и тревог, а также безопасный анонимный канал связи с учителями.',
                icon: Icons.spa_rounded,
                color: AppColors.mindcareAccent,
                actions: [
                  _ActionItem(
                    'Личный дневник мыслей',
                    Icons.auto_stories_rounded,
                    () => context.push('/mindcare/diary'),
                  ),
                  _ActionItem(
                    'Анонимный чат с учителем',
                    Icons.shield_outlined,
                    () => context.push('/mindcare/anonymous-chat'),
                  ),
                  _ActionItem(
                    'Дневник настроения',
                    Icons.mood,
                    () => context.push('/mindcare/mood'),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Inclusive AI
              _ModuleCategoryCard(
                title: loc.tr('module_inclusive_title'),
                subtitle: loc.tr('module_inclusive_sub'),
                description: loc.tr('module_inclusive_desc'),
                icon: Icons.accessibility_new_rounded,
                color: AppColors.inclusiveAccent,
                actions: [
                  _ActionItem(
                    'AI Simplifier (Упрощение)',
                    Icons.auto_stories,
                    () => context.push('/inclusive/simplifier'),
                  ),
                  _ActionItem(
                    'Голосовой ввод (STT)',
                    Icons.mic,
                    () => context.push('/inclusive/voice'),
                  ),
                  _ActionItem(
                    'Специальные возможности',
                    Icons.tune,
                    () => context.push('/inclusive/accessibility'),
                  ),
                ],
              ),
              const SizedBox(height: 20),
            ],
          ],
        ),
      ),
    );
  }
}

class _ActionItem {
  final String label;
  final IconData icon;
  final VoidCallback onTap;
  _ActionItem(this.label, this.icon, this.onTap);
}

class _ModuleCategoryCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final String description;
  final IconData icon;
  final Color color;
  final List<_ActionItem> actions;

  const _ModuleCategoryCard({
    required this.title,
    required this.subtitle,
    required this.description,
    required this.icon,
    required this.color,
    required this.actions,
  });

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
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
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: color,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            description,
            style: const TextStyle(
              fontSize: 12,
              color: AppColors.secondaryTextLight,
              height: 1.35,
            ),
          ),
          const SizedBox(height: 14),
          const Divider(height: 1),
          const SizedBox(height: 8),
          ...actions.map(
            (action) => ListTile(
              dense: true,
              contentPadding: EdgeInsets.zero,
              leading: Icon(action.icon, size: 20, color: color),
              title: Text(
                action.label,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
              trailing: const Icon(
                Icons.arrow_forward_ios_rounded,
                size: 14,
                color: AppColors.secondaryTextLight,
              ),
              onTap: action.onTap,
            ),
          ),
        ],
      ),
    );
  }
}
