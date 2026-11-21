import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../auth/data/auth_repository.dart';
import '../../auth/domain/user_model.dart';
import '../domain/teacher_application.dart';

final adminApplicationsProvider =
    StateNotifierProvider<AdminApplicationsNotifier, List<TeacherApplication>>((
      ref,
    ) {
      final prefs = ref.watch(sharedPreferencesProvider);
      return AdminApplicationsNotifier(prefs, ref);
    });

final registeredUsersProvider =
    StateNotifierProvider<RegisteredUsersNotifier, List<UserModel>>((ref) {
      final prefs = ref.watch(sharedPreferencesProvider);
      return RegisteredUsersNotifier(prefs);
    });

class AdminApplicationsNotifier
    extends StateNotifier<List<TeacherApplication>> {
  final SharedPreferences _prefs;
  final Ref _ref;

  static const String _storageKey = 'admin_teacher_applications_v2';

  AdminApplicationsNotifier(this._prefs, this._ref)
      : super(_loadInitial(_prefs));

  static List<TeacherApplication> _loadInitial(SharedPreferences prefs) {
    final raw = prefs.getString(_storageKey);
    if (raw != null && raw.isNotEmpty) {
      try {
        final decoded = json.decode(raw) as List;
        return decoded
            .map((e) => TeacherApplication.fromMap(Map<String, dynamic>.from(e)))
            .toList();
      } catch (_) {}
    }
    return _defaultApplications;
  }

  static final List<TeacherApplication> _defaultApplications = [
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

  Future<void> reload() async {
    try {
      await _prefs.reload();
      final reloaded = _loadInitial(_prefs);
      state = reloaded;
    } catch (_) {}
  }

  Future<void> _persist() async {
    final encoded = json.encode(state.map((a) => a.toMap()).toList());
    await _prefs.setString(_storageKey, encoded);
  }

  Future<void> approve(String id) async {
    TeacherApplication? approvedApp;

    state = [
      for (final app in state)
        if (app.id == id) ...[
          (() {
            final updated = app.copyWith(
              status: ApplicationStatus.approved,
              reviewedBy: 'Администратор',
            );
            approvedApp = updated;
            return updated;
          })(),
        ] else
          app,
    ];
    await _persist();

    if (approvedApp != null) {
      await _ref
          .read(registeredUsersProvider.notifier)
          .updateUserVerification(approvedApp!.email, true, 'approved');
    }
  }

  Future<void> reject(String id, String reason) async {
    TeacherApplication? rejectedApp;

    state = [
      for (final app in state)
        if (app.id == id) ...[
          (() {
            final updated = app.copyWith(
              status: ApplicationStatus.rejected,
              rejectionReason: reason,
              reviewedBy: 'Администратор',
            );
            rejectedApp = updated;
            return updated;
          })(),
        ] else
          app,
    ];
    await _persist();

    if (rejectedApp != null) {
      await _ref
          .read(registeredUsersProvider.notifier)
          .updateUserVerification(rejectedApp!.email, false, 'rejected', reason);
    }
  }

  Future<void> submitNewApplication({
    required String fullName,
    required String email,
    required String school,
    required String city,
    required String subject,
    required String teacherCode,
  }) async {
    try {
      await _prefs.reload();
    } catch (_) {}

    final currentList = _loadInitial(_prefs);
    final cleanEmail = email.trim().toLowerCase();
    final cleanCode = teacherCode.trim().toUpperCase();

    final newApp = TeacherApplication(
      id: 'app-${DateTime.now().millisecondsSinceEpoch}',
      fullName: fullName.trim(),
      email: email.trim(),
      school: school.trim(),
      city: city.trim(),
      subject: subject.trim(),
      teacherCode: cleanCode,
      status: ApplicationStatus.pending,
      appliedAt: DateTime.now(),
    );

    // Filter out previous app for this email or code
    final filtered = currentList.where((a) =>
      a.email.trim().toLowerCase() != cleanEmail &&
      a.teacherCode.trim().toUpperCase() != cleanCode
    ).toList();

    state = [newApp, ...filtered];
    await _persist();
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

class RegisteredUsersNotifier extends StateNotifier<List<UserModel>> {
  final SharedPreferences _prefs;

  static const String _usersStorageKey = 'admin_registered_users_registry_v1';

  RegisteredUsersNotifier(this._prefs) : super(_loadInitialUsers(_prefs));

  static List<UserModel> _loadInitialUsers(SharedPreferences prefs) {
    final raw = prefs.getString(_usersStorageKey);
    if (raw != null && raw.isNotEmpty) {
      try {
        final decoded = json.decode(raw) as List;
        return decoded
            .map((e) => UserModel.fromMap(Map<String, dynamic>.from(e)))
            .toList();
      } catch (_) {}
    }
    return [
      AuthRepository.adminUser,
      AuthRepository.teacherDemoUser,
      AuthRepository.studentDemoUser,
      AuthRepository.learnerDemoUser,
    ];
  }

  Future<void> reload() async {
    try {
      await _prefs.reload();
      final loaded = _loadInitialUsers(_prefs);
      state = loaded;
    } catch (_) {}
  }

  Future<void> _persist() async {
    final encoded = json.encode(state.map((u) => u.toMap()).toList());
    await _prefs.setString(_usersStorageKey, encoded);
  }

  Future<void> addUser(UserModel user) async {
    try {
      await _prefs.reload();
    } catch (_) {}

    final currentUsers = _loadInitialUsers(_prefs);
    final cleanEmail = user.email.trim().toLowerCase();
    final filtered = currentUsers.where((u) => u.email.trim().toLowerCase() != cleanEmail).toList();

    state = [user, ...filtered];
    await _persist();
  }

  Future<void> updateUserVerification(
    String emailOrCode,
    bool isVerified,
    String status, [
    String? reason,
  ]) async {
    final clean = emailOrCode.trim().toLowerCase();
    state = [
      for (final u in state)
        if (u.email.toLowerCase() == clean ||
            (u.teacherCode != null && u.teacherCode!.toLowerCase() == clean))
          u.copyWith(
            isTeacherVerified: isVerified,
            teacherStatus: status,
          )
        else
          u,
    ];
    await _persist();
  }
}
