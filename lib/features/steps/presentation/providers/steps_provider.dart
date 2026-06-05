import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:health/health.dart';
import '../../../../core/network/dio_provider.dart';
import '../../../../core/constants/api_endpoints.dart';
import '../../data/models/steps_model.dart'; // ✅ must export both StepsModel & StepTrend

// ─── State ────────────────────────────────────────────────────────────────────

class StepsState {
  final int todaySteps;
  final int goalSteps;
  final List<StepTrend> trends;

  const StepsState({
    this.todaySteps = 0,
    this.goalSteps  = 10000,
    this.trends     = const [],
  });
}

// ─── Provider ─────────────────────────────────────────────────────────────────

final stepsProvider =
    StateNotifierProvider<StepsNotifier, AsyncValue<StepsState>>((ref) {
  return StepsNotifier(ref.watch(dioProvider));
});

// ─── Notifier ─────────────────────────────────────────────────────────────────

class StepsNotifier extends StateNotifier<AsyncValue<StepsState>> {
  final Dio _dio;
  final Health _health = Health();

  StepsNotifier(this._dio) : super(const AsyncValue.loading()) {
    fetchAndSyncSteps();
  }

  Future<void> fetchAndSyncSteps() async {
    state = const AsyncValue.loading();
    try {
      final types   = [HealthDataType.STEPS];
      final granted = await _health.requestAuthorization(types);

      int todaySteps = 0;

      if (granted) {
        final now   = DateTime.now();
        final today = DateTime(now.year, now.month, now.day);

        final steps = await _health.getTotalStepsInInterval(today, now);
        todaySteps  = steps ?? 0;

        final dateStr =
            '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';

        await _dio.post(
          ApiEndpoints.stepsSync,
          data: {'steps': todaySteps, 'date': dateStr},
        );
      }

      // Fetch 30-day trends + goal from backend
      final response = await _dio.get(ApiEndpoints.stepsTrends);
      final data     = response.data as Map<String, dynamic>;

      // ✅ parse goalSteps from backend if available, fallback to 10000
      final goalSteps = (data['goal_steps'] as int?) ?? 10000;

      final trends = (data['trends'] as List)
          .map((e) => StepTrend(
                date:  DateTime.parse(e['date'] as String),
                steps: e['steps'] as int,
              ))
          .toList();

      state = AsyncValue.data(StepsState(
        todaySteps: todaySteps,
        goalSteps:  goalSteps,
        trends:     trends,
      ));
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> refresh() => fetchAndSyncSteps();
}