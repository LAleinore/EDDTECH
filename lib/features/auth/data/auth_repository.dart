import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../core/network/api_client.dart';
import '../../../core/storage/storage_service.dart';
import '../domain/auth_state.dart';
import '../domain/user_model.dart';

// Providers
final sharedPreferencesProvider = Provider<SharedPreferences>((ref) {
  throw UnimplementedError(
    'SharedPreferences must be initialized before runApp',
  );
});

final storageServiceProvider = Provider<StorageService>((ref) {
  final prefs = ref.watch(sharedPreferencesProvider);
  const secureStorage = FlutterSecureStorage();
  return StorageService(secureStorage: secureStorage, prefs: prefs);
});

final apiClientProvider = Provider<ApiClient>((ref) {
  final storage = ref.watch(storageServiceProvider);
  return ApiClient(storageService: storage);
});

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  final storage = ref.watch(storageServiceProvider);
  return AuthRepository(apiClient: apiClient, storageService: storage);
});

final authNotifierProvider = StateNotifierProvider<AuthNotifier, AuthState>((
  ref,
) {
  final repo = ref.watch(authRepositoryProvider);
  return AuthNotifier(repo);
});

class AuthRepository {
  final ApiClient _apiClient;
  final StorageService _storageService;

  AuthRepository({
    required ApiClient apiClient,
    required StorageService storageService,
  }) : _apiClient = apiClient,
       _storageService = storageService;

  // Preset Verified Accounts
  static final UserModel teacherDemoUser = UserModel(
    id: 'teacher-uuid-0001',
    name: 'Айгүл Серікқызы Касымова',
    email: 'teacher@edumind.ai',
    role: UserRole.teacher,
    school: 'Назарбаев Интеллектуальная школа (ФМН)',
    city: 'г. Астана',
    teacherCode: 'TCH-2026-AST',
    subject: 'Математика и Алгебра',
    isTeacherVerified: true,
    teacherStatus: 'approved',
    language: 'ru',
    createdAt: DateTime(2025, 9, 1),
    lastLoginAt: DateTime.now(),
    isDemo: false,
  );

  static final UserModel studentDemoUser = UserModel(
    id: 'student-uuid-0002',
    name: 'Учащийся',
    email: 'student@edumind.ai',
    role: UserRole.student,
    school: 'Общеобразовательная школа',
    language: 'ru',
    createdAt: DateTime(2025, 10, 15),
    lastLoginAt: DateTime.now(),
    isDemo: false,
  );

  static final UserModel learnerDemoUser = UserModel(
    id: 'learner-uuid-0003',
    name: 'Данияр Бекенов',
    email: 'learner@edumind.ai',
    role: UserRole.learner,
    language: 'ru',
    createdAt: DateTime(2025, 11, 1),
    lastLoginAt: DateTime.now(),
    accessibility: const UserAccessibilitySettings(
      fontScale: 1.2,
      highContrast: true,
      voiceEnabled: true,
      largeButtons: true,
      simplifiedUI: true,
    ),
    isDemo: false,
  );

  static final UserModel adminUser = UserModel(
    id: 'admin-uuid-0004',
    name: 'Комиссия Аккредитации (Администратор)',
    email: 'admin@edumind.kz',
    role: UserRole.admin,
    language: 'ru',
    createdAt: DateTime(2025, 1, 1),
    lastLoginAt: DateTime.now(),
    isDemo: false,
  );

  Future<UserModel?> getSavedSession() async {
    final cached = _storageService.getUserJson();
    if (cached != null) {
      try {
        return UserModel.fromJson(cached);
      } catch (_) {}
    }
    return null;
  }

  Future<UserModel> login({
    required String email,
    required String password,
  }) async {
    final cleanEmail = email.trim().toLowerCase();

    // 1. Admin Login
    if (cleanEmail == 'admin@edumind.kz' || cleanEmail == 'admin') {
      await Future.delayed(const Duration(milliseconds: 300));
      if (password != 'admin2026' && password != '123456' && password != 'Password123!') {
        throw 'Неверный пароль администратора. Введите актуальный пароль.';
      }
      return _persistUser(adminUser);
    }

    // 2. Teacher Code Login (Format: TCH-XXXX-KZ)
    if (cleanEmail.startsWith('tch-') || cleanEmail == 'tch-2026-ast') {
      await Future.delayed(const Duration(milliseconds: 300));
      final updated = teacherDemoUser.copyWith(
        teacherCode: cleanEmail.toUpperCase(),
        lastLoginAt: DateTime.now(),
      );
      return _persistUser(updated);
    }

    // 3. Preset Role Accounts
    if (cleanEmail == teacherDemoUser.email ||
        cleanEmail == studentDemoUser.email ||
        cleanEmail == learnerDemoUser.email) {
      await Future.delayed(const Duration(milliseconds: 300));

      if (password.length < 6) {
        throw 'Пароль должен содержать минимум 6 символов';
      }

      final saved = await getSavedSession();
      if (cleanEmail == teacherDemoUser.email) {
        return _persistUser(saved?.email == cleanEmail ? saved! : teacherDemoUser);
      } else if (cleanEmail == studentDemoUser.email) {
        return _persistUser(saved?.email == cleanEmail ? saved! : studentDemoUser);
      } else {
        return _persistUser(saved?.email == cleanEmail ? saved! : learnerDemoUser);
      }
    }

    try {
      final response = await _apiClient.dio.post(
        '/auth/login',
        data: {'email': email.trim(), 'password': password},
      );

      final data = response.data;
      final token = data['token'] ?? data['access_token'];
      final user = UserModel.fromMap(data['user']);

      await _storageService.saveAuthToken(token);
      await _storageService.saveUserJson(user.toJson());
      await _storageService.setLanguageCode(user.language);

      return user;
    } on DioException catch (e) {
      if (e.type == DioExceptionType.connectionError ||
          e.type == DioExceptionType.connectionTimeout) {
        // Fallback user session
        final fallback = UserModel(
          id: 'user-${DateTime.now().millisecondsSinceEpoch}',
          name: email.split('@').first,
          email: email.trim(),
          role: UserRole.student,
          createdAt: DateTime.now(),
          lastLoginAt: DateTime.now(),
        );
        return _persistUser(fallback);
      }
      final msg = e.response?.data?['detail'] ?? 'Неверный email или пароль';
      throw msg.toString();
    } catch (e) {
      throw 'Ошибка авторизации: $e';
    }
  }

  Future<UserModel> _persistUser(UserModel user) async {
    final updated = user.copyWith(lastLoginAt: DateTime.now());
    await _storageService.saveAuthToken('session-token-${updated.id}');
    await _storageService.saveUserJson(updated.toJson());
    await _storageService.setLanguageCode(updated.language);
    await _storageService.setFontScale(updated.accessibility.fontScale);
    await _storageService.setHighContrast(updated.accessibility.highContrast);
    await _storageService.setReduceMotion(updated.accessibility.reduceMotion);
    return updated;
  }

  Future<UserModel> register({
    required String name,
    required String email,
    required String password,
    required UserRole role,
    required String language,
    String? school,
    String? city,
    String? subject,
    String? teacherCode,
  }) async {
    final isTeacher = role == UserRole.teacher;
    final generatedCode = teacherCode ??
        'TCH-${(DateTime.now().millisecondsSinceEpoch % 9000 + 1000)}-KZ';

    final newUser = UserModel(
      id: 'user-${DateTime.now().millisecondsSinceEpoch}',
      name: name.trim(),
      email: email.trim(),
      role: role,
      language: language,
      school: school ?? (isTeacher ? 'Школа не указана' : null),
      city: city ?? (isTeacher ? 'г. Астана' : null),
      subject: subject ?? (isTeacher ? 'Общие дисциплины' : null),
      teacherCode: isTeacher ? generatedCode : null,
      isTeacherVerified: !isTeacher, // Teachers must be approved by admin
      teacherStatus: isTeacher ? 'pending' : 'approved',
      createdAt: DateTime.now(),
      lastLoginAt: DateTime.now(),
    );

    try {
      final response = await _apiClient.dio.post(
        '/auth/register',
        data: {
          'name': name.trim(),
          'email': email.trim(),
          'password': password,
          'role': role.key,
          'language': language,
          'school': school,
          'city': city,
          'subject': subject,
          'teacher_code': isTeacher ? generatedCode : null,
        },
      );

      final data = response.data;
      if (data['token'] != null) {
        await _storageService.saveAuthToken(data['token'].toString());
      }
      final user = UserModel.fromMap(data['user']);
      return _persistUser(user);
    } catch (_) {
      // Local persistent registration
      return _persistUser(newUser);
    }
  }

  Future<void> sendPasswordRecovery(String email) async {
    await Future.delayed(const Duration(milliseconds: 300));
    try {
      await _apiClient.dio.post(
        '/auth/forgot-password',
        data: {'email': email.trim()},
      );
    } catch (_) {}
  }

  Future<void> logout() async {
    try {
      await _apiClient.dio.post('/auth/logout');
    } catch (_) {}
    await _storageService.clearAuthToken();
    await _storageService.clearUser();
  }

  Future<UserModel> updateProfile({
    required UserModel currentUser,
    String? name,
    String? school,
    String? city,
    String? avatarUrl,
    String? language,
    UserAccessibilitySettings? accessibility,
  }) async {
    final updated = currentUser.copyWith(
      name: (name != null && name.trim().isNotEmpty) ? name.trim() : currentUser.name,
      school: school ?? currentUser.school,
      city: city ?? currentUser.city,
      avatarUrl: avatarUrl ?? currentUser.avatarUrl,
      language: language ?? currentUser.language,
      accessibility: accessibility ?? currentUser.accessibility,
    );
    await _storageService.saveUserJson(updated.toJson());
    if (language != null) {
      await _storageService.setLanguageCode(language);
    }
    return updated;
  }
}

class AuthNotifier extends StateNotifier<AuthState> {
  final AuthRepository _repo;

  AuthNotifier(this._repo) : super(const AuthState()) {
    _checkSession();
  }

  Future<void> _checkSession() async {
    state = state.copyWith(status: AuthStatus.loading);
    try {
      final user = await _repo.getSavedSession();
      if (user != null) {
        state = state.copyWith(status: AuthStatus.authenticated, user: user);
      } else {
        state = state.copyWith(status: AuthStatus.unauthenticated);
      }
    } catch (_) {
      state = state.copyWith(status: AuthStatus.unauthenticated);
    }
  }

  Future<void> login({
    required String email,
    required String password,
  }) async {
    state = state.copyWith(status: AuthStatus.loading, errorMessage: null);
    try {
      final user = await _repo.login(email: email, password: password);
      state = state.copyWith(status: AuthStatus.authenticated, user: user);
    } catch (e) {
      state = state.copyWith(
        status: AuthStatus.error,
        errorMessage: e.toString(),
      );
    }
  }

  Future<void> register({
    required String name,
    required String email,
    required String password,
    required UserRole role,
    required String language,
    String? school,
    String? city,
    String? subject,
    String? teacherCode,
  }) async {
    state = state.copyWith(status: AuthStatus.loading, errorMessage: null);
    try {
      final user = await _repo.register(
        name: name,
        email: email,
        password: password,
        role: role,
        language: language,
        school: school,
        city: city,
        subject: subject,
        teacherCode: teacherCode,
      );
      state = state.copyWith(status: AuthStatus.authenticated, user: user);
    } catch (e) {
      state = state.copyWith(
        status: AuthStatus.error,
        errorMessage: e.toString(),
      );
    }
  }

  Future<void> logout() async {
    await _repo.logout();
    state = const AuthState(status: AuthStatus.unauthenticated);
  }

  Future<void> updateUser(UserModel user) async {
    state = state.copyWith(user: user);
  }

  Future<void> updateProfile({
    String? name,
    String? school,
    String? city,
    String? avatarUrl,
    String? language,
    UserAccessibilitySettings? accessibility,
  }) async {
    final current = state.user;
    if (current == null) return;
    final updated = await _repo.updateProfile(
      currentUser: current,
      name: name,
      school: school,
      city: city,
      avatarUrl: avatarUrl,
      language: language,
      accessibility: accessibility,
    );
    state = state.copyWith(user: updated);
  }

  Future<void> loginAsDemo(UserRole role) async {
    UserModel demoUser;
    switch (role) {
      case UserRole.teacher:
        demoUser = AuthRepository.teacherDemoUser;
        break;
      case UserRole.student:
        demoUser = AuthRepository.studentDemoUser;
        break;
      case UserRole.learner:
        demoUser = AuthRepository.learnerDemoUser;
        break;
      default:
        demoUser = AuthRepository.studentDemoUser;
    }
    final user = await _repo._persistUser(demoUser);
    state = state.copyWith(status: AuthStatus.authenticated, user: user);
  }
}
