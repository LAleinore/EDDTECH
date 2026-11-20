import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../app/localization/app_localizations.dart';
import '../../../app/theme/app_colors.dart';
import '../../auth/data/auth_repository.dart';
import '../../auth/domain/user_model.dart';

class MainScaffold extends ConsumerWidget {
  final StatefulNavigationShell navigationShell;

  const MainScaffold({super.key, required this.navigationShell});

  void _onTap(int index) {
    navigationShell.goBranch(
      index,
      initialLocation: index == navigationShell.currentIndex,
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authNotifierProvider).user;
    final loc = AppLocalizations(AppLanguage.fromCode(user?.language ?? 'ru'));
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isAdmin = user?.role == UserRole.admin;

    return Scaffold(
      body: navigationShell,
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
          border: Border(
            top: BorderSide(
              color: isDark ? AppColors.dividerDark : AppColors.dividerLight,
              width: 0.5,
            ),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 10,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _NavBarItem(
                  icon: Icons.grid_view_rounded,
                  label: loc.tr('nav_home'),
                  isSelected: navigationShell.currentIndex == 0,
                  onTap: () => _onTap(0),
                ),
                _NavBarItem(
                  icon: Icons.menu_book_rounded,
                  label: 'Обучение',
                  isSelected: navigationShell.currentIndex == 1,
                  onTap: () => _onTap(1),
                  accentColor: AppColors.primary,
                ),
                _NavBarItem(
                  icon: Icons.auto_awesome_rounded,
                  label: 'AI Помощник',
                  isSelected: navigationShell.currentIndex == 2,
                  onTap: () => _onTap(2),
                  accentColor: AppColors.primaryDark,
                ),
                _NavBarItem(
                  icon: Icons.layers_rounded,
                  label: loc.tr('nav_modules'),
                  isSelected: navigationShell.currentIndex == 3,
                  onTap: () => _onTap(3),
                ),
                _NavBarItem(
                  icon: Icons.person_rounded,
                  label: loc.tr('nav_profile'),
                  isSelected: navigationShell.currentIndex == 4,
                  onTap: () => _onTap(4),
                ),
              ],
            ),
          ),
        ),
      ),
      floatingActionButton: isAdmin
          ? FloatingActionButton.extended(
              backgroundColor: AppColors.primaryDark,
              foregroundColor: Colors.white,
              onPressed: () => context.push('/admin'),
              icon: const Icon(Icons.admin_panel_settings_rounded, size: 20),
              label: const Text(
                'Админ-панель',
                style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
              ),
            )
          : null,
    );
  }
}

class _NavBarItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;
  final Color? accentColor;

  const _NavBarItem({
    required this.icon,
    required this.label,
    required this.isSelected,
    required this.onTap,
    this.accentColor,
  });

  @override
  Widget build(BuildContext context) {
    final activeColor = accentColor ?? AppColors.primary;
    final inactiveColor = Theme.of(context).brightness == Brightness.dark
        ? AppColors.secondaryTextDark
        : AppColors.secondaryTextLight;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 22,
              color: isSelected ? activeColor : inactiveColor,
            ),
            const SizedBox(height: 3),
            Text(
              label,
              style: TextStyle(
                fontSize: 10,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                color: isSelected ? activeColor : inactiveColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
