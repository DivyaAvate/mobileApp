import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/network/dio_provider.dart';
import '../../../../core/constants/api_endpoints.dart';
import '../../data/models/achievement_model.dart';

// ─── User Level + XP ─────────────────────────────────────────────────────────

class GamificationState {
  final int level;
  final int currentXP;
  final int nextLevelXP;
  final int streakDays;
  final int totalWorkouts;

  const GamificationState({
    this.level        = 1,
    this.currentXP    = 0,
    this.nextLevelXP  = 500,
    this.streakDays   = 0,
    this.totalWorkouts = 0,
  });
}

final gamificationProvider = FutureProvider<GamificationState>((ref) async {
  final dio      = ref.watch(dioProvider);
  final response = await dio.get(ApiEndpoints.dashboard);
  final data     = response.data;

  return GamificationState(
    level:          data['level']          ?? 1,
    currentXP:      data['xp']             ?? 0,
    nextLevelXP:    data['nextLevelXp']    ?? 500,
    streakDays:     data['streakDays']     ?? 0,
    totalWorkouts:  data['totalWorkouts']  ?? 0,
  );
});

// ─── Achievements / Badges ────────────────────────────────────────────────────

final badgesProvider = FutureProvider<List<AchievementModel>>((ref) async {
  final dio      = ref.watch(dioProvider);
  final response = await dio.get(ApiEndpoints.achievements);

  return (response.data as List)
      .map((e) => AchievementModel(
            name:        e['name']           ?? '',
            description: e['description']    ?? '',
            iconUrl:     e['badge_icon_url'] ?? '',
            isUnlocked:  e['isUnlocked']     ?? false,
          ))
      .toList();
});