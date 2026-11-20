import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../app/theme/app_colors.dart';
import '../../../core/widgets/cards.dart';
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
    _tabController = TabController(length: 3, vsync: this);
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

    final pending = applications
        .where((a) => a.status == ApplicationStatus.pending)
        .toList();
    final approved = applications
        .where((a) => a.status == ApplicationStatus.approved)
        .toList();
    final rejected = applications
        .where((a) => a.status == ApplicationStatus.rejected)
        .toList();

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
              'Модерация и верификация школ и преподавателей',
              style: TextStyle(fontSize: 11, color: AppColors.secondaryTextLight),
            ),
          ],
        ),
        actions: [
          IconButton(
            tooltip: 'Обновить реестр',
            icon: const Icon(Icons.refresh_rounded),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Реестр аккредитаций обновлен'),
                  duration: Duration(seconds: 1),
                ),
              );
            },
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          labelColor: AppColors.primary,
          unselectedLabelColor: AppColors.secondaryTextLight,
          indicatorColor: AppColors.primary,
          tabs: [
            Tab(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
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
          ],
        ),
      ),
      body: Column(
        children: [
          // Metrics Header
          Container(
            padding: const EdgeInsets.all(16),
            color: Theme.of(context).cardColor,
            child: Row(
              children: [
                _buildMetricCard(
                  title: 'На проверке',
                  count: '${pending.length}',
                  icon: Icons.hourglass_top_rounded,
                  color: AppColors.warning,
                ),
                const SizedBox(width: 10),
                _buildMetricCard(
                  title: 'Одобрено',
                  count: '${approved.length}',
                  icon: Icons.verified_user_rounded,
                  color: AppColors.success,
                ),
                const SizedBox(width: 10),
                _buildMetricCard(
                  title: 'Школ в базе',
                  count: '14',
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
                hintText: 'Поиск по ФИО, школе, коду TCH...',
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
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
        decoration: BoxDecoration(
          color: color.withOpacity(0.08),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withOpacity(0.25)),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 20),
            const SizedBox(height: 4),
            Text(
              count,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: color,
              ),
            ),
            Text(
              title,
              style: const TextStyle(
                fontSize: 10,
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
          a.teacherCode.toLowerCase().contains(_searchQuery);
    }).toList();

    if (filtered.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.inbox_outlined, size: 48, color: Colors.grey.shade400),
            const SizedBox(height: 8),
            const Text(
              'Заявок в этой категории нет',
              style: TextStyle(color: AppColors.secondaryTextLight, fontSize: 14),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      itemCount: filtered.length,
      itemBuilder: (ctx, i) {
        final app = filtered[i];
        return _buildTeacherCard(app, isPending);
      },
    );
  }

  Widget _buildTeacherCard(TeacherApplication app, bool isPending) {
    Color statusColor;
    switch (app.status) {
      case ApplicationStatus.approved:
        statusColor = AppColors.success;
        break;
      case ApplicationStatus.rejected:
        statusColor = AppColors.error;
        break;
      case ApplicationStatus.pending:
        statusColor = AppColors.warning;
        break;
    }

    return AppCard(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CircleAvatar(
                radius: 20,
                backgroundColor: AppColors.primary.withOpacity(0.12),
                child: const Icon(
                  Icons.person_rounded,
                  color: AppColors.primary,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      app.fullName,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      app.email,
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.secondaryTextLight,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: statusColor.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: statusColor, width: 0.8),
                ),
                child: Text(
                  app.status.title,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: statusColor,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Divider(height: 1),
          const SizedBox(height: 10),

          // School & City Details
          Row(
            children: [
              const Icon(Icons.apartment_rounded, size: 16, color: AppColors.primaryDark),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  '${app.school} (${app.city})',
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
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
                          content: Text('Преподаватель ${app.fullName} успешно верифицирован!'),
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
}
