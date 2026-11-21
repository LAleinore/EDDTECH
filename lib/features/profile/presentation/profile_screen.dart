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

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authNotifierProvider).user;
    final loc = AppLocalizations(AppLanguage.fromCode(user?.language ?? 'ru'));
    final authNotifier = ref.read(authNotifierProvider.notifier);
    final isDark = ref.watch(themeProvider);

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
                      Text(
                        user?.name ?? 'Пользователь',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
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
            const SizedBox(height: 24),

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
