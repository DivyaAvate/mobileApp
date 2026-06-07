import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/router/app_router.dart';
import 'core/theme/app_theme.dart';
import 'core/services/notification_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize notifications
  final notificationService = NotificationService();
  await notificationService.init();

  // Schedule daily reminders
  await notificationService.scheduleWorkoutReminder(hour: 8, minute: 0);
  await notificationService.scheduleStreakReminder();

  runApp(
    ProviderScope(
      overrides: [
        // Make notification service available via provider
        notificationServiceProvider.overrideWithValue(notificationService),
      ],
      child: const GymBuddyApp(),
    ),
  );
}

class GymBuddyApp extends StatelessWidget {
  const GymBuddyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title:                    'GymBuddy AI',
      debugShowCheckedModeBanner: false,
      routerConfig:             appRouter,
      theme:                    AppTheme.dark(),
    );
  }
}