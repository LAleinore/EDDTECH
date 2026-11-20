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

  // Preset Demo Accounts
  static final UserModel teacherDemoUser = UserModel(
    id: 'demo-teacher-uuid-0001',
    name: 'Айгүл Серікқызы',
    email: 'teacher@edumind.ai',
    role: UserRole.teacher,
    language: 'ru',
    createdAt: DateTime(2025, 9, 1),
    lastLoginAt: DateTime.now(),
    isDemo: true,
  );

  static final UserModel studentDemoUser = UserModel(
    id: 'demo-student-uuid-0002',
    name: 'Алихан Нуртаев',
    email: 'student@edumind.ai',
    role: UserRole.student,
    language: 'ru',
    createdAt: DateTime(2025, 10, 15),
    lastLoginAt: DateTime.now(),
    isDemo: true,
  );

  static final UserModel learnerDemoUser = UserModel(
    id: 'demo-learner-uuid-0003',
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
    isDemo: true,
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
    // Check if email matches demo accounts
    if (email.trim().toLowerCase() == teacherDemoUser.email) {
      return loginAsDemo(UserRole.teacher);
    } else if (email.trim().toLowerCase() == studentDemoUser.email) {
      return loginAsDemo(UserRole.student);
    } else if (email.trim().toLowerCase() == learnerDemoUser.email) {
      return loginAsDemo(UserRole.learner);
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
      // If server is not yet running in environment, fall back gracefully
      if (e.type == DioExceptionType.connectionError ||
          e.type == DioExceptionType.connectionTimeout) {
        throw 'Сервер временно недоступен. Вы можете использовать Demo Mode для входа.';
      }
      final msg = e.response?.data?['detail'] ?? 'Неверный email или пароль';
      throw msg.toString();
    } catch (e) {
      throw 'Ошибка авторизации: $e';
    }
  }

  Future<UserModel> register({
    required String name,
    required String email,
    required String password,
    required UserRole role,
    required String language,
  }) async {
    try {
      final response = await _apiClient.dio.post(
        '/auth/register',
        data: {
          'name': name.trim(),
          'email': email.trim(),
          'password': password,
          'role': role.key,
          'language': language,
        },
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
        // Create local user in demo mode fallback
        final localUser = UserModel(
          id: 'user-${DateTime.now().millisecondsSinceEpoch}',
          name: name.trim(),
          email: email.trim(),
          role: role,
          language: language,
          createdAt: DateTime.now(),
          lastLoginAt: DateTime.now(),
          isDemo: true,
        );
        await _storageService.saveAuthToken('demo-token-${localUser.id}');
        await _storageService.saveUserJson(localUser.toJson());
        return localUser;
      }
      final msg = e.response?.data?['detail'] ?? 'Ошибка при регистрации';
      throw msg.toString();
    } catch (e) {
      throw 'Ошибка регистрации: $e';
    }
  }

  Future<UserModel> loginAsDemo(UserRole role) async {
    UserModel user;
    switch (role) {
      case UserRole.teacher:
        user = teacherDemoUser;
        break;
      case UserRole.learner:
        user = learnerDemoUser;
        break;
      case UserRole.student:
      case UserRole.admin:
        user = studentDemoUser;
        break;
    }

    final updated = user.copyWith(lastLoginAt: DateTime.now());
    await _storageService.saveAuthToken('demo-token-${updated.id}');
    await _storageService.saveUserJson(updated.toJson());
    await _storageService.setLanguageCode(updated.language);
    await _storageService.setFontScale(updated.accessibility.fontScale);
    await _storageService.setHighContrast(updated.accessibility.highContrast);
    await _storageService.setReduceMotion(updated.accessibility.reduceMotion);

    return updated;
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
    String? language,
    UserAccessibilitySettings? accessibility,
  }) async {
    final updated = currentUser.copyWith(
      name: name,
      language: language,
      accessibility: accessibility,
    );

    await _storageService.saveUserJson(updated.toJson());
    if (language != null) {
      await _storageService.setLanguageCode(language);
    }
    if (accessibility != null) {
      await _storageService.setFontScale(accessibility.fontScale);
      await _storageService.setHighContrast(accessibility.highContrast);
      await _storageService.setReduceMotion(accessibility.reduceMotion);
    }

    if (!currentUser.isDemo) {
      try {
        await _apiClient.dio.put('/auth/profile', data: updated.toMap());
      } catch (_) {}
    }

    return updated;
  }

  Future<void> sendPasswordRecovery(String email) async {
    try {
      await _apiClient.dio.post(
        '/auth/forgot-password',
        data: {'email': email.trim()},
      );
    } on DioException catch (e) {
      if (e.type != DioExceptionType.connectionError) {
        throw e.response?.data?['detail'] ??
            'Ошибка отправки ссылки восстановления';
      }
    }
  }
}

class AuthNotifier extends StateNotifier<AuthState> {
  final AuthRepository _repo;

  AuthNotifier(this._repo) : super(const AuthState()) {
    checkSession();
  }

  Future<void> checkSession() async {
    state = state.copyWith(status: AuthStatus.loading);
    try {
      final user = await _repo.getSavedSession();
      if (user != null) {
        state = state.copyWith(status: AuthStatus.authenticated, user: user);
      } else {
        state = state.copyWith(status: AuthStatus.unauthenticated);
      }
    } catch (e) {
      state = state.copyWith(status: AuthStatus.unauthenticated);
    }
  }

  Future<void> login({required String email, required String password}) async {
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
  }) async {
    state = state.copyWith(status: AuthStatus.loading, errorMessage: null);
    try {
      final user = await _repo.register(
        name: name,
        email: email,
        password: password,
        role: role,
        language: language,
      );
      state = state.copyWith(status: AuthStatus.authenticated, user: user);
    } catch (e) {
      state = state.copyWith(
        status: AuthStatus.error,
        errorMessage: e.toString(),
      );
    }
  }

  Future<void> loginAsDemo(UserRole role) async {
    state = state.copyWith(status: AuthStatus.loading, errorMessage: null);
    try {
      final user = await _repo.loginAsDemo(role);
      state = state.copyWith(status: AuthStatus.authenticated, user: user);
    } catch (e) {
      state = state.copyWith(
        status: AuthStatus.error,
        errorMessage: e.toString(),
      );
    }
  }

  Future<void> updateProfile({
    String? name,
    String? language,
    UserAccessibilitySettings? accessibility,
  }) async {
    if (state.user == null) return;
    try {
      final updated = await _repo.updateProfile(
        currentUser: state.user!,
        name: name,
        language: language,
        accessibility: accessibility,
      );
      state = state.copyWith(user: updated);
    } catch (e) {
      state = state.copyWith(errorMessage: e.toString());
    }
  }

  Future<void> logout() async {
    await _repo.logout();
    state = const AuthState(status: AuthStatus.unauthenticated);
  }
}
