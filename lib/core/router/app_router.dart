import 'package:go_router/go_router.dart';
import 'package:flutter/material.dart';

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
import '../../features/workout/data/models/exercise_model.dart';

final appRouter = GoRouter(
  initialLocation: '/login',
  debugLogDiagnostics: true,

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
      path: '/select-gym',
      builder: (_, _) => const GymListScreen(),
    ),
    GoRoute(
      path: '/gym-owner',
      builder: (_, _) => const GymOwnerDashboard(),
    ),
    // ─── Auth ──────────────────────────────────────────────────
    GoRoute(
      path: '/login',
      name: 'login',
      builder: (_, _) => const LoginPage(),
    ),
    GoRoute(
      path: '/register',
      name: 'register',
      builder: (_, _) => const RegisterPage(),
    ),
    GoRoute(
      path: '/onboarding',
      name: 'onboarding',
      builder: (_, _) => const OnboardingPage(),
    ),

    // ─── Main Shell ────────────────────────────────────────────
    ShellRoute(
      builder: (_, _, child) => MainLayout(child: child),
      routes: [
        GoRoute(path: '/home',        builder: (_, _) => const HomePage()),
        GoRoute(path: '/workout',     builder: (_, _) => const WorkoutGenerationScreen()),
        GoRoute(path: '/steps',       builder: (_, _) => const StepsScreen()),
        GoRoute(path: '/coach',       builder: (_, _) => const ChatScreen()),
        GoRoute(path: '/profile',     builder: (_, _) => const DashboardPage()),
        GoRoute(path: '/progress',    builder: (_, _) => const ProgressDashboardPage()),
        GoRoute(path: '/recovery',    builder: (_, _) => const RecoveryDashboardPage()),
        GoRoute(path: '/achievements',builder: (_, _) => const AchievementsPage()),
        GoRoute(path: '/leaderboard', builder: (_, _) => const LeaderboardPage()),
      ],
    ),

    // ─── Standalone ────────────────────────────────────────────
    GoRoute(
      path: '/active-workout',
      builder: (_, _) => const ActiveWorkoutScreen(),
    ),
    GoRoute(
      path: '/exercise-list',
      builder: (_, _) => const ExerciseListPage(),
    ),
    GoRoute(
      path: '/exercise-detail',
      builder: (context, state) {
        final exercise = state.extra as ExerciseModel;
        return ExerciseDetailPage(exercise: exercise);
      },
    ),
  ],
);
