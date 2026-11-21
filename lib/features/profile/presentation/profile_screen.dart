import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../app/localization/app_localizations.dart';
import '../../../app/theme/app_colors.dart';
import '../../../app/theme/theme_provider.dart';
import '../../../core/widgets/buttons.dart';
import '../../../core/widgets/cards.dart';
import '../../auth/data/auth_repository.dart';
import '../../auth/domain/user_model.dart';
import '../../gamification/data/gamification_repository.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authNotifierProvider).user;
    final loc = AppLocalizations(AppLanguage.fromCode(user?.language ?? 'ru'));
    final authNotifier = ref.read(authNotifierProvider.notifier);
    final isDark = ref.watch(themeProvider);
    final gamification = ref.watch(gamificationProvider);
    final streak = gamification.streak;

    return Scaffold(
      appBar: AppBar(title: Text(loc.tr('profile'))),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            // User Avatar Card
            Center(
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 40,
                    backgroundColor: AppColors.primaryLight,
                    child: Text(
                      user?.name.isNotEmpty == true
                          ? user!.name[0].toUpperCase()
                          : 'U',
                      style: const TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Flexible(
                        child: Text(
                          user?.name ?? 'Пользователь',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.edit_outlined, size: 18, color: AppColors.primary),
                        tooltip: 'Изменить имя и данные',
                        onPressed: () => _showEditProfileDialog(context, ref, user),
                      ),
                    ],
                  ),
                  if (user?.school != null && user!.school!.isNotEmpty) ...[
                    Text(
                      user.school!,
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.secondaryTextLight,
                      ),
                    ),
                    const SizedBox(height: 4),
                  ],
                  Text(
                    user?.email ?? '',
                    style: const TextStyle(
                      fontSize: 13,
                      color: AppColors.secondaryTextLight,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 3,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      user?.role.title ?? '',
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            if (user?.role == UserRole.student) ...[
              // Gamification & Streak Stats Card (Students only)
              InkWell(
                onTap: () => context.push('/achievements'),
                borderRadius: BorderRadius.circular(16),
                child: AppCard(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      Column(
                        children: [
                          Row(
                            children: [
                              const Icon(Icons.local_fire_department_rounded, color: Color(0xFFE8590C), size: 20),
                              const SizedBox(width: 4),
                              Text(
                                '${streak.currentStreak} ${streak.currentStreak == 1 ? "день" : "дня"}',
                                style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16),
                              ),
                            ],
                          ),
                          const SizedBox(height: 2),
                          const Text(
                            'Стрик',
                            style: TextStyle(fontSize: 12, color: AppColors.secondaryTextLight),
                          ),
                        ],
                      ),
                      Container(height: 32, width: 1, color: AppColors.dividerLight),
                      Column(
                        children: [
                          Row(
                            children: [
                              const Icon(Icons.bolt_rounded, color: AppColors.primary, size: 20),
                              const SizedBox(width: 4),
                              Text(
                                '${streak.totalXp}',
                                style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16),
                              ),
                            ],
                          ),
                          const SizedBox(height: 2),
                          const Text(
                            'Очки XP',
                            style: TextStyle(fontSize: 12, color: AppColors.secondaryTextLight),
                          ),
                        ],
                      ),
                      Container(height: 32, width: 1, color: AppColors.dividerLight),
                      Column(
                        children: [
                          Row(
                            children: [
                              const Icon(Icons.military_tech_rounded, color: AppColors.warning, size: 20),
                              const SizedBox(width: 4),
                              Text(
                                'Ур. ${streak.level}',
                                style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16),
                              ),
                            ],
                          ),
                          const SizedBox(height: 2),
                          const Text(
                            'Уровень',
                            style: TextStyle(fontSize: 12, color: AppColors.secondaryTextLight),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),
            ] else if (user?.role == UserRole.admin) ...[
              AppCard(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                color: AppColors.primaryDark.withOpacity(0.08),
                border: Border.all(color: AppColors.primaryDark.withOpacity(0.25)),
                child: const Row(
                  children: [
                    Icon(Icons.security_rounded, color: AppColors.primaryDark, size: 24),
                    SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Права: Главный Администратор платформы',
                            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: AppColors.primaryDark),
                          ),
                          SizedBox(height: 2),
                          Text(
                            'Модерация заявок учителей, аккредитация школ и реестр пользователей.',
                            style: TextStyle(fontSize: 11, color: AppColors.secondaryTextLight),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
            ],

            // Language Selector Card
            AppCard(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    loc.tr('language'),
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      _LangChip(
                        code: 'ru',
                        title: 'Русский',
                        isSelected: (user?.language ?? 'ru') == 'ru',
                        onTap: () => authNotifier.updateProfile(language: 'ru'),
                      ),
                      const SizedBox(width: 8),
                      _LangChip(
                        code: 'kk',
                        title: 'Қазақша',
                        isSelected: user?.language == 'kk',
                        onTap: () => authNotifier.updateProfile(language: 'kk'),
                      ),
                      const SizedBox(width: 8),
                      _LangChip(
                        code: 'en',
                        title: 'English',
                        isSelected: user?.language == 'en',
                        onTap: () => authNotifier.updateProfile(language: 'en'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),

            // Accessibility Settings Overview
            AppCard(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        loc.tr('accessibility_settings'),
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const Icon(
                        Icons.accessibility,
                        size: 20,
                        color: AppColors.primary,
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  SwitchListTile.adaptive(
                    contentPadding: EdgeInsets.zero,
                    title: const Text(
                      'Тёмная тема',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    value: isDark,
                    onChanged: (val) {
                      ref.read(themeProvider.notifier).toggleDarkTheme(val);
                    },
                  ),
                  SwitchListTile.adaptive(
                    contentPadding: EdgeInsets.zero,
                    title: Text(
                      loc.tr('high_contrast'),
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    value: user?.accessibility.highContrast ?? false,
                    onChanged: (val) {
                      final acc =
                          (user?.accessibility ??
                                  const UserAccessibilitySettings())
                              .copyWith(highContrast: val);
                      authNotifier.updateProfile(accessibility: acc);
                    },
                  ),
                  SwitchListTile.adaptive(
                    contentPadding: EdgeInsets.zero,
                    title: Text(
                      loc.tr('reduce_motion'),
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    value: user?.accessibility.reduceMotion ?? false,
                    onChanged: (val) {
                      final acc =
                          (user?.accessibility ??
                                  const UserAccessibilitySettings())
                              .copyWith(reduceMotion: val);
                      authNotifier.updateProfile(accessibility: acc);
                    },
                  ),
                  const SizedBox(height: 4),
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton.icon(
                      onPressed: () => context.push('/inclusive/accessibility'),
                      icon: const Icon(Icons.tune_rounded, size: 16),
                      label: const Text(
                        'Шрифт и все настройки',
                        style: TextStyle(fontSize: 12),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Admin Panel Shortcut Card
            AppCard(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              onTap: () => context.push('/admin'),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppColors.primaryDark.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(
                      Icons.admin_panel_settings_rounded,
                      color: AppColors.primaryDark,
                      size: 22,
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Панель Администратора',
                          style: TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 13,
                          ),
                        ),
                        Text(
                          'Модерация и верификация преподавателей',
                          style: TextStyle(
                            fontSize: 11,
                            color: AppColors.secondaryTextLight,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Icon(
                    Icons.arrow_forward_ios_rounded,
                    size: 14,
                    color: AppColors.secondaryTextLight,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Logout Button
            SecondaryButton(
              text: loc.tr('logout'),
              icon: Icons.logout_rounded,
              onPressed: () => authNotifier.logout(),
            ),
          ],
        ),
      ),
    );
  }

  void _showEditProfileDialog(
    BuildContext context,
    WidgetRef ref,
    UserModel? user,
  ) {
    final nameController = TextEditingController(text: user?.name ?? '');
    final schoolController = TextEditingController(text: user?.school ?? '');

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text(
          'Редактировать профиль',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: InputDecoration(
                labelText: 'Ваше имя и фамилия',
                hintText: 'Введите ваше имя',
                prefixIcon: const Icon(Icons.person_outline),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
            const SizedBox(height: 14),
            TextField(
              controller: schoolController,
              decoration: InputDecoration(
                labelText: 'Школа и класс',
                hintText: 'Например: Школа №1, 10 класс',
                prefixIcon: const Icon(Icons.school_outlined),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Отмена'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            onPressed: () {
              final newName = nameController.text.trim();
              final newSchool = schoolController.text.trim();
              if (newName.isNotEmpty) {
                ref.read(authNotifierProvider.notifier).updateProfile(
                      name: newName,
                      school: newSchool.isNotEmpty ? newSchool : null,
                    );
              }
              Navigator.pop(ctx);
            },
            child: const Text('Сохранить'),
          ),
        ],
      ),
    );
  }
}

class _LangChip extends StatelessWidget {
  final String code;
  final String title;
  final bool isSelected;
  final VoidCallback onTap;

  const _LangChip({
    required this.code,
    required this.title,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ChoiceChip(
      label: Text(
        title,
        style: TextStyle(
          fontSize: 12,
          fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
          color: isSelected ? AppColors.primaryDark : null,
        ),
      ),
      selected: isSelected,
      selectedColor: AppColors.primaryLight,
      checkmarkColor: AppColors.primaryDark,
      onSelected: (_) => onTap(),
    );
  }
}
