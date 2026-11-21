import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../features/auth/data/auth_repository.dart';
import '../features/auth/presentation/forgot_password_screen.dart';
import '../features/auth/presentation/login_screen.dart';
import '../features/auth/presentation/register_screen.dart';
import '../features/home/presentation/main_scaffold.dart';
import '../features/home/presentation/home_dashboard_screen.dart';
import '../features/home/presentation/modules_screen.dart';
import '../features/ai_assistant/presentation/ai_assistant_screen.dart';
import '../features/profile/presentation/profile_screen.dart';
import '../features/notifications/presentation/notifications_screen.dart';

// Admin Screen
import '../features/admin/presentation/admin_screen.dart';

// Learning Hub Screen
import '../features/learning/presentation/learning_hub_screen.dart';

// Gamification Screen
import '../features/gamification/presentation/achievements_screen.dart';

// Teacher Screens
import '../features/teacher/presentation/teacher_portal_screen.dart';
import '../features/teacher/presentation/lesson_generator_screen.dart';
import '../features/teacher/presentation/quiz_generator_screen.dart';
import '../features/teacher/presentation/quiz_taking_screen.dart';
import '../features/teacher/presentation/explain_concept_screen.dart';
import '../features/teacher/presentation/materials_history_screen.dart';

// MindCare Screens
import '../features/mindcare/presentation/mindcare_chat_screen.dart';
import '../features/mindcare/presentation/mood_tracker_screen.dart';
import '../features/mindcare/presentation/exercise_timer_screen.dart';

// Inclusive Screens
import '../features/inclusive/presentation/ai_simplifier_screen.dart';
import '../features/inclusive/presentation/voice_notes_screen.dart';
import '../features/inclusive/presentation/accessibility_settings_screen.dart';

final routerProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authNotifierProvider);

  return GoRouter(
    initialLocation: '/home',
    redirect: (context, state) {
      final isAuth = authState.isAuthenticated;
      final isAuthRoute =
          state.matchedLocation == '/login' ||
          state.matchedLocation == '/register' ||
          state.matchedLocation == '/forgot-password';

      if (!isAuth && !isAuthRoute) {
        return '/login';
      }
      if (isAuth && isAuthRoute) {
        return '/home';
      }
      return null;
    },
    routes: [
      GoRoute(path: '/login', builder: (context, state) => const LoginScreen()),
      GoRoute(
        path: '/register',
        builder: (context, state) => const RegisterScreen(),
      ),
      GoRoute(
        path: '/forgot-password',
        builder: (context, state) => const ForgotPasswordScreen(),
      ),

      // Bottom Navigation Shell
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) {
          return MainScaffold(navigationShell: navigationShell);
        },
        branches: [
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/home',
                builder: (context, state) => const HomeDashboardScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/learning',
                builder: (context, state) => const LearningHubScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/assistant',
                builder: (context, state) => const AiAssistantScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/modules',
                builder: (context, state) => const ModulesScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/profile',
                builder: (context, state) => const ProfileScreen(),
              ),
            ],
          ),
        ],
      ),

      // Admin Portal
      GoRoute(
        path: '/admin',
        builder: (context, state) => const AdminScreen(),
      ),

      // Standalone Feature Routes
      GoRoute(
        path: '/notifications',
        builder: (context, state) => const NotificationsScreen(),
      ),
      GoRoute(
        path: '/achievements',
        builder: (context, state) => const AchievementsScreen(),
      ),
      // Teacher
      GoRoute(
        path: '/teacher/portal',
        builder: (context, state) => const TeacherPortalScreen(),
      ),
      GoRoute(
        path: '/teacher/lesson-generator',
        builder: (context, state) => const LessonGeneratorScreen(),
      ),
      GoRoute(
        path: '/teacher/quiz-generator',
        builder: (context, state) => const QuizGeneratorScreen(),
      ),
      GoRoute(
        path: '/teacher/quiz-take',
        builder: (context, state) {
          final extra = state.extra as Map<String, dynamic>?;
          return QuizTakingScreen(quizData: extra);
        },
      ),
      GoRoute(
        path: '/teacher/explain',
        builder: (context, state) => const ExplainConceptScreen(),
      ),
      GoRoute(
        path: '/teacher/history',
        builder: (context, state) => const MaterialsHistoryScreen(),
      ),
      // MindCare
      GoRoute(
        path: '/mindcare/chat',
        builder: (context, state) => const MindcareChatScreen(),
      ),
      GoRoute(
        path: '/mindcare/mood',
        builder: (context, state) => const MoodTrackerScreen(),
      ),
      GoRoute(
        path: '/mindcare/exercises',
        builder: (context, state) => const ExerciseTimerScreen(),
      ),
      // Inclusive
      GoRoute(
        path: '/inclusive/simplifier',
        builder: (context, state) => const AiSimplifierScreen(),
      ),
      GoRoute(
        path: '/inclusive/voice',
        builder: (context, state) => const VoiceNotesScreen(),
      ),
      GoRoute(
        path: '/inclusive/accessibility',
        builder: (context, state) => const AccessibilitySettingsScreen(),
      ),
    ],
  );
});
