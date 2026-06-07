import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz_data;
import 'package:flutter/material.dart';
// ─── Provider ─────────────────────────────────────────────────────────────────

final notificationServiceProvider = Provider<NotificationService>((ref) {
  return NotificationService();
});

// ─── Service ──────────────────────────────────────────────────────────────────

class NotificationService {
  final _plugin = FlutterLocalNotificationsPlugin();
  bool _initialized = false;

  // ── Initialize ────────────────────────────────────────────

  Future<void> init() async {
    if (_initialized) return;
    tz_data.initializeTimeZones();

    const android = AndroidInitializationSettings('@mipmap/ic_launcher');
   const ios = DarwinInitializationSettings(
        requestAlertPermission: true,
        requestBadgePermission: true,
        requestSoundPermission: true,
        );

    await _plugin.initialize(
      const InitializationSettings(android: android, iOS: ios),
      onDidReceiveNotificationResponse: _onTap,
    );

    // Request permissions (Android 13+)
    await _plugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.requestNotificationsPermission();

    _initialized = true;
  }

  void _onTap(NotificationResponse response) {
    // Handle notification tap — navigate based on payload
    // e.g. payload: 'workout' → go to /workout
  }

  // ── Show immediate notification ───────────────────────────

  Future<void> show({
    required int    id,
    required String title,
    required String body,
    String?         payload,
  }) async {
    await _plugin.show(
      id,
      title,
      body,
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'gymbuddy_channel',
          'GymBuddy AI',
          channelDescription: 'GymBuddy AI notifications',
          importance:  Importance.high,
          priority:    Priority.high,
          color:       Color(0xFF00E5A0),
          icon:        '@mipmap/ic_launcher',
        ),
        iOS: DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
        ),
      ),
      payload: payload,
    );
  }

  // ── Schedule daily workout reminder ───────────────────────

  Future<void> scheduleWorkoutReminder({
    int hour   = 8,
    int minute = 0,
  }) async {
    await _plugin.zonedSchedule(
      1, // notification ID
      '💪 Time to train!',
      'Your workout is waiting. Let\'s crush it today!',
      _nextInstanceOfTime(hour, minute),
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'gymbuddy_workout',
          'Workout Reminders',
          channelDescription: 'Daily workout reminders',
          importance: Importance.high,
          priority:   Priority.high,
          color:      Color(0xFF00E5A0),
        ),
        iOS: DarwinNotificationDetails(),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
        matchDateTimeComponents: DateTimeComponents.time,
        payload: 'workout',
    );
  }

  // ── Schedule streak reminder ──────────────────────────────

  Future<void> scheduleStreakReminder() async {
    await _plugin.zonedSchedule(
      2,
      '🔥 Don\'t break your streak!',
      'You haven\'t logged a workout today. Keep the streak going!',
      _nextInstanceOfTime(20, 0), // 8 PM
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'gymbuddy_streak',
          'Streak Reminders',
          channelDescription: 'Streak reminder notifications',
          importance: Importance.defaultImportance,
          priority:   Priority.defaultPriority,
          color:      Color(0xFF00E5A0),
        ),
        iOS: DarwinNotificationDetails(),
      ),
       androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
    uiLocalNotificationDateInterpretation:
        UILocalNotificationDateInterpretation.absoluteTime,
    matchDateTimeComponents: DateTimeComponents.time,
    payload: 'streak',
    );
  }

  // ── Show offer notification (called when gym posts offer) ─

  Future<void> showOfferNotification({
    required String gymName,
    required String offerTitle,
  }) async {
    await show(
      id:      3,
      title:   '🏷️ New offer from $gymName!',
      body:    offerTitle,
      payload: 'offers',
    );
  }

  // ── Show XP / level up notification ──────────────────────

  Future<void> showLevelUpNotification(int newLevel) async {
    await show(
      id:    4,
      title: '🎉 Level Up!',
      body:  'Congratulations! You reached Level $newLevel!',
      payload: 'achievements',
    );
  }

  // ── Show workout complete notification ────────────────────

  Future<void> showWorkoutCompleteNotification({
    required int xpEarned,
    List? achievements,
  }) async {
    final hasAchievement = achievements != null && achievements.isNotEmpty;
    await show(
      id:    5,
      title: '✅ Workout Complete!',
      body:  hasAchievement
          ? 'You earned $xpEarned XP and unlocked a badge! 🏆'
          : 'You earned $xpEarned XP. Keep it up!',
      payload: 'progress',
    );
  }

  // ── Cancel specific notification ──────────────────────────

  Future<void> cancel(int id) => _plugin.cancel(id);

  // ── Cancel all notifications ──────────────────────────────

  Future<void> cancelAll() => _plugin.cancelAll();

  // ── Helper: next instance of a time ──────────────────────

  tz.TZDateTime _nextInstanceOfTime(int hour, int minute) {
    final now      = tz.TZDateTime.now(tz.local);
    var   scheduled = tz.TZDateTime(
      tz.local, now.year, now.month, now.day, hour, minute);
    if (scheduled.isBefore(now)) {
      scheduled = scheduled.add(const Duration(days: 1));
    }
    return scheduled;
  }
}