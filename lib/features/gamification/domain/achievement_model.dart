import 'package:flutter/material.dart';

enum AchievementCategory {
  learning,
  streak,
  assistant,
  mindcare,
}

class Achievement {
  final String id;
  final String title;
  final String description;
  final IconData icon;
  final Color color;
  final AchievementCategory category;
  final int xpReward;
  final bool isUnlocked;
  final DateTime? unlockedAt;
  final int progress;
  final int maxProgress;

  const Achievement({
    required this.id,
    required this.title,
    required this.description,
    required this.icon,
    required this.color,
    required this.category,
    required this.xpReward,
    required this.isUnlocked,
    this.unlockedAt,
    required this.progress,
    required this.maxProgress,
  });

  Achievement copyWith({
    bool? isUnlocked,
    DateTime? unlockedAt,
    int? progress,
  }) {
    return Achievement(
      id: id,
      title: title,
      description: description,
      icon: icon,
      color: color,
      category: category,
      xpReward: xpReward,
      isUnlocked: isUnlocked ?? this.isUnlocked,
      unlockedAt: unlockedAt ?? this.unlockedAt,
      progress: progress ?? this.progress,
      maxProgress: maxProgress,
    );
  }
}

class StreakInfo {
  final int currentStreak;
  final int longestStreak;
  final int freezesAvailable;
  final int totalXp;
  final int level;
  final String levelTitle;
  final int currentLevelXp;
  final int xpForNextLevel;
  final List<bool> weekDaysCompleted; // Mon..Sun (7 items)

  const StreakInfo({
    required this.currentStreak,
    required this.longestStreak,
    required this.freezesAvailable,
    required this.totalXp,
    required this.level,
    required this.levelTitle,
    required this.currentLevelXp,
    required this.xpForNextLevel,
    required this.weekDaysCompleted,
  });

  double get progressToNextLevel =>
      xpForNextLevel > 0 ? (currentLevelXp / xpForNextLevel).clamp(0.0, 1.0) : 1.0;

  StreakInfo copyWith({
    int? currentStreak,
    int? longestStreak,
    int? freezesAvailable,
    int? totalXp,
    int? level,
    String? levelTitle,
    int? currentLevelXp,
    int? xpForNextLevel,
    List<bool>? weekDaysCompleted,
  }) {
    return StreakInfo(
      currentStreak: currentStreak ?? this.currentStreak,
      longestStreak: longestStreak ?? this.longestStreak,
      freezesAvailable: freezesAvailable ?? this.freezesAvailable,
      totalXp: totalXp ?? this.totalXp,
      level: level ?? this.level,
      levelTitle: levelTitle ?? this.levelTitle,
      currentLevelXp: currentLevelXp ?? this.currentLevelXp,
      xpForNextLevel: xpForNextLevel ?? this.xpForNextLevel,
      weekDaysCompleted: weekDaysCompleted ?? this.weekDaysCompleted,
    );
  }
}

class LeaderboardUser {
  final int rank;
  final String name;
  final String school;
  final int xp;
  final int streak;
  final bool isCurrentUser;

  const LeaderboardUser({
    required this.rank,
    required this.name,
    required this.school,
    required this.xp,
    required this.streak,
    this.isCurrentUser = false,
  });
}
