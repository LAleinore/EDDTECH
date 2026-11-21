import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../app/theme/app_colors.dart';
import '../../../core/widgets/cards.dart';
import '../../auth/domain/user_model.dart';
import '../data/admin_repository.dart';
import '../domain/teacher_application.dart';

class AdminScreen extends ConsumerStatefulWidget {
  const AdminScreen({super.key});

  @override
  ConsumerState<AdminScreen> createState() => _AdminScreenState();
}

class _AdminScreenState extends ConsumerState<AdminScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _tabController.addListener(() {
      if (_tabController.indexIsChanging) {
        ref.read(adminApplicationsProvider.notifier).reload();
        ref.read(registeredUsersProvider.notifier).reload();
      }
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(adminApplicationsProvider.notifier).reload();
      ref.read(registeredUsersProvider.notifier).reload();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _showRejectDialog(TeacherApplication app) {
    final reasonController = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        title: const Row(
          children: [
            Icon(Icons.warning_amber_rounded, color: AppColors.error),
            SizedBox(width: 8),
            Text('Отклонить заявку', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Укажите причину отклонения заявки для преподавателя ${app.fullName} (${app.school}):',
              style: const TextStyle(fontSize: 13, color: AppColors.secondaryTextLight),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: reasonController,
              maxLines: 3,
              decoration: InputDecoration(
                hintText: 'Например: не подтверждена должность в указанной школе',
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
              backgroundColor: AppColors.error,
              foregroundColor: Colors.white,
            ),
            onPressed: () {
              final reason = reasonController.text.trim().isEmpty
                  ? 'Несоответствие указанных данных школы'
                  : reasonController.text.trim();
              ref.read(adminApplicationsProvider.notifier).reject(app.id, reason);
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Заявка преподавателя ${app.fullName} отклонена'),
                  backgroundColor: AppColors.error,
                ),
              );
            },
            child: const Text('Отклонить'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final applications = ref.watch(adminApplicationsProvider);
    final registeredUsers = ref.watch(registeredUsersProvider);

    final pending = applications
        .where((a) => a.status == ApplicationStatus.pending)
        .toList();
    final approved = applications
        .where((a) => a.status == ApplicationStatus.approved)
        .toList();
    final rejected = applications
        .where((a) => a.status == ApplicationStatus.rejected)
        .toList();

    // Calculate unique schools count
    final schools = <String>{};
    for (final a in applications) {
      if (a.school.isNotEmpty) schools.add(a.school);
    }
    for (final u in registeredUsers) {
      if (u.school != null && u.school!.isNotEmpty) schools.add(u.school!);
    }

    return Scaffold(
      appBar: AppBar(
        title: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Панель Администратора',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
            ),
            Text(
              'Модерация школ, верификация учителей и реестр пользователей',
              style: TextStyle(fontSize: 11, color: AppColors.secondaryTextLight),
            ),
          ],
        ),
        actions: [
          IconButton(
            tooltip: 'Обновить реестр',
            icon: const Icon(Icons.refresh_rounded),
            onPressed: () async {
              final messenger = ScaffoldMessenger.of(context);
              await ref.read(adminApplicationsProvider.notifier).reload();
              await ref.read(registeredUsersProvider.notifier).reload();
              if (mounted) {
                messenger.showSnackBar(
                  const SnackBar(
                    content: Text('Реестр аккредитаций и пользователей синхронизирован с базой'),
                    duration: Duration(seconds: 1),
                  ),
                );
              }
            },
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          labelColor: AppColors.primary,
          unselectedLabelColor: AppColors.secondaryTextLight,
          indicatorColor: AppColors.primary,
          tabs: [
            Tab(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('Заявки'),
                  if (pending.isNotEmpty) ...[
                    const SizedBox(width: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: AppColors.error,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        '${pending.length}',
                        style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ],
              ),
            ),
            Tab(text: 'Верифицированы (${approved.length})'),
            Tab(text: 'Отклоненные (${rejected.length})'),
            Tab(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('Все пользователи'),
                  const SizedBox(width: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      '${registeredUsers.length}',
                      style: const TextStyle(color: AppColors.primary, fontSize: 10, fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          // Metrics Header
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            color: Theme.of(context).cardColor,
            child: Row(
              children: [
                _buildMetricCard(
                  title: 'На проверке',
                  count: '${pending.length}',
                  icon: Icons.hourglass_top_rounded,
                  color: AppColors.warning,
                ),
                const SizedBox(width: 8),
                _buildMetricCard(
                  title: 'Одобрено',
                  count: '${approved.length}',
                  icon: Icons.verified_user_rounded,
                  color: AppColors.success,
                ),
                const SizedBox(width: 8),
                _buildMetricCard(
                  title: 'Пользователи',
                  count: '${registeredUsers.length}',
                  icon: Icons.people_alt_rounded,
                  color: AppColors.primary,
                ),
                const SizedBox(width: 8),
                _buildMetricCard(
                  title: 'Школ в базе',
                  count: '${schools.length}',
                  icon: Icons.apartment_rounded,
                  color: AppColors.primaryDark,
                ),
              ],
            ),
          ),
          const Divider(height: 1),

          // Search Field
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            child: TextField(
              onChanged: (val) => setState(() => _searchQuery = val.toLowerCase()),
              decoration: InputDecoration(
                hintText: 'Поиск по ФИО, email, школе, роли или коду TCH...',
                prefixIcon: const Icon(Icons.search, size: 20),
                isDense: true,
                contentPadding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ),

          // Tab Views
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildList(pending, isPending: true),
                _buildList(approved, isPending: false),
                _buildList(rejected, isPending: false),
                _buildUsersList(registeredUsers),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMetricCard({
    required String title,
    required String count,
    required IconData icon,
    required Color color,
  }) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 6),
        decoration: BoxDecoration(
          color: color.withOpacity(0.08),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withOpacity(0.25)),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 18),
            const SizedBox(height: 2),
            Text(
              count,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w800,
                color: color,
              ),
            ),
            Text(
              title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 9,
                color: AppColors.secondaryTextLight,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildList(List<TeacherApplication> list, {required bool isPending}) {
    final filtered = list.where((a) {
      if (_searchQuery.isEmpty) return true;
      return a.fullName.toLowerCase().contains(_searchQuery) ||
          a.school.toLowerCase().contains(_searchQuery) ||
          a.city.toLowerCase().contains(_searchQuery) ||
          a.email.toLowerCase().contains(_searchQuery) ||
          a.teacherCode.toLowerCase().contains(_searchQuery) ||
          a.subject.toLowerCase().contains(_searchQuery);
    }).toList();

    if (filtered.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              isPending ? Icons.task_alt_rounded : Icons.search_off_rounded,
              size: 48,
              color: AppColors.secondaryTextLight.withOpacity(0.5),
            ),
            const SizedBox(height: 12),
            Text(
              isPending
                  ? 'Все заявки учителей рассмотрены!'
                  : 'Записей в данном разделе не найдено',
              style: const TextStyle(color: AppColors.secondaryTextLight, fontSize: 13),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: filtered.length + (isPending ? 1 : 0),
      itemBuilder: (context, index) {
        if (isPending && index == 0) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: AppColors.warning.withOpacity(0.12),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.warning.withOpacity(0.35)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.info_outline_rounded, color: AppColors.warning, size: 20),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'В очереди модерации: ${filtered.length} заявок. Новые регистрации учителей отображаются здесь автоматически.',
                      style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                    ),
                  ),
                ],
              ),
            ),
          );
        }
        final app = isPending ? filtered[index - 1] : filtered[index];
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: _buildApplicationCard(app, isPending: isPending),
        );
      },
    );
  }

  Widget _buildApplicationCard(TeacherApplication app, {required bool isPending}) {
    Color statusColor;
    String statusText;

    switch (app.status) {
      case ApplicationStatus.approved:
        statusColor = AppColors.success;
        statusText = 'Верифицирован';
        break;
      case ApplicationStatus.rejected:
        statusColor = AppColors.error;
        statusText = 'Отклонен';
        break;
      case ApplicationStatus.pending:
        statusColor = AppColors.warning;
        statusText = 'На рассмотрении';
        break;
    }

    return AppCard(
      padding: const EdgeInsets.all(16),
      border: isPending ? Border.all(color: AppColors.warning.withOpacity(0.5), width: 1.5) : null,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CircleAvatar(
                radius: 20,
                backgroundColor: AppColors.primary.withOpacity(0.12),
                child: Text(
                  app.fullName.isNotEmpty ? app.fullName[0].toUpperCase() : 'T',
                  style: const TextStyle(
                    color: AppColors.primary,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      app.fullName,
                      style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      app.email,
                      style: const TextStyle(fontSize: 12, color: AppColors.secondaryTextLight),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: statusColor.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: statusColor.withOpacity(0.3)),
                ),
                child: Text(
                  statusText,
                  style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: statusColor),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Divider(height: 1),
          const SizedBox(height: 10),

          // School & City
          Row(
            children: [
              const Icon(Icons.apartment_rounded, size: 16, color: AppColors.secondaryTextLight),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  '${app.school} (${app.city})',
                  style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),

          // Subject & Teacher ID Code
          Row(
            children: [
              const Icon(Icons.menu_book_rounded, size: 16, color: AppColors.teacherAccent),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  'Предмет: ${app.subject}',
                  style: const TextStyle(fontSize: 12, color: AppColors.secondaryTextLight),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.grey.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  app.teacherCode,
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
            ],
          ),

          if (app.rejectionReason != null) ...[
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.errorLight,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  const Icon(Icons.info_outline, size: 16, color: AppColors.error),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      'Причина отказа: ${app.rejectionReason}',
                      style: const TextStyle(fontSize: 11, color: AppColors.error),
                    ),
                  ),
                ],
              ),
            ),
          ],

          if (isPending) ...[
            const SizedBox(height: 14),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.error,
                      side: const BorderSide(color: AppColors.error),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                    onPressed: () => _showRejectDialog(app),
                    icon: const Icon(Icons.close_rounded, size: 16),
                    label: const Text('Отклонить'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.success,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                    onPressed: () {
                      ref.read(adminApplicationsProvider.notifier).approve(app.id);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Преподаватель ${app.fullName} успешно верифицирован! Доступ открыт.'),
                          backgroundColor: AppColors.success,
                        ),
                      );
                    },
                    icon: const Icon(Icons.check_rounded, size: 16),
                    label: const Text('Одобрить доступ'),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  // 4th Tab: ALL REGISTERED USERS OF THE PLATFORM
  Widget _buildUsersList(List<UserModel> users) {
    final filtered = users.where((u) {
      if (_searchQuery.isEmpty) return true;
      final q = _searchQuery.toLowerCase();
      return u.name.toLowerCase().contains(q) ||
          u.email.toLowerCase().contains(q) ||
          (u.school != null && u.school!.toLowerCase().contains(q)) ||
          (u.city != null && u.city!.toLowerCase().contains(q)) ||
          u.role.title.toLowerCase().contains(q) ||
          (u.teacherCode != null && u.teacherCode!.toLowerCase().contains(q));
    }).toList();

    if (filtered.isEmpty) {
      return const Center(
        child: Text(
          'Пользователи не найдены',
          style: TextStyle(color: AppColors.secondaryTextLight),
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: filtered.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final u = filtered[index];
        return _buildUserCard(u);
      },
    );
  }

  Widget _buildUserCard(UserModel u) {
    Color roleColor;
    IconData roleIcon;

    switch (u.role) {
      case UserRole.admin:
        roleColor = AppColors.primaryDark;
        roleIcon = Icons.security_rounded;
        break;
      case UserRole.teacher:
        roleColor = AppColors.teacherAccent;
        roleIcon = Icons.school_rounded;
        break;
      case UserRole.learner:
        roleColor = AppColors.inclusiveAccent;
        roleIcon = Icons.accessibility_new_rounded;
        break;
      case UserRole.student:
        roleColor = AppColors.primary;
        roleIcon = Icons.person_rounded;
        break;
    }

    final isTeacher = u.role == UserRole.teacher;

    return AppCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CircleAvatar(
                radius: 20,
                backgroundColor: roleColor.withOpacity(0.12),
                child: Icon(roleIcon, color: roleColor, size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      u.name,
                      style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      u.email,
                      style: const TextStyle(fontSize: 12, color: AppColors.secondaryTextLight),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: roleColor.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: roleColor.withOpacity(0.3)),
                ),
                child: Text(
                  u.role.title,
                  style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: roleColor),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          const Divider(height: 1),
          const SizedBox(height: 8),

          if (u.school != null && u.school!.isNotEmpty) ...[
            Row(
              children: [
                const Icon(Icons.apartment_rounded, size: 15, color: AppColors.secondaryTextLight),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    '${u.school!}${u.city != null && u.city!.isNotEmpty ? " • ${u.city!}" : ""}',
                    style: const TextStyle(fontSize: 12),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
          ],

          if (isTeacher) ...[
            Row(
              children: [
                const Icon(Icons.verified_outlined, size: 15, color: AppColors.teacherAccent),
                const SizedBox(width: 6),
                Text(
                  'Статус аккредитации: ',
                  style: const TextStyle(fontSize: 12, color: AppColors.secondaryTextLight),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: (u.isTeacherVerified ? AppColors.success : AppColors.warning).withOpacity(0.15),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    u.isTeacherVerified ? 'Верифицирован' : 'Ожидает одобрения',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: u.isTeacherVerified ? AppColors.success : AppColors.warning,
                    ),
                  ),
                ),
                const Spacer(),
                if (u.teacherCode != null)
                  Text(
                    u.teacherCode!,
                    style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.secondaryTextLight),
                  ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}
