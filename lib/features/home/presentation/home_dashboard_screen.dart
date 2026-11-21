import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../app/localization/app_localizations.dart';
import '../../../app/theme/app_colors.dart';
import '../../../core/widgets/cards.dart';
import '../../auth/data/auth_repository.dart';
import '../../auth/domain/user_model.dart';
import '../../gamification/data/gamification_repository.dart';

class HomeDashboardScreen extends ConsumerWidget {
  const HomeDashboardScreen({super.key});

  String _getGreeting(AppLocalizations loc) {
    final hour = DateTime.now().hour;
    if (hour < 12) return loc.tr('greeting_morning');
    if (hour < 18) return loc.tr('greeting_day');
    return loc.tr('greeting_evening');
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authNotifierProvider).user;
    final loc = AppLocalizations(AppLanguage.fromCode(user?.language ?? 'ru'));
    final gamification = ref.watch(gamificationProvider);
    final currentStreak = gamification.streak.currentStreak;
    final totalXp = gamification.streak.totalXp;

    final userName = user?.name ?? 'Пользователь';
    final role = user?.role ?? UserRole.student;

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Top Header with User, Avatar, and Notification Bell
              Row(
                children: [
                  CircleAvatar(
                    radius: 22,
                    backgroundColor: AppColors.primaryLight,
                    child: Text(
                      userName.isNotEmpty ? userName[0].toUpperCase() : 'U',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Flexible(
                              child: Text(
                                '${_getGreeting(loc)}, $userName!',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  fontSize: 17,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                            if (user?.role == UserRole.teacher && user?.school != null) ...[
                              const SizedBox(width: 6),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(
                                  color: AppColors.teacherAccent.withOpacity(0.15),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Text(
                                  user!.teacherCode ?? 'TCH',
                                  style: const TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.teacherAccent,
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),
                        Text(
                          role.title,
                          style: const TextStyle(
                            fontSize: 12,
                            color: AppColors.secondaryTextLight,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: () => context.push('/notifications'),
                    icon: Stack(
                      children: [
                        const Icon(Icons.notifications_none_rounded, size: 26),
                        Positioned(
                          right: 2,
                          top: 2,
                          child: Container(
                            width: 8,
                            height: 8,
                            decoration: const BoxDecoration(
                              color: AppColors.error,
                              shape: BoxShape.circle,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),

              if (role == UserRole.student) ...[
                // Gamification Quick Bar (Streak & XP - Students only)
                InkWell(
                  onTap: () => context.push('/achievements'),
                  borderRadius: BorderRadius.circular(16),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                    decoration: BoxDecoration(
                      color: Theme.of(context).cardColor,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppColors.dividerLight),
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: const Color(0xFFE8590C).withOpacity(0.12),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.local_fire_department_rounded, color: Color(0xFFE8590C), size: 16),
                              const SizedBox(width: 4),
                              Text(
                                '$currentStreak ${currentStreak == 1 ? "день" : "дня"} стрик',
                                style: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w800,
                                  color: Color(0xFFE8590C),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: AppColors.primary.withOpacity(0.12),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.bolt_rounded, color: AppColors.primary, size: 16),
                              const SizedBox(width: 4),
                              Text(
                                '$totalXp XP',
                                style: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w800,
                                  color: AppColors.primary,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const Spacer(),
                        const Text(
                          'Награды',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: AppColors.primary,
                          ),
                        ),
                        const SizedBox(width: 2),
                        const Icon(Icons.chevron_right_rounded, size: 18, color: AppColors.primary),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 14),
              ],

              // Large Hero Card: EduMind AI
              Container(
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [AppColors.primaryDark, AppColors.primary],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(22),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary.withOpacity(0.3),
                      blurRadius: 18,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                padding: const EdgeInsets.all(22),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.auto_awesome,
                                color: Colors.white,
                                size: 14,
                              ),
                              SizedBox(width: 4),
                              Text(
                                'AI ECOSYSTEM',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 10,
                                  fontWeight: FontWeight.w700,
                                  letterSpacing: 0.8,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const Spacer(),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 3,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.18),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            role == UserRole.admin ? 'АДМИНИСТРАТОР' : (role == UserRole.teacher ? 'ПРЕПОДАВАТЕЛЬ' : 'ОБУЧЕНИЕ'),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    const Text(
                      'EduMind AI',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.w800,
                        letterSpacing: -0.3,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      role == UserRole.admin
                          ? 'Центр аккредитации школ, верификации педагогов и управления пользователями платформы.'
                          : (role == UserRole.teacher
                              ? 'Интеллектуальный помощник преподавателя: создавайте планы занятий и тесты в 1 клик.'
                              : (role == UserRole.learner
                                    ? 'Адаптивное инклюзивное пространство: озвучивание, крупный текст и упрощение тем.'
                                    : 'Ваш образовательный проводник и безопасная эмоциональная поддержка MindCare.')),
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.9),
                        fontSize: 13,
                        height: 1.4,
                      ),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: AppColors.primaryDark,
                        minimumSize: const Size(0, 42),
                        padding: const EdgeInsets.symmetric(horizontal: 18),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onPressed: () => context.push(role == UserRole.admin ? '/admin' : '/assistant'),
                      icon: Icon(role == UserRole.admin ? Icons.admin_panel_settings_rounded : Icons.chat_bubble_outline, size: 18),
                      label: Text(
                        role == UserRole.admin ? 'Открыть Панель Администратора' : 'Открыть AI Ассистент',
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 22),

              // ROLE-ADAPTED SECTIONS
              if (role == UserRole.admin) ...[
                _buildAdminSection(context, loc),
              ] else if (role == UserRole.teacher) ...[
                _buildTeacherSection(context, loc),
              ] else if (role == UserRole.learner) ...[
                _buildLearnerSection(context, loc),
              ] else ...[
                _buildStudentSection(context, loc, currentStreak),
              ],

              const SizedBox(height: 24),

              // CORE MODULES SECTION
              Text(
                loc.tr('nav_modules'),
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 12),

              if (role == UserRole.admin) ...[
                // Admin Modules (No student clutter)
                _ModuleNavCard(
                  title: 'Панель Модерации',
                  subtitle: 'Заявки учителей на верификацию',
                  description: 'Проверка преподавательского состава, утверждение или отклонение заявок аккредитации.',
                  icon: Icons.admin_panel_settings_rounded,
                  color: AppColors.primaryDark,
                  badgeText: 'Модерация',
                  onTap: () => context.push('/admin'),
                ),
                const SizedBox(height: 12),

                _ModuleNavCard(
                  title: 'Реестр Пользователей',
                  subtitle: 'Все зарегистрированные аккаунты',
                  description: 'Полный мониторинг учеников, учителей и администраторов с их ролями и статусами.',
                  icon: Icons.people_alt_rounded,
                  color: AppColors.primary,
                  badgeText: 'Пользователи',
                  onTap: () => context.push('/admin'),
                ),
                const SizedBox(height: 12),

                _ModuleNavCard(
                  title: 'Daryn Ustaz (Аудит)',
                  subtitle: 'Методические материалы педагогов',
                  description: 'Просмотр сгенерированных поурочных планов ҚМЖ и тестов БЖБ/ТЖБ.',
                  icon: Icons.school_rounded,
                  color: AppColors.teacherAccent,
                  badgeText: 'Учителям',
                  onTap: () => context.push('/teacher/portal'),
                ),
              ] else ...[
                // Student & Teacher Standard Modules
                if (role == UserRole.student) ...[
                  _ModuleNavCard(
                    title: 'Интерактивное Обучение',
                    subtitle: 'Учебные курсы и тренажеры знаний',
                    description: 'Алгебра, Python, Физика и Английский язык с практическими заданиями и AI Тьютором.',
                    icon: Icons.menu_book_rounded,
                    color: AppColors.primary,
                    badgeText: 'Обучение & Тесты',
                    onTap: () => context.push('/learning'),
                  ),
                  const SizedBox(height: 12),
                ],

                if (role == UserRole.teacher) ...[
                  _ModuleNavCard(
                    title: loc.tr('module_teacher_title'),
                    subtitle: 'Платформа верифицированных учителей',
                    description: 'Поурочные планы ҚМЖ, конструктор тестов БЖБ/ТЖБ и проверка школ.',
                    icon: Icons.school_rounded,
                    color: AppColors.teacherAccent,
                    badgeText: 'Преподавателям',
                    onTap: () => context.push('/teacher/portal'),
                  ),
                  const SizedBox(height: 12),
                ],

                // MindCare Card
                _ModuleNavCard(
                  title: loc.tr('module_mindcare_title'),
                  subtitle: loc.tr('module_mindcare_sub'),
                  description: loc.tr('module_mindcare_desc'),
                  icon: Icons.spa_rounded,
                  color: AppColors.mindcareAccent,
                  badgeText: 'Поддержка & Mood',
                  onTap: () => context.push('/mindcare/chat'),
                ),
                const SizedBox(height: 12),

                // Inclusive AI Card
                _ModuleNavCard(
                  title: loc.tr('module_inclusive_title'),
                  subtitle: loc.tr('module_inclusive_sub'),
                  description: loc.tr('module_inclusive_desc'),
                  icon: Icons.accessibility_new_rounded,
                  color: AppColors.inclusiveAccent,
                  badgeText: 'Адаптивность & TTS',
                  onTap: () => context.push('/inclusive/simplifier'),
                ),
              ],

              const SizedBox(height: 28),
            ],
          ),
        ),
      ),
    );
  }

  // Admin Specific Dashboard Section
  Widget _buildAdminSection(BuildContext context, AppLocalizations loc) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Управление аккредитацией и модерация',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
            ),
            TextButton(
              onPressed: () => context.push('/admin'),
              child: const Text(
                'Панель админа',
                style: TextStyle(fontSize: 12, color: AppColors.primaryDark, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        AppCard(
          padding: const EdgeInsets.all(16),
          color: AppColors.primaryDark.withOpacity(0.08),
          border: Border.all(color: AppColors.primaryDark.withOpacity(0.3)),
          onTap: () => context.push('/admin'),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.primaryDark,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Icon(
                  Icons.admin_panel_settings_rounded,
                  color: Colors.white,
                  size: 28,
                ),
              ),
              const SizedBox(width: 14),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Заявки учителей на верификацию',
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 14,
                      ),
                    ),
                    SizedBox(height: 2),
                    Text(
                      'Проверяйте принадлежность педагогов к школам и утверждайте доступ',
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.secondaryTextLight,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(
                Icons.arrow_forward_ios_rounded,
                size: 16,
                color: AppColors.primaryDark,
              ),
            ],
          ),
        ),
      ],
    );
  }

  // Teacher Specific Dashboard Section
  Widget _buildTeacherSection(BuildContext context, AppLocalizations loc) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Инструменты преподавателя',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
            ),
            TextButton(
              onPressed: () => context.push('/teacher/history'),
              child: const Text(
                'Все материалы',
                style: TextStyle(fontSize: 12, color: AppColors.primary),
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(
              child: _QuickActionCard(
                title: 'Генератор уроков',
                icon: Icons.menu_book_rounded,
                color: AppColors.teacherAccent,
                onTap: () => context.push('/teacher/lesson-generator'),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _QuickActionCard(
                title: 'Конструктор тестов',
                icon: Icons.quiz_rounded,
                color: AppColors.primaryDark,
                onTap: () => context.push('/teacher/quiz-generator'),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _QuickActionCard(
                title: 'Объяснить тему',
                icon: Icons.lightbulb_outline_rounded,
                color: AppColors.warning,
                onTap: () => context.push('/teacher/explain'),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _QuickActionCard(
                title: 'История материалов',
                icon: Icons.folder_open_rounded,
                color: AppColors.success,
                onTap: () => context.push('/teacher/history'),
              ),
            ),
          ],
        ),
      ],
    );
  }

  // Student Specific Dashboard Section
  Widget _buildStudentSection(
    BuildContext context,
    AppLocalizations loc,
    int currentStreak,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Streak Challenge Card
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Ударный режим и цель дня',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
            ),
            TextButton(
              onPressed: () => context.push('/achievements'),
              child: const Text(
                'Все награды',
                style: TextStyle(
                  fontSize: 12,
                  color: AppColors.primary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        AppCard(
          padding: const EdgeInsets.all(16),
          onTap: () => context.push('/achievements'),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.warning.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Icon(
                  Icons.local_fire_department_rounded,
                  color: AppColors.warning,
                  size: 26,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '$currentStreak ${currentStreak == 1 ? "день" : "дня"} непрерывного обучения',
                      style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 2),
                    const Text(
                      'Решите 1 задачу сегодня, чтобы получить +50 XP и сохранить стрик',
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.secondaryTextLight,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(
                Icons.arrow_forward_ios_rounded,
                size: 16,
                color: AppColors.primary,
              ),
            ],
          ),
        ),
        const SizedBox(height: 18),

        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Эмоциональное самочувствие',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
            ),
            TextButton(
              onPressed: () => context.push('/mindcare/mood'),
              child: const Text(
                'Дневник',
                style: TextStyle(fontSize: 12, color: AppColors.mindcareAccent),
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        AppCard(
          padding: const EdgeInsets.all(16),
          color: AppColors.mindcareAccent.withOpacity(0.08),
          border: Border.all(color: AppColors.mindcareAccent.withOpacity(0.3)),
          onTap: () => context.push('/mindcare/mood'),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.mindcareAccent,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Icon(
                  Icons.mood_rounded,
                  color: Colors.white,
                  size: 28,
                ),
              ),
              const SizedBox(width: 14),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Как ваше настроение сегодня?',
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 14,
                      ),
                    ),
                    SizedBox(height: 2),
                    Text(
                      'Отметьте настроение и отслеживайте динамику за неделю',
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.secondaryTextLight,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(
                Icons.arrow_forward_ios_rounded,
                size: 16,
                color: AppColors.mindcareAccent,
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _QuickActionCard(
                title: 'MindCare Чат',
                icon: Icons.support_agent_rounded,
                color: AppColors.mindcareAccent,
                onTap: () => context.push('/mindcare/chat'),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _QuickActionCard(
                title: 'Дыхание 4-7-8',
                icon: Icons.air_rounded,
                color: AppColors.primary,
                onTap: () => context.push('/mindcare/exercises'),
              ),
            ),
          ],
        ),
      ],
    );
  }

  // Learner (Inclusive) Specific Dashboard Section
  Widget _buildLearnerSection(BuildContext context, AppLocalizations loc) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Адаптивные инструменты',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
            ),
            TextButton(
              onPressed: () => context.push('/inclusive/accessibility'),
              child: const Text(
                'Настройки доступности',
                style: TextStyle(
                  fontSize: 12,
                  color: AppColors.inclusiveAccent,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(
              child: _QuickActionCard(
                title: 'AI Simplifier',
                icon: Icons.auto_stories_rounded,
                color: AppColors.inclusiveAccent,
                onTap: () => context.push('/inclusive/simplifier'),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _QuickActionCard(
                title: 'Голосовой ввод (STT)',
                icon: Icons.mic_rounded,
                color: AppColors.primary,
                onTap: () => context.push('/inclusive/voice'),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        AppCard(
          padding: const EdgeInsets.all(16),
          color: AppColors.inclusiveAccent.withOpacity(0.08),
          border: Border.all(color: AppColors.inclusiveAccent.withOpacity(0.3)),
          onTap: () => context.push('/inclusive/accessibility'),
          child: const Row(
            children: [
              Icon(
                Icons.tune_rounded,
                color: AppColors.inclusiveAccent,
                size: 28,
              ),
              SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Специальные возможности',
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 14,
                      ),
                    ),
                    SizedBox(height: 2),
                    Text(
                      'Крупный шрифт, высокий контраст, озвучивание',
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.secondaryTextLight,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.arrow_forward_ios_rounded,
                size: 16,
                color: AppColors.inclusiveAccent,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _QuickActionCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _QuickActionCard({
    required this.title,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 16),
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withOpacity(0.12),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 22),
          ),
          const SizedBox(height: 12),
          Text(
            title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
          ),
        ],
      ),
    );
  }
}

class _ModuleNavCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final String description;
  final IconData icon;
  final Color color;
  final String badgeText;
  final VoidCallback onTap;

  const _ModuleNavCard({
    required this.title,
    required this.subtitle,
    required this.description,
    required this.icon,
    required this.color,
    required this.badgeText,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: const EdgeInsets.all(18),
      onTap: onTap,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withOpacity(0.12),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(icon, color: color, size: 28),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: color.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        badgeText,
                        style: TextStyle(
                          fontSize: 9,
                          fontWeight: FontWeight.w700,
                          color: color,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: color,
                  ),
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
          const SizedBox(width: 8),
          const Icon(
            Icons.arrow_forward_ios_rounded,
            size: 14,
            color: AppColors.secondaryTextLight,
          ),
        ],
      ),
    );
  }
}
