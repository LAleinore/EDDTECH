import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../app/theme/app_colors.dart';
import '../../../core/widgets/cards.dart';
import '../../auth/data/auth_repository.dart';
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
    final currentUser = ref.watch(authNotifierProvider).user;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Прогресс и Достижения',
          style: TextStyle(fontWeight: FontWeight.w700),
        ),
        bottom: TabBar(
          controller: _tabController,
          labelColor: AppColors.primary,
          unselectedLabelColor: AppColors.secondaryTextLight,
          indicatorColor: AppColors.primary,
          indicatorWeight: 3,
          tabs: const [
            Tab(text: 'Стрик и Уровень'),
            Tab(text: 'Достижения'),
            Tab(text: 'Рейтинг'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // TAB 1: STREAK & LEVEL
          _buildStreakTab(context, streak),

          // TAB 2: ACHIEVEMENTS
          _buildAchievementsTab(context, gamification.achievements),

          // TAB 3: LEADERBOARD
          _buildLeaderboardTab(context, gamification.leaderboard, currentUser?.name),
        ],
      ),
    );
  }

  Widget _buildStreakTab(BuildContext context, StreakInfo streak) {
    const dayNames = ['Пн', 'Вт', 'Ср', 'Чт', 'Пт', 'Сб', 'Вс'];
    final todayIndex = (DateTime.now().weekday - 1) % 7;

    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      children: [
        // Clean Realistic Streak Card
        AppCard(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: AppColors.warning.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(12),
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
                          'Ударный режим: ${streak.currentStreak} ${streak.currentStreak == 1 ? "день" : (streak.currentStreak < 5 ? "дня" : "дней")}',
                          style: const TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 2),
                        const Text(
                          'Занимайтесь каждый день для сохранения непрерывного прогресса',
                          style: TextStyle(
                            fontSize: 12,
                            color: AppColors.secondaryTextLight,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 18),
              const Divider(height: 1),
              const SizedBox(height: 16),

              // Calendar Days Row
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: List.generate(7, (i) {
                  final isCompleted = streak.weekDaysCompleted[i];
                  final isToday = i == todayIndex;

                  return Column(
                    children: [
                      Text(
                        dayNames[i],
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: isToday ? FontWeight.w800 : FontWeight.w500,
                          color: isToday ? AppColors.primary : AppColors.secondaryTextLight,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        width: 34,
                        height: 34,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: isCompleted
                              ? AppColors.primary
                              : (isToday
                                  ? AppColors.primary.withOpacity(0.1)
                                  : AppColors.surfaceVariantLight),
                          border: isToday
                              ? Border.all(color: AppColors.primary, width: 1.5)
                              : null,
                        ),
                        child: Icon(
                          isCompleted ? Icons.check_rounded : Icons.circle,
                          size: isCompleted ? 18 : 6,
                          color: isCompleted
                              ? Colors.white
                              : (isToday
                                  ? AppColors.primary
                                  : AppColors.secondaryTextLight.withOpacity(0.4)),
                        ),
                      ),
                    ],
                  );
                }),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // Level & Experience Card
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
                          color: AppColors.primaryLight,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(
                          Icons.school_rounded,
                          color: AppColors.primary,
                          size: 22,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Уровень ${streak.level}',
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          Text(
                            streak.levelTitle,
                            style: const TextStyle(
                              fontSize: 12,
                              color: AppColors.secondaryTextLight,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.primaryLight,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      '${streak.totalXp} XP',
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w800,
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Прогресс до следующего уровня',
                    style: TextStyle(fontSize: 12, color: AppColors.secondaryTextLight),
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
                borderRadius: BorderRadius.circular(6),
                child: LinearProgressIndicator(
                  value: streak.progressToNextLevel,
                  minHeight: 8,
                  backgroundColor: AppColors.dividerLight,
                  valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primary),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // Clean Streak Freeze Protection (Robust Full-Width Layout)
        AppCard(
          padding: const EdgeInsets.all(18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: AppColors.mindcareAccent.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.shield_outlined,
                      color: AppColors.mindcareAccent,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Защита непрерывного стрика',
                          style: TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 15,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          streak.freezesAvailable > 0
                              ? 'В запасе: ${streak.freezesAvailable} день защиты. Если вы пропустите день, стрик сохранится.'
                              : 'Запас защиты исчерпан. Занимайтесь ежедневно для поддержания серии.',
                          style: const TextStyle(
                            fontSize: 12,
                            color: AppColors.secondaryTextLight,
                            height: 1.3,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: streak.freezesAvailable > 0
                      ? () {
                          ref.read(gamificationProvider.notifier).useFreeze();
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Защита активирована! Серия защищена на случай пропуска.'),
                            ),
                          );
                        }
                      : null,
                  icon: const Icon(Icons.ac_unit_rounded, size: 18),
                  label: Text(
                    streak.freezesAvailable > 0
                        ? 'Активировать защиту на сегодня'
                        : 'Защита уже активна',
                    style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                  ),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildAchievementsTab(BuildContext context, List<Achievement> achievements) {
    final unlockedCount = achievements.where((a) => a.isUnlocked).length;

    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      children: [
        // Summary Header Card
        AppCard(
          padding: const EdgeInsets.all(16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Открытые достижения',
                    style: TextStyle(fontSize: 12, color: AppColors.secondaryTextLight),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '$unlockedCount из ${achievements.length}',
                    style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800),
                  ),
                ],
              ),
              CircularProgressIndicator(
                value: achievements.isNotEmpty ? unlockedCount / achievements.length : 0,
                strokeWidth: 5,
                backgroundColor: AppColors.dividerLight,
                valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primary),
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),

        ...achievements.map((ach) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: AppCard(
              padding: const EdgeInsets.all(16),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: ach.isUnlocked
                          ? ach.color.withOpacity(0.12)
                          : Colors.grey.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      ach.icon,
                      color: ach.isUnlocked ? ach.color : Colors.grey,
                      size: 22,
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
                                  fontSize: 14,
                                  color: ach.isUnlocked ? null : AppColors.secondaryTextLight,
                                ),
                              ),
                            ),
                            Text(
                              '+${ach.xpReward} XP',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                                color: ach.isUnlocked ? AppColors.primary : Colors.grey,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 3),
                        Text(
                          ach.description,
                          style: const TextStyle(
                            fontSize: 12,
                            color: AppColors.secondaryTextLight,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Expanded(
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(4),
                                child: LinearProgressIndicator(
                                  value: ach.maxProgress > 0 ? ach.progress / ach.maxProgress : 0,
                                  minHeight: 5,
                                  backgroundColor: AppColors.dividerLight,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    ach.isUnlocked ? ach.color : Colors.grey,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Text(
                              ach.isUnlocked ? 'Выполнено' : '${ach.progress}/${ach.maxProgress}',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
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

  Widget _buildLeaderboardTab(
    BuildContext context,
    List<LeaderboardUser> leaderboard,
    String? currentUserName,
  ) {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      itemCount: leaderboard.length,
      itemBuilder: (context, index) {
        final student = leaderboard[index];

        return Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: AppCard(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            color: student.isCurrentUser ? AppColors.primaryLight.withOpacity(0.5) : null,
            border: student.isCurrentUser
                ? Border.all(color: AppColors.primary, width: 1.5)
                : null,
            child: Row(
              children: [
                // Rank number
                Container(
                  width: 28,
                  alignment: Alignment.center,
                  child: Text(
                    '${student.rank}',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w800,
                      color: student.rank <= 3 ? AppColors.primary : AppColors.secondaryTextLight,
                    ),
                  ),
                ),
                const SizedBox(width: 10),

                // Initials Avatar
                CircleAvatar(
                  radius: 18,
                  backgroundColor: student.isCurrentUser ? AppColors.primary : AppColors.primaryLight,
                  child: Text(
                    student.name.isNotEmpty ? student.name[0].toUpperCase() : 'У',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: student.isCurrentUser ? Colors.white : AppColors.primary,
                    ),
                  ),
                ),
                const SizedBox(width: 12),

                // Name & School
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        student.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: student.isCurrentUser ? FontWeight.w800 : FontWeight.w600,
                        ),
                      ),
                      Text(
                        student.school,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 11,
                          color: AppColors.secondaryTextLight,
                        ),
                      ),
                    ],
                  ),
                ),

                // XP Score
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      '${student.xp} XP',
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w800,
                        color: AppColors.primary,
                      ),
                    ),
                    Text(
                      '🔥 ${student.streak} дн',
                      style: const TextStyle(
                        fontSize: 11,
                        color: AppColors.secondaryTextLight,
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
