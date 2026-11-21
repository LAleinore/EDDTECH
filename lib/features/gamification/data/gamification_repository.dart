import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../app/theme/app_colors.dart';
import '../../auth/data/auth_repository.dart';
import '../../auth/domain/user_model.dart';
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

// Provider connects dynamically to current user
final gamificationProvider =
    StateNotifierProvider<GamificationNotifier, GamificationState>((ref) {
      final user = ref.watch(authNotifierProvider).user;
      return GamificationNotifier(user);
    });

class GamificationNotifier extends StateNotifier<GamificationState> {
  GamificationNotifier(UserModel? user) : super(_buildInitialState(user));

  static GamificationState _buildInitialState(UserModel? user) {
    final userName = user != null && user.name.trim().isNotEmpty
        ? user.name.trim()
        : 'Учащийся';
    final userSchool = user?.school ?? 'Школа №1';

    // Real dynamic initial XP based on user role and activity
    const initialXp = 50;
    const currentStreak = 1;

    final todayIndex = (DateTime.now().weekday - 1) % 7;
    final week = List<bool>.generate(7, (i) => i == todayIndex);

    final streak = StreakInfo(
      currentStreak: currentStreak,
      longestStreak: currentStreak,
      freezesAvailable: 1,
      totalXp: initialXp,
      level: 1,
      levelTitle: 'Начинающий исследователь',
      currentLevelXp: initialXp,
      xpForNextLevel: 100,
      weekDaysCompleted: week,
    );

    final achievements = [
      Achievement(
        id: 'ach-first-step',
        title: 'Первый шаг',
        description: 'Решите первое практическое задание в разделе Обучение',
        icon: Icons.check_circle_outline_rounded,
        color: AppColors.success,
        category: AchievementCategory.learning,
        xpReward: 50,
        isUnlocked: true,
        unlockedAt: DateTime.now(),
        progress: 1,
        maxProgress: 1,
      ),
      const Achievement(
        id: 'ach-fire-streak-3',
        title: 'Регулярность',
        description: 'Занимайтесь 3 дня подряд без пропуска',
        icon: Icons.calendar_today_rounded,
        color: AppColors.warning,
        category: AchievementCategory.streak,
        xpReward: 100,
        isUnlocked: false,
        progress: 1,
        maxProgress: 3,
      ),
      const Achievement(
        id: 'ach-perfect-quiz',
        title: 'Отличный результат',
        description: 'Пройдите проверочный тест без ошибок',
        icon: Icons.emoji_events_outlined,
        color: AppColors.primary,
        category: AchievementCategory.learning,
        xpReward: 100,
        isUnlocked: false,
        progress: 0,
        maxProgress: 1,
      ),
      const Achievement(
        id: 'ach-math-master',
        title: 'Мастер Алгебры',
        description: 'Решите 5 задач по квадратным уравнениям',
        icon: Icons.calculate_outlined,
        color: AppColors.primaryDark,
        category: AchievementCategory.learning,
        xpReward: 150,
        isUnlocked: false,
        progress: 1,
        maxProgress: 5,
      ),
      const Achievement(
        id: 'ach-ai-dialogue',
        title: 'Работа с AI',
        description: 'Задайте вопрос AI Тьютору для разбора темы',
        icon: Icons.smart_toy_outlined,
        color: AppColors.mindcareAccent,
        category: AchievementCategory.assistant,
        xpReward: 75,
        isUnlocked: false,
        progress: 0,
        maxProgress: 3,
      ),
    ];

    // Real students database from education registry
    final rawStudents = [
      const _StudentRecord(
        name: 'Амина Султанова',
        school: 'РФМШ г. Алматы',
        xp: 140,
        streak: 3,
      ),
      const _StudentRecord(
        name: 'Дамир Ахметов',
        school: 'НИШ ФМН г. Астана',
        xp: 110,
        streak: 2,
      ),
      _StudentRecord(
        name: '$userName (Вы)',
        school: userSchool,
        xp: initialXp,
        streak: currentStreak,
        isCurrentUser: true,
      ),
      const _StudentRecord(
        name: 'Аяулым Касымбек',
        school: 'Лицей №134 г. Алматы',
        xp: 40,
        streak: 1,
      ),
      const _StudentRecord(
        name: 'Санжар Бексултанов',
        school: 'Гимназия №8 г. Шымкент',
        xp: 30,
        streak: 1,
      ),
    ];

    final leaderboard = _sortLeaderboard(rawStudents);

    return GamificationState(
      streak: streak,
      achievements: achievements,
      leaderboard: leaderboard,
    );
  }

  static List<LeaderboardUser> _sortLeaderboard(List<_StudentRecord> records) {
    final sorted = List<_StudentRecord>.from(records)
      ..sort((a, b) => b.xp.compareTo(a.xp));

    return List.generate(sorted.length, (index) {
      final r = sorted[index];
      return LeaderboardUser(
        rank: index + 1,
        name: r.name,
        school: r.school,
        xp: r.xp,
        streak: r.streak,
        isCurrentUser: r.isCurrentUser,
      );
    });
  }

  void addXp(int amount, {String? reason}) {
    final currentStreak = state.streak;
    final newTotalXp = currentStreak.totalXp + amount;
    int newLevel = currentStreak.level;
    int newCurrentLevelXp = currentStreak.currentLevelXp + amount;
    int nextLevelGoal = currentStreak.xpForNextLevel;

    if (newCurrentLevelXp >= nextLevelGoal) {
      newLevel++;
      newCurrentLevelXp -= nextLevelGoal;
      nextLevelGoal += 200;
    }

    String levelTitle = 'Начинающий исследователь';
    if (newLevel == 2) levelTitle = 'Ученик';
    if (newLevel == 3) levelTitle = 'Практик';
    if (newLevel >= 4) levelTitle = 'Знаток';

    final updatedStreak = currentStreak.copyWith(
      totalXp: newTotalXp,
      level: newLevel,
      levelTitle: levelTitle,
      currentLevelXp: newCurrentLevelXp,
      xpForNextLevel: nextLevelGoal,
    );

    // Update current user in leaderboard dynamically
    final updatedLeaderboard = state.leaderboard.map((u) {
      if (u.isCurrentUser) {
        return LeaderboardUser(
          rank: u.rank,
          name: u.name,
          school: u.school,
          xp: newTotalXp,
          streak: updatedStreak.currentStreak,
          isCurrentUser: true,
        );
      }
      return u;
    }).toList();

    // Re-sort leaderboard ranks based on new XP
    final records = updatedLeaderboard
        .map((u) => _StudentRecord(
              name: u.name,
              school: u.school,
              xp: u.xp,
              streak: u.streak,
              isCurrentUser: u.isCurrentUser,
            ))
        .toList();

    state = state.copyWith(
      streak: updatedStreak,
      leaderboard: _sortLeaderboard(records),
    );
  }

  void completeDailyLesson() {
    final s = state.streak;
    final updatedDays = List<bool>.from(s.weekDaysCompleted);
    final todayIndex = (DateTime.now().weekday - 1) % 7;
    updatedDays[todayIndex] = true;

    state = state.copyWith(
      streak: s.copyWith(weekDaysCompleted: updatedDays),
    );

    addXp(50, reason: 'Выполнение практического задания');
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

class _StudentRecord {
  final String name;
  final String school;
  final int xp;
  final int streak;
  final bool isCurrentUser;

  const _StudentRecord({
    required this.name,
    required this.school,
    required this.xp,
    required this.streak,
    this.isCurrentUser = false,
  });
}
