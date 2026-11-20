import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../app/localization/app_localizations.dart';
import '../../../app/theme/app_colors.dart';
import '../../../core/widgets/cards.dart';
import '../../auth/data/auth_repository.dart';

class ModulesScreen extends ConsumerWidget {
  const ModulesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authNotifierProvider).user;
    final loc = AppLocalizations(AppLanguage.fromCode(user?.language ?? 'ru'));

    return Scaffold(
      appBar: AppBar(title: Text(loc.tr('nav_modules'))),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            // 1. Daryn Ustaz
            _ModuleCategoryCard(
              title: loc.tr('module_teacher_title'),
              subtitle: loc.tr('module_teacher_sub'),
              description: loc.tr('module_teacher_desc'),
              icon: Icons.school_rounded,
              color: AppColors.teacherAccent,
              actions: [
                _ActionItem(
                  'Генератор уроков',
                  Icons.menu_book,
                  () => context.push('/teacher/lesson-generator'),
                ),
                _ActionItem(
                  'Конструктор тестов',
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

            // 2. MindCare
            _ModuleCategoryCard(
              title: loc.tr('module_mindcare_title'),
              subtitle: loc.tr('module_mindcare_sub'),
              description: loc.tr('module_mindcare_desc'),
              icon: Icons.spa_rounded,
              color: AppColors.mindcareAccent,
              actions: [
                _ActionItem(
                  'Поддерживающий диалог',
                  Icons.chat_bubble_outline,
                  () => context.push('/mindcare/chat'),
                ),
                _ActionItem(
                  'Дневник настроения',
                  Icons.mood,
                  () => context.push('/mindcare/mood'),
                ),
                _ActionItem(
                  'Дыхательные практики',
                  Icons.air,
                  () => context.push('/mindcare/exercises'),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // 3. Inclusive AI
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
                        fontSize: 18,
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
              fontSize: 13,
              color: AppColors.secondaryTextLight,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 16),
          const Divider(),
          const SizedBox(height: 8),
          ...actions.map(
            (action) => ListTile(
              contentPadding: EdgeInsets.zero,
              leading: Icon(action.icon, size: 20, color: color),
              title: Text(
                action.label,
                style: const TextStyle(
                  fontSize: 14,
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
