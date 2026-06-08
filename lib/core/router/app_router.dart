import 'package:go_router/go_router.dart';
import 'package:flutter/material.dart';

import '../../features/splash/splash_screen.dart';
import '../../features/gym/presentation/pages/create_gym_screen.dart';
import '../../features/gym/presentation/pages/gym_list_screen.dart';
import '../../features/gym/presentation/pages/gym_owner_dashboard.dart';
import '../../features/auth/presentation/pages/login_page.dart';
import '../../features/auth/presentation/pages/register_page.dart';
import '../../features/onboarding/presentation/pages/onboarding_page.dart';
import '../../features/home/presentation/pages/main_layout.dart';
import '../../features/home/presentation/pages/home_page.dart';
import '../../features/workout/presentation/pages/workout_generation_screen.dart';
import '../../features/workout/presentation/pages/active_workout_screen.dart';
import '../../features/workout/presentation/pages/exercise_detail_page.dart';
import '../../features/workout/presentation/pages/exercise_list_page.dart';
import '../../features/steps/presentation/pages/steps_screen.dart';
import '../../features/ai_coach/presentation/pages/chat_screen.dart';
import '../../features/profile/presentation/pages/dashboard_page.dart';
import '../../features/profile/presentation/pages/achievements_page.dart';
import '../../features/profile/presentation/pages/leaderboard_page.dart';
import '../../features/progress/presentation/pages/progress_dashboard_page.dart';
import '../../features/recovery/presentation/pages/recovery_dashboard_page.dart';

final appRouter = GoRouter(
  initialLocation: '/splash',
  debugLogDiagnostics: true,

  // ── Redirect guard ─────────────────────────────────────────
  redirect: (context, state) {
    final location = state.uri.path;

    // Allow splash + auth routes always
    final publicRoutes = ['/splash', '/login', '/register'];
    if (publicRoutes.contains(location)) return null;

    // No redirect needed for other routes
    return null;
  },

  errorBuilder: (context, state) => Scaffold(
    backgroundColor: const Color(0xFF0F1117),
    body: Center(
      child: Text(
        'Page not found: ${state.uri}',
        style: const TextStyle(color: Colors.white),
      ),
    ),
  ),

  routes: [
    GoRoute(
      path: '/splash',
      builder: (_, __) => const SplashScreen(),
    ),
    GoRoute(
      path: '/create-gym',
      builder: (_, __) => const CreateGymScreen(),
    ),
    GoRoute(
      path: '/select-gym',
      builder: (_, __) => const GymListScreen(),
    ),
    GoRoute(
      path: '/gym-owner',
      builder: (_, __) => const GymOwnerDashboard(),
    ),
    // ─── Auth ──────────────────────────────────────────────────
    GoRoute(
      path: '/login',
      name: 'login',
      builder: (_, __) => const LoginPage(),
    ),
    GoRoute(
      path: '/register',
      name: 'register',
      builder: (_, __) => const RegisterPage(),
    ),
    GoRoute(
      path: '/onboarding',
      name: 'onboarding',
      builder: (_, __) => const OnboardingPage(),
    ),

    // ─── Main Shell ────────────────────────────────────────────
    ShellRoute(
      builder: (_, __, child) => MainLayout(child: child),
      routes: [
        GoRoute(path: '/home',        builder: (_, __) => const HomePage()),
        GoRoute(path: '/workout',     builder: (_, __) => const WorkoutGenerationScreen()),
        GoRoute(path: '/steps',       builder: (_, __) => const StepsScreen()),
        GoRoute(path: '/coach',       builder: (_, __) => const ChatScreen()),
        GoRoute(path: '/profile',     builder: (_, __) => const DashboardPage()),
        GoRoute(path: '/progress',    builder: (_, __) => const ProgressDashboardPage()),
        GoRoute(path: '/recovery',    builder: (_, __) => const RecoveryDashboardPage()),
        GoRoute(path: '/achievements',builder: (_, __) => const AchievementsPage()),
        GoRoute(path: '/leaderboard', builder: (_, __) => const LeaderboardPage()),
      ],
    ),

    // ─── Standalone ────────────────────────────────────────────
    GoRoute(
      path: '/active-workout',
      builder: (_, __) => const ActiveWorkoutScreen(),
    ),
    GoRoute(
      path: '/exercise-list',
      builder: (_, __) => const ExerciseListPage(),
    ),
    GoRoute(
      path: '/exercise-detail',
      builder: (context, state) {
        final exerciseId = state.uri.queryParameters['id'] ?? '';
        return ExerciseDetailPage(exerciseId: exerciseId);
      },
    ),
  ],
);