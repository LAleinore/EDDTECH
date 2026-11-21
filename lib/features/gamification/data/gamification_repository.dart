import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../app/theme/app_colors.dart';
import '../domain/achievement_model.dart';

class GamificationState {
  final StreakInfo streak;
  final List<Achievement> achievements;
  final List<LeaderboardUser> leaderboard;

  const GamificationState({
    required this.streak,
    required this.achievements,
    required this.leaderboard,
  });

  GamificationState copyWith({
    StreakInfo? streak,
    List<Achievement>? achievements,
    List<LeaderboardUser>? leaderboard,
  }) {
    return GamificationState(
      streak: streak ?? this.streak,
      achievements: achievements ?? this.achievements,
      leaderboard: leaderboard ?? this.leaderboard,
    );
  }
}

final gamificationProvider =
    StateNotifierProvider<GamificationNotifier, GamificationState>((ref) {
      return GamificationNotifier();
    });

class GamificationNotifier extends StateNotifier<GamificationState> {
  GamificationNotifier() : super(_initialState);

  static final GamificationState _initialState = GamificationState(
    streak: const StreakInfo(
      currentStreak: 7,
      longestStreak: 14,
      freezesAvailable: 2,
      totalXp: 1450,
      level: 4,
      levelTitle: 'Искатель знаний',
      currentLevelXp: 450,
      xpForNextLevel: 1000,
      weekDaysCompleted: [true, true, true, true, true, true, true],
    ),
    achievements: [
      Achievement(
        id: 'ach-first-step',
        title: 'Первый шаг',
        description: 'Успешно завершите свой первый интерактивный урок',
        icon: Icons.flag_rounded,
        color: AppColors.success,
        category: AchievementCategory.learning,
        xpReward: 50,
        isUnlocked: true,
        unlockedAt: DateTime.now().subtract(const Duration(days: 6)),
        progress: 1,
        maxProgress: 1,
      ),
      Achievement(
        id: 'ach-fire-streak-3',
        title: 'В огне',
        description: 'Удерживайте непрерывный стрик обучения 3 дня подряд',
        icon: Icons.local_fire_department_rounded,
        color: AppColors.warning,
        category: AchievementCategory.streak,
        xpReward: 100,
        isUnlocked: true,
        unlockedAt: DateTime.now().subtract(const Duration(days: 4)),
        progress: 3,
        maxProgress: 3,
      ),
      Achievement(
        id: 'ach-streak-week',
        title: 'Недельный марафон',
        description: 'Занимайтесь каждый день в течение всей недели (7 дней)',
        icon: Icons.bolt_rounded,
        color: AppColors.primary,
        category: AchievementCategory.streak,
        xpReward: 250,
        isUnlocked: true,
        unlockedAt: DateTime.now(),
        progress: 7,
        maxProgress: 7,
      ),
      Achievement(
        id: 'ach-perfect-quiz',
        title: 'Абсолютный эрудит',
        description: 'Пройдите проверочный тест по любому предмету на 100%',
        icon: Icons.verified_rounded,
        color: AppColors.teacherAccent,
        category: AchievementCategory.learning,
        xpReward: 150,
        isUnlocked: true,
        unlockedAt: DateTime.now().subtract(const Duration(days: 2)),
        progress: 1,
        maxProgress: 1,
      ),
      Achievement(
        id: 'ach-math-master',
        title: 'Мастер Алгебры',
        description: 'Решите 10 задач по квадратным уравнениям и функциям',
        icon: Icons.calculate_rounded,
        color: AppColors.primaryDark,
        category: AchievementCategory.learning,
        xpReward: 200,
        isUnlocked: false,
        progress: 7,
        maxProgress: 10,
      ),
      Achievement(
        id: 'ach-ai-dialogue',
        title: 'Собеседник ИИ',
        description: 'Задайте 5 академических вопросов AI Тьютору',
        icon: Icons.psychology_rounded,
        color: AppColors.mindcareAccent,
        category: AchievementCategory.assistant,
        xpReward: 120,
        isUnlocked: false,
        progress: 3,
        maxProgress: 5,
      ),
      Achievement(
        id: 'ach-mind-harmony',
        title: 'Осознанность',
        description: 'Отметьте настроение 5 раз в дневнике MindCare',
        icon: Icons.spa_rounded,
        color: AppColors.mindcareAccent,
        category: AchievementCategory.mindcare,
        xpReward: 100,
        isUnlocked: false,
        progress: 4,
        maxProgress: 5,
      ),
      Achievement(
        id: 'ach-polyglot',
        title: 'Полиглот',
        description: 'Пройдите модуль академического английского уровня B2-C1',
        icon: Icons.translate_rounded,
        color: AppColors.success,
        category: AchievementCategory.learning,
        xpReward: 180,
        isUnlocked: false,
        progress: 1,
        maxProgress: 3,
      ),
    ],
    leaderboard: const [
      LeaderboardUser(
        rank: 1,
        name: 'Амина Султанова',
        school: 'РФМШ г. Алматы',
        xp: 2840,
        streak: 21,
      ),
      LeaderboardUser(
        rank: 2,
        name: 'Дамир Ахметов',
        school: 'НИШ ФМН г. Астана',
        xp: 2310,
        streak: 18,
      ),
      LeaderboardUser(
        rank: 3,
        name: 'Мадина Омарова',
        school: 'Лицей «Білім-Инновация»',
        xp: 1950,
        streak: 12,
      ),
      LeaderboardUser(
        rank: 4,
        name: 'Алихан Нуртаев (Вы)',
        school: 'Лицей №1 г. Астана',
        xp: 1450,
        streak: 7,
        isCurrentUser: true,
      ),
      LeaderboardUser(
        rank: 5,
        name: 'Санжар Бексултанов',
        school: 'Гимназия №8 г. Шымкент',
        xp: 1320,
        streak: 9,
      ),
      LeaderboardUser(
        rank: 6,
        name: 'Аяулым Касымбек',
        school: 'НИШ ХБН г. Караганда',
        xp: 1180,
        streak: 5,
      ),
    ],
  );

  void addXp(int amount, {String? reason}) {
    final currentStreak = state.streak;
    final newTotalXp = currentStreak.totalXp + amount;
    int newLevel = currentStreak.level;
    int newCurrentLevelXp = currentStreak.currentLevelXp + amount;
    int nextLevelGoal = currentStreak.xpForNextLevel;

    if (newCurrentLevelXp >= nextLevelGoal) {
      newLevel++;
      newCurrentLevelXp -= nextLevelGoal;
      nextLevelGoal += 500;
    }

    String levelTitle = currentStreak.levelTitle;
    if (newLevel >= 5) levelTitle = 'Знаток наук';
    if (newLevel >= 8) levelTitle = 'Магистр Академии';

    state = state.copyWith(
      streak: currentStreak.copyWith(
        totalXp: newTotalXp,
        level: newLevel,
        levelTitle: levelTitle,
        currentLevelXp: newCurrentLevelXp,
        xpForNextLevel: nextLevelGoal,
      ),
    );
  }

  void completeDailyLesson() {
    final s = state.streak;
    final updatedDays = List<bool>.from(s.weekDaysCompleted);
    final todayIndex = (DateTime.now().weekday - 1) % 7;
    updatedDays[todayIndex] = true;

    addXp(50, reason: 'Ежедневный урок');

    state = state.copyWith(
      streak: s.copyWith(
        currentStreak: s.currentStreak + 1,
        longestStreak: (s.currentStreak + 1 > s.longestStreak)
            ? s.currentStreak + 1
            : s.longestStreak,
        weekDaysCompleted: updatedDays,
      ),
    );
  }

  void unlockAchievement(String id) {
    final updated = state.achievements.map((ach) {
      if (ach.id == id && !ach.isUnlocked) {
        addXp(ach.xpReward, reason: 'Достижение: ${ach.title}');
        return ach.copyWith(
          isUnlocked: true,
          unlockedAt: DateTime.now(),
          progress: ach.maxProgress,
        );
      }
      return ach;
    }).toList();

    state = state.copyWith(achievements: updated);
  }

  void useFreeze() {
    if (state.streak.freezesAvailable > 0) {
      state = state.copyWith(
        streak: state.streak.copyWith(
          freezesAvailable: state.streak.freezesAvailable - 1,
        ),
      );
    }
  }
}
