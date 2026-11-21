import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../app/theme/app_colors.dart';
import '../../../core/widgets/cards.dart';
import '../data/gamification_repository.dart';
import '../domain/achievement_model.dart';

class AchievementsScreen extends ConsumerStatefulWidget {
  const AchievementsScreen({super.key});

  @override
  ConsumerState<AchievementsScreen> createState() => _AchievementsScreenState();
}

class _AchievementsScreenState extends ConsumerState<AchievementsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final gamification = ref.watch(gamificationProvider);
    final streak = gamification.streak;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Достижения и Стрики',
          style: TextStyle(fontWeight: FontWeight.w700),
        ),
        bottom: TabBar(
          controller: _tabController,
          labelColor: AppColors.primary,
          unselectedLabelColor: AppColors.secondaryTextLight,
          indicatorColor: AppColors.primary,
          indicatorWeight: 3,
          tabs: const [
            Tab(text: 'Ударный режим'),
            Tab(text: 'Награды'),
            Tab(text: 'Лидерборд'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // TAB 1: STREAK & XP PROGRESS
          _buildStreakTab(context, streak),

          // TAB 2: ACHIEVEMENTS
          _buildAchievementsTab(context, gamification.achievements),

          // TAB 3: LEADERBOARD
          _buildLeaderboardTab(context, gamification.leaderboard),
        ],
      ),
    );
  }

  Widget _buildStreakTab(BuildContext context, StreakInfo streak) {
    const dayNames = ['ПН', 'ВТ', 'СР', 'ЧТ', 'ПТ', 'СБ', 'ВС'];

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Main Flame Hero Card
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFFE8590C), Color(0xFFF76707), Color(0xFFFF922B)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFFE8590C).withOpacity(0.35),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.local_fire_department_rounded,
                        color: Colors.white,
                        size: 42,
                      ),
                    ),
                    const SizedBox(width: 14),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${streak.currentStreak} ДНЕЙ',
                          style: const TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.w900,
                            color: Colors.white,
                            letterSpacing: -0.5,
                          ),
                        ),
                        const Text(
                          'Ударный режим активен 🔥',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // Week days dots
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.18),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: List.generate(7, (index) {
                      final isDone = streak.weekDaysCompleted[index];
                      return Column(
                        children: [
                          Text(
                            dayNames[index],
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: isDone
                                  ? Colors.white
                                  : Colors.white.withOpacity(0.5),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Container(
                            width: 32,
                            height: 32,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: isDone
                                  ? Colors.white
                                  : Colors.white.withOpacity(0.15),
                            ),
                            child: Icon(
                              isDone ? Icons.check_rounded : Icons.lock_outline_rounded,
                              size: 16,
                              color: isDone
                                  ? const Color(0xFFE8590C)
                                  : Colors.white.withOpacity(0.4),
                            ),
                          ),
                        ],
                      );
                    }),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Level and XP Card
          AppCard(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: AppColors.primary.withOpacity(0.12),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Icon(
                            Icons.military_tech_rounded,
                            color: AppColors.primary,
                            size: 24,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Уровень ${streak.level}',
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                            Text(
                              streak.levelTitle,
                              style: const TextStyle(
                                fontSize: 13,
                                color: AppColors.secondaryTextLight,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                        color: AppColors.primaryLight,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        '⚡ ${streak.totalXp} XP',
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w800,
                          color: AppColors.primary,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 18),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Прогресс уровня',
                      style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                    ),
                    Text(
                      '${streak.currentLevelXp} / ${streak.xpForNextLevel} XP',
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: AppColors.primary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: LinearProgressIndicator(
                    value: streak.progressToNextLevel,
                    minHeight: 10,
                    backgroundColor: AppColors.dividerLight,
                    valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primary),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Streak Protection & Stats Card
          AppCard(
            padding: const EdgeInsets.all(18),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.mindcareAccent.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: const Icon(
                    Icons.ac_unit_rounded,
                    color: AppColors.mindcareAccent,
                    size: 26,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Заморозка стрика',
                        style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Доступно: ${streak.freezesAvailable} защиты от пропуска дня',
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppColors.secondaryTextLight,
                        ),
                      ),
                    ],
                  ),
                ),
                OutlinedButton(
                  onPressed: streak.freezesAvailable > 0
                      ? () {
                          ref.read(gamificationProvider.notifier).useFreeze();
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Заморозка активирована! Стрик защищен на сегодня.'),
                            ),
                          );
                        }
                      : null,
                  style: OutlinedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: const Text('Применить', style: TextStyle(fontSize: 12)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAchievementsTab(BuildContext context, List<Achievement> achievements) {
    final unlockedCount = achievements.where((a) => a.isUnlocked).length;

    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        // Summary Header Card
        Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: AppColors.dividerLight),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Разблокировано наград',
                    style: TextStyle(fontSize: 13, color: AppColors.secondaryTextLight),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '$unlockedCount из ${achievements.length}',
                    style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w800),
                  ),
                ],
              ),
              CircularProgressIndicator(
                value: achievements.isNotEmpty ? unlockedCount / achievements.length : 0,
                strokeWidth: 6,
                backgroundColor: AppColors.dividerLight,
                valueColor: const AlwaysStoppedAnimation<Color>(AppColors.success),
              ),
            ],
          ),
        ),
        const SizedBox(height: 18),

        ...achievements.map((ach) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: AppCard(
              padding: const EdgeInsets.all(16),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: ach.isUnlocked
                          ? ach.color.withOpacity(0.14)
                          : Colors.grey.withOpacity(0.12),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      ach.icon,
                      color: ach.isUnlocked ? ach.color : Colors.grey,
                      size: 26,
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                ach.title,
                                style: TextStyle(
                                  fontWeight: FontWeight.w700,
                                  fontSize: 15,
                                  color: ach.isUnlocked
                                      ? null
                                      : AppColors.secondaryTextLight,
                                ),
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                              decoration: BoxDecoration(
                                color: ach.isUnlocked
                                    ? AppColors.primaryLight
                                    : Colors.grey.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                '+${ach.xpReward} XP',
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700,
                                  color: ach.isUnlocked
                                      ? AppColors.primary
                                      : Colors.grey,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          ach.description,
                          style: const TextStyle(
                            fontSize: 12,
                            color: AppColors.secondaryTextLight,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Row(
                          children: [
                            Expanded(
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(4),
                                child: LinearProgressIndicator(
                                  value: ach.maxProgress > 0
                                      ? ach.progress / ach.maxProgress
                                      : 0,
                                  minHeight: 6,
                                  backgroundColor: AppColors.dividerLight,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    ach.isUnlocked ? ach.color : Colors.grey,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Text(
                              ach.isUnlocked
                                  ? 'Выполнено'
                                  : '${ach.progress}/${ach.maxProgress}',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                color: ach.isUnlocked
                                    ? AppColors.success
                                    : AppColors.secondaryTextLight,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        }),
      ],
    );
  }

  Widget _buildLeaderboardTab(BuildContext context, List<LeaderboardUser> leaderboard) {
    return ListView.builder(
      padding: const EdgeInsets.all(20),
      itemCount: leaderboard.length,
      itemBuilder: (context, index) {
        final user = leaderboard[index];

        Color? rankColor;
        if (user.rank == 1) rankColor = const Color(0xFFFFD700); // Gold
        if (user.rank == 2) rankColor = const Color(0xFFC0C0C0); // Silver
        if (user.rank == 3) rankColor = const Color(0xFFCD7F32); // Bronze

        return Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: AppCard(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            color: user.isCurrentUser
                ? AppColors.primary.withOpacity(0.08)
                : null,
            border: user.isCurrentUser
                ? Border.all(color: AppColors.primary, width: 1.5)
                : null,
            child: Row(
              children: [
                // Rank Badge
                Container(
                  width: 32,
                  height: 32,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: rankColor != null
                        ? rankColor.withOpacity(0.2)
                        : Colors.transparent,
                    shape: BoxShape.circle,
                  ),
                  child: Text(
                    '${user.rank}',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w900,
                      color: rankColor ?? AppColors.secondaryTextLight,
                    ),
                  ),
                ),
                const SizedBox(width: 12),

                // Avatar
                CircleAvatar(
                  radius: 18,
                  backgroundColor: user.isCurrentUser
                      ? AppColors.primary
                      : AppColors.primaryLight,
                  child: Text(
                    user.name.isNotEmpty ? user.name[0] : 'U',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: user.isCurrentUser ? Colors.white : AppColors.primary,
                    ),
                  ),
                ),
                const SizedBox(width: 14),

                // User details
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        user.name,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: user.isCurrentUser
                              ? FontWeight.w800
                              : FontWeight.w600,
                        ),
                      ),
                      Text(
                        user.school,
                        style: const TextStyle(
                          fontSize: 11,
                          color: AppColors.secondaryTextLight,
                        ),
                      ),
                    ],
                  ),
                ),

                // XP and streak badge
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      '${user.xp} XP',
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w800,
                        color: AppColors.primary,
                      ),
                    ),
                    Text(
                      '🔥 ${user.streak} дн',
                      style: const TextStyle(
                        fontSize: 11,
                        color: AppColors.warning,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
