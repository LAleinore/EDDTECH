import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../app/theme/app_colors.dart';
import '../../../core/widgets/cards.dart';
import '../../auth/data/auth_repository.dart';
import '../../auth/domain/user_model.dart';

class AccessibilitySettingsScreen extends ConsumerWidget {
  const AccessibilitySettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authNotifierProvider).user;
    final authNotifier = ref.read(authNotifierProvider.notifier);
    final acc = user?.accessibility ?? const UserAccessibilitySettings();

    return Scaffold(
      appBar: AppBar(title: const Text('Специальные возможности')),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            // Preview Card
            AppCard(
              padding: const EdgeInsets.all(18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Предпросмотр текста',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: AppColors.secondaryTextLight,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'EduMind AI адаптирует интерфейс под ваши индивидуальные потребности.',
                    style: TextStyle(
                      fontSize: 15 * acc.fontScale,
                      fontWeight: acc.highContrast
                          ? FontWeight.bold
                          : FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Font Scale Slider
            AppCard(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Размер текста',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        '${(acc.fontScale * 100).toInt()}%',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: AppColors.primary,
                        ),
                      ),
                    ],
                  ),
                  Slider(
                    value: acc.fontScale,
                    min: 0.85,
                    max: 1.45,
                    divisions: 6,
                    label: '${(acc.fontScale * 100).toInt()}%',
                    activeColor: AppColors.primary,
                    onChanged: (val) {
                      authNotifier.updateProfile(
                        accessibility: acc.copyWith(fontScale: val),
                      );
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),

            // High Contrast Switch
            AppCard(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: SwitchListTile.adaptive(
                contentPadding: EdgeInsets.zero,
                title: const Text(
                  'Высокая контрастность',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                ),
                subtitle: const Text(
                  'Усиливает границы карточек и контрастность шрифтов',
                  style: TextStyle(
                    fontSize: 11,
                    color: AppColors.secondaryTextLight,
                  ),
                ),
                value: acc.highContrast,
                onChanged: (val) {
                  authNotifier.updateProfile(
                    accessibility: acc.copyWith(highContrast: val),
                  );
                },
              ),
            ),
            const SizedBox(height: 12),

            // Reduce Motion Switch
            AppCard(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: SwitchListTile.adaptive(
                contentPadding: EdgeInsets.zero,
                title: const Text(
                  'Уменьшение анимаций',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                ),
                subtitle: const Text(
                  'Отключает быстрые переходы и мерцания',
                  style: TextStyle(
                    fontSize: 11,
                    color: AppColors.secondaryTextLight,
                  ),
                ),
                value: acc.reduceMotion,
                onChanged: (val) {
                  authNotifier.updateProfile(
                    accessibility: acc.copyWith(reduceMotion: val),
                  );
                },
              ),
            ),
            const SizedBox(height: 12),

            // Simplified UI
            AppCard(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: SwitchListTile.adaptive(
                contentPadding: EdgeInsets.zero,
                title: const Text(
                  'Упрощенный интерфейс',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                ),
                subtitle: const Text(
                  'Скрывает второстепенные декоративные элементы',
                  style: TextStyle(
                    fontSize: 11,
                    color: AppColors.secondaryTextLight,
                  ),
                ),
                value: acc.simplifiedUI,
                onChanged: (val) {
                  authNotifier.updateProfile(
                    accessibility: acc.copyWith(simplifiedUI: val),
                  );
                },
              ),
            ),
            const SizedBox(height: 12),

            // Large Buttons
            AppCard(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: SwitchListTile.adaptive(
                contentPadding: EdgeInsets.zero,
                title: const Text(
                  'Крупные кнопки',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                ),
                subtitle: const Text(
                  'Увеличивает область нажатия для комфортного касания',
                  style: TextStyle(
                    fontSize: 11,
                    color: AppColors.secondaryTextLight,
                  ),
                ),
                value: acc.largeButtons,
                onChanged: (val) {
                  authNotifier.updateProfile(
                    accessibility: acc.copyWith(largeButtons: val),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
