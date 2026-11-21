import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../app/theme/app_colors.dart';
import '../../../core/widgets/cards.dart';
import '../../admin/data/admin_repository.dart';
import '../../admin/domain/teacher_application.dart';
import '../../auth/data/auth_repository.dart';
import '../../auth/domain/user_model.dart';
import '../../mindcare/data/anonymous_chat_repository.dart';
import '../../mindcare/domain/anonymous_message_model.dart';

class TeacherPortalScreen extends ConsumerStatefulWidget {
  const TeacherPortalScreen({super.key});

  @override
  ConsumerState<TeacherPortalScreen> createState() => _TeacherPortalScreenState();
}

class _TeacherPortalScreenState extends ConsumerState<TeacherPortalScreen> {
  final _schoolController = TextEditingController();
  final _teacherCodeController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    _schoolController.dispose();
    _teacherCodeController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(authNotifierProvider).user;
    final applications = ref.watch(adminApplicationsProvider);

    // Check if this teacher is approved in the accreditation registry
    final currentApp = applications.firstWhere(
      (a) =>
          a.email == user?.email ||
          (user?.teacherCode != null && a.teacherCode == user?.teacherCode),
      orElse: () => TeacherApplication(
        id: 'mock-curr',
        fullName: user?.name ?? 'Преподаватель',
        email: user?.email ?? '',
        school: user?.school ?? 'Назарбаев Интеллектуальная школа (ФМН)',
        city: user?.city ?? 'г. Астана',
        subject: user?.subject ?? 'Математика',
        teacherCode: user?.teacherCode ?? 'TCH-2026-AST',
        status: ApplicationStatus.approved,
        appliedAt: DateTime.now(),
      ),
    );

    final isApproved = currentApp.status == ApplicationStatus.approved;
    final isPending = currentApp.status == ApplicationStatus.pending;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Платформа Учителей • Daryn Ustaz',
          style: TextStyle(fontSize: 17, fontWeight: FontWeight.w800),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Teacher Accreditation Header Badge
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: isApproved
                      ? [AppColors.teacherAccent, AppColors.primary]
                      : [Colors.orange.shade800, Colors.deepOrange],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(18),
                boxShadow: [
                  BoxShadow(
                    color: (isApproved ? AppColors.teacherAccent : Colors.orange)
                        .withOpacity(0.3),
                    blurRadius: 16,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              isApproved ? Icons.verified_rounded : Icons.pending_actions_rounded,
                              color: Colors.white,
                              size: 14,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              isApproved
                                  ? 'ВЕРИФИЦИРОВАННЫЙ ПЕДАГОГ'
                                  : 'АККРЕДИТАЦИЯ НА РАССМОТРЕНИИ',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const Spacer(),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.25),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          currentApp.teacherCode,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.8,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    currentApp.fullName,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(Icons.apartment_rounded, color: Colors.white70, size: 14),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          '${currentApp.school} (${currentApp.city})',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 2),
                  Row(
                    children: [
                      const Icon(Icons.menu_book_rounded, color: Colors.white70, size: 14),
                      const SizedBox(width: 4),
                      Text(
                        'Предмет: ${currentApp.subject}',
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            if (isPending) ...[
              // Verification Warning Card
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.warning.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.warning.withOpacity(0.4)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Row(
                      children: [
                        Icon(Icons.security_update_warning_rounded, color: AppColors.warning),
                        SizedBox(width: 8),
                        Text(
                          'Проверка принадлежности к школе',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            color: AppColors.warning,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Ваша заявка направлена Администрации образовательного округа. Мы сверяем данные преподавателя с реестром школы для предотвращения несанкционированного доступа к генераторам экзаменов.',
                      style: TextStyle(fontSize: 13, height: 1.4),
                    ),
                    const SizedBox(height: 12),
                    ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.warning,
                        foregroundColor: Colors.black87,
                      ),
                      onPressed: () {
                        // Fast test approval
                        ref.read(adminApplicationsProvider.notifier).approve(currentApp.id);
                        setState(() {});
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Статус обновлен: Одобрено Администратором!'),
                            backgroundColor: AppColors.success,
                          ),
                        );
                      },
                      icon: const Icon(Icons.verified, size: 18),
                      label: const Text('Одобрить через Админку (Тест)'),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
            ],

            // Professional Teacher Workstation
            const Text(
              'Инструменты планирования и дидактики',
              style: TextStyle(fontSize: 17, fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 12),

            _buildToolCard(
              title: 'Генератор поурочных планов (ҚМЖ / КСП)',
              description: 'Создание календарно-тематических планов по стандартам ГОСО РК и критериям Блума.',
              icon: Icons.menu_book_rounded,
              color: AppColors.teacherAccent,
              onTap: () => context.push('/teacher/lesson-generator'),
            ),
            const SizedBox(height: 12),

            _buildToolCard(
              title: 'Конструктор критериальных тестов (БЖБ / ТЖБ)',
              description: 'Формирование тестов с 4 вариантами, ключами ответов и шкалой оценивания.',
              icon: Icons.quiz_rounded,
              color: AppColors.primaryDark,
              onTap: () => context.push('/teacher/quiz-generator'),
            ),
            const SizedBox(height: 12),

            _buildToolCard(
              title: 'Объяснение сложных концепций',
              description: 'Адаптация трудных математических и естественнонаучных тем на понятный язык с метафорами.',
              icon: Icons.lightbulb_outline_rounded,
              color: AppColors.warning,
              onTap: () => context.push('/teacher/explain'),
            ),
            const SizedBox(height: 12),

            _buildToolCard(
              title: 'Архив учебных материалов',
              description: 'История ранее сгенерированных уроков, тестов и возможность повторной выгрузки.',
              icon: Icons.folder_open_rounded,
              color: AppColors.success,
              onTap: () => context.push('/teacher/history'),
            ),
            const SizedBox(height: 24),

            // ASSIGNED STUDENTS SECTION (Назначенные ученики)
            _buildAssignedStudentsSection(context, user),
            const SizedBox(height: 24),

            // ANONYMOUS STUDENT INQUIRIES SECTION (Анонимные обращения)
            _buildAnonymousMessagesSection(context, user),
          ],
        ),
      ),
    );
  }

  Widget _buildAssignedStudentsSection(BuildContext context, UserModel? teacher) {
    final mentorship = ref.watch(teacherMentorshipProvider);
    final allUsers = ref.watch(registeredUsersProvider);

    final teacherEmail = teacher?.email.toLowerCase() ?? 'teacher@edumind.ai';
    final assignedEmails = mentorship[teacherEmail] ??
        mentorship['teacher@edumind.ai'] ??
        ['student@edumind.ai', 'learner@edumind.ai'];

    final assignedStudents = allUsers
        .where((u) => assignedEmails.contains(u.email.toLowerCase()))
        .toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Row(
              children: [
                Icon(Icons.supervised_user_circle_rounded, color: AppColors.teacherAccent, size: 22),
                SizedBox(width: 8),
                Text(
                  'Мои подопечные ученики',
                  style: TextStyle(fontSize: 17, fontWeight: FontWeight.w800),
                ),
              ],
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: AppColors.teacherAccent.withOpacity(0.12),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                '${assignedStudents.length} учащихся',
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  color: AppColors.teacherAccent,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        const Text(
          'Список студентов, закрепленных за вами Администрацией платформы. Отслеживайте успеваемость, пройденные темы и тесты в реальном времени.',
          style: TextStyle(fontSize: 12, color: AppColors.secondaryTextLight, height: 1.35),
        ),
        const SizedBox(height: 12),

        if (assignedStudents.isEmpty)
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.grey.withOpacity(0.08),
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Center(
              child: Text(
                'Ученики еще не закреплены. Администратор может назначить учащихся через Панель Администратора.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 12, color: AppColors.secondaryTextLight),
              ),
            ),
          )
        else
          ...assignedStudents.map((st) => _buildStudentItemCard(context, st)),
      ],
    );
  }

  Widget _buildStudentItemCard(BuildContext context, UserModel st) {
    final record = StudentAcademicRecord.getRecordForUser(st);

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: AppCard(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 20,
                  backgroundColor: AppColors.primary.withOpacity(0.12),
                  child: Text(
                    st.name.isNotEmpty ? st.name[0].toUpperCase() : 'У',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary,
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
                        st.name,
                        style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                      ),
                      Text(
                        '${st.email} • ${st.school ?? "Лицей №1"}',
                        style: const TextStyle(fontSize: 11, color: AppColors.secondaryTextLight),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: AppColors.warning.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.local_fire_department_rounded, size: 14, color: AppColors.warning),
                      const SizedBox(width: 2),
                      Text(
                        '${record.streak} дн.',
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: AppColors.warning,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            const Divider(height: 1),
            const SizedBox(height: 10),

            // Academic Progress Preview
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Пройдено тем', style: TextStyle(fontSize: 10, color: AppColors.secondaryTextLight)),
                    Text('${record.passedTopics.length} тем', style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Сдано тестов', style: TextStyle(fontSize: 10, color: AppColors.secondaryTextLight)),
                    Text('${record.testScores.length} среза', style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Опыт XP', style: TextStyle(fontSize: 10, color: AppColors.secondaryTextLight)),
                    Text('${record.xp} XP', style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppColors.primary)),
                  ],
                ),
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.teacherAccent,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    minimumSize: const Size(0, 34),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  onPressed: () => _showStudentProgressSheet(context, st, record),
                  icon: const Icon(Icons.analytics_outlined, size: 14),
                  label: const Text('Успеваемость', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showStudentProgressSheet(
    BuildContext context,
    UserModel st,
    StudentAcademicRecord record,
  ) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
      ),
      builder: (ctx) => DraggableScrollableSheet(
        initialChildSize: 0.8,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        expand: false,
        builder: (ctx, scrollController) => SingleChildScrollView(
          controller: scrollController,
          padding: const EdgeInsets.all(22),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey.withOpacity(0.4),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              Row(
                children: [
                  CircleAvatar(
                    radius: 24,
                    backgroundColor: AppColors.teacherAccent.withOpacity(0.15),
                    child: const Icon(Icons.school_rounded, color: AppColors.teacherAccent, size: 26),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Табель успеваемости: ${st.name}',
                          style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w800),
                        ),
                        Text(
                          '${st.email} • ${st.school ?? "Лицей №1"}',
                          style: const TextStyle(fontSize: 12, color: AppColors.secondaryTextLight),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 18),

              // Metrics Banner
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: AppColors.teacherAccent.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: AppColors.teacherAccent.withOpacity(0.2)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    Column(
                      children: [
                        const Icon(Icons.local_fire_department_rounded, color: AppColors.warning, size: 20),
                        const SizedBox(height: 2),
                        Text('${record.streak} дн.', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                        const Text('Стрик', style: TextStyle(fontSize: 10, color: AppColors.secondaryTextLight)),
                      ],
                    ),
                    Column(
                      children: [
                        const Icon(Icons.bolt_rounded, color: AppColors.primary, size: 20),
                        const SizedBox(height: 2),
                        Text('${record.xp}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                        const Text('Баллы XP', style: TextStyle(fontSize: 10, color: AppColors.secondaryTextLight)),
                      ],
                    ),
                    Column(
                      children: [
                        const Icon(Icons.check_circle_rounded, color: AppColors.success, size: 20),
                        const SizedBox(height: 2),
                        const Text('92%', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                        const Text('Ср. балл', style: TextStyle(fontSize: 10, color: AppColors.secondaryTextLight)),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Test Scores
              const Text(
                'Сданные тесты и критериальное оценивание (БЖБ/ТЖБ)',
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              ...record.testScores.map(
                (t) => Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Theme.of(context).cardColor,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey.withOpacity(0.2)),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(t['title']!, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
                            const SizedBox(height: 2),
                            Text('Дата сдачи: ${t['date']}', style: const TextStyle(fontSize: 11, color: AppColors.secondaryTextLight)),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppColors.success.withOpacity(0.12),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          t['score']!,
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: AppColors.success),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 18),

              // Completed & Current Topics
              const Text(
                'Изученные темы и прогресс по курсам',
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              ...record.passedTopics.map(
                (p) => Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Theme.of(context).cardColor,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey.withOpacity(0.2)),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withOpacity(0.1),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.bookmark_rounded, size: 16, color: AppColors.primary),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('${p['subject']}: ${p['topic']}', style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                            const SizedBox(height: 2),
                            Text('Статус: ${p['status']} (${p['progress']})', style: const TextStyle(fontSize: 11, color: AppColors.secondaryTextLight)),
                          ],
                        ),
                      ),
                      Text(
                        p['progress']!,
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: AppColors.primary),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAnonymousMessagesSection(BuildContext context, UserModel? teacher) {
    final messages = ref.watch(anonymousChatProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Row(
              children: [
                Icon(Icons.mark_chat_unread_rounded, color: AppColors.warning, size: 22),
                SizedBox(width: 8),
                Text(
                  'Анонимные обращения учеников',
                  style: TextStyle(fontSize: 17, fontWeight: FontWeight.w800),
                ),
              ],
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: AppColors.warning.withOpacity(0.15),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                '${messages.length} сообщений',
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  color: AppColors.warning,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        const Text(
          'Ученики могут анонимно написать о том, что их беспокоит (оценки, буллинг, перегрузка). Отвечайте им с поддержкой.',
          style: TextStyle(fontSize: 12, color: AppColors.secondaryTextLight, height: 1.35),
        ),
        const SizedBox(height: 12),

        if (messages.isEmpty)
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.grey.withOpacity(0.08),
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Center(
              child: Text(
                'Обращений от учеников пока нет.',
                style: TextStyle(fontSize: 12, color: AppColors.secondaryTextLight),
              ),
            ),
          )
        else
          ...messages.map((msg) => _buildAnonymousMessageTeacherCard(context, msg, teacher?.name ?? 'Учитель-наставник')),
      ],
    );
  }

  Widget _buildAnonymousMessageTeacherCard(
    BuildContext context,
    AnonymousMessageModel msg,
    String teacherName,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: AppCard(
        padding: const EdgeInsets.all(16),
        border: msg.isReplied ? null : Border.all(color: AppColors.warning.withOpacity(0.5), width: 1.5),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: AppColors.warning.withOpacity(0.12),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        msg.studentAlias,
                        style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.warning),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      msg.category,
                      style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.secondaryTextLight),
                    ),
                  ],
                ),
                Text(
                  '${msg.timestamp.hour.toString().padLeft(2, '0')}:${msg.timestamp.minute.toString().padLeft(2, '0')}',
                  style: const TextStyle(fontSize: 11, color: AppColors.secondaryTextLight),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              msg.content,
              style: const TextStyle(fontSize: 13, height: 1.4),
            ),
            const SizedBox(height: 10),

            if (msg.isReplied) ...[
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppColors.success.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: AppColors.success.withOpacity(0.3)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Ваш ответ (${msg.teacherName ?? teacherName}):',
                      style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.success),
                    ),
                    const SizedBox(height: 4),
                    Text(msg.teacherReply!, style: const TextStyle(fontSize: 12)),
                  ],
                ),
              ),
            ] else ...[
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.teacherAccent,
                  foregroundColor: Colors.white,
                  minimumSize: const Size(double.infinity, 38),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
                onPressed: () => _showTeacherReplyDialog(context, msg, teacherName),
                icon: const Icon(Icons.reply_rounded, size: 16),
                label: const Text('Ответить ученику анонимно', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
              ),
            ],
          ],
        ),
      ),
    );
  }

  void _showTeacherReplyDialog(
    BuildContext context,
    AnonymousMessageModel msg,
    String teacherName,
  ) {
    final replyController = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        title: Row(
          children: [
            const Icon(Icons.reply_rounded, color: AppColors.teacherAccent),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                'Ответ для ${msg.studentAlias}',
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Обращение: "${msg.content}"',
              style: const TextStyle(fontSize: 12, fontStyle: FontStyle.italic, color: AppColors.secondaryTextLight),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: replyController,
              maxLines: 4,
              decoration: InputDecoration(
                hintText: 'Напишите слова поддержки или предложите решение...',
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
              backgroundColor: AppColors.teacherAccent,
              foregroundColor: Colors.white,
            ),
            onPressed: () {
              final rep = replyController.text.trim();
              if (rep.isEmpty) return;
              ref.read(anonymousChatProvider.notifier).replyTeacherMessage(
                    messageId: msg.id,
                    reply: rep,
                    teacherName: teacherName,
                  );
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Ответ успешно отправлен ученику!'),
                  backgroundColor: AppColors.success,
                ),
              );
            },
            child: const Text('Отправить ответ'),
          ),
        ],
      ),
    );
  }

  Widget _buildToolCard({
    required String title,
    required String description,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return AppCard(
      padding: const EdgeInsets.all(16),
      onTap: onTap,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
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
                  style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.secondaryTextLight,
                    height: 1.35,
                  ),
                ),
              ],
            ),
          ),
          const Icon(Icons.arrow_forward_ios_rounded, size: 16, color: AppColors.secondaryTextLight),
        ],
      ),
    );
  }
}
