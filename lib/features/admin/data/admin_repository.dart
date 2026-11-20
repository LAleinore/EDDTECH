import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../domain/teacher_application.dart';

final adminApplicationsProvider =
    StateNotifierProvider<AdminApplicationsNotifier, List<TeacherApplication>>((
      ref,
    ) {
      return AdminApplicationsNotifier();
    });

class AdminApplicationsNotifier
    extends StateNotifier<List<TeacherApplication>> {
  AdminApplicationsNotifier() : super(_initialApplications);

  static final List<TeacherApplication> _initialApplications = [
    TeacherApplication(
      id: 'app-001',
      fullName: 'Айгүл Серікқызы Касымова',
      email: 'aigul.kasymova@nis.edu.kz',
      school: 'Назарбаев Интеллектуальная школа (ФМН)',
      city: 'г. Астана',
      subject: 'Математика и Алгебра',
      teacherCode: 'TCH-2026-AST',
      status: ApplicationStatus.approved,
      appliedAt: DateTime.now().subtract(const Duration(days: 3)),
      reviewedBy: 'Администратор системы',
    ),
    TeacherApplication(
      id: 'app-002',
      fullName: 'Ерлан Муратович Сапаров',
      email: 'erlan.saparov@fizmat.kz',
      school: 'Республиканская физико-математическая школа (РФМШ)',
      city: 'г. Алматы',
      subject: 'Физика и Астрономия',
      teacherCode: 'TCH-7842-ALM',
      status: ApplicationStatus.pending,
      appliedAt: DateTime.now().subtract(const Duration(hours: 4)),
    ),
    TeacherApplication(
      id: 'app-003',
      fullName: 'Светлана Борисовна Ким',
      email: 'kim.sb@lyceum134.kz',
      school: 'Школа-лицей №134',
      city: 'г. Алматы',
      subject: 'Информатика и Робототехника',
      teacherCode: 'TCH-5412-ALM',
      status: ApplicationStatus.pending,
      appliedAt: DateTime.now().subtract(const Duration(hours: 12)),
    ),
    TeacherApplication(
      id: 'app-004',
      fullName: 'Нурлан Канатович Байжанов',
      email: 'nurlan.b@gymnasium1.kz',
      school: 'Гимназия №1 им. А. Бокейханова',
      city: 'г. Караганда',
      subject: 'История Казахстана',
      teacherCode: 'TCH-9130-KRG',
      status: ApplicationStatus.pending,
      appliedAt: DateTime.now().subtract(const Duration(days: 1)),
    ),
  ];

  void approve(String id) {
    state = [
      for (final app in state)
        if (app.id == id)
          app.copyWith(
            status: ApplicationStatus.approved,
            reviewedBy: 'Администратор',
          )
        else
          app,
    ];
  }

  void reject(String id, String reason) {
    state = [
      for (final app in state)
        if (app.id == id)
          app.copyWith(
            status: ApplicationStatus.rejected,
            rejectionReason: reason,
            reviewedBy: 'Администратор',
          )
        else
          app,
    ];
  }

  void submitNewApplication({
    required String fullName,
    required String email,
    required String school,
    required String city,
    required String subject,
    required String teacherCode,
  }) {
    final newApp = TeacherApplication(
      id: 'app-${DateTime.now().millisecondsSinceEpoch}',
      fullName: fullName,
      email: email,
      school: school,
      city: city,
      subject: subject,
      teacherCode: teacherCode,
      status: ApplicationStatus.pending,
      appliedAt: DateTime.now(),
    );

    state = [newApp, ...state];
  }

  bool isTeacherApproved(String emailOrCode) {
    final clean = emailOrCode.trim().toLowerCase();
    return state.any(
      (app) =>
          (app.email.toLowerCase() == clean ||
              app.teacherCode.toLowerCase() == clean) &&
          app.status == ApplicationStatus.approved,
    );
  }
}
