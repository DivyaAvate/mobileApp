import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/network/dio_provider.dart';
import '../../../../core/constants/api_endpoints.dart';
import '../../data/models/workout_plan_model.dart';

// ─── Provider ─────────────────────────────────────────────────────────────────

final workoutGeneratorProvider =
    StateNotifierProvider<WorkoutNotifier, AsyncValue<WorkoutPlanModel?>>(
  (ref) => WorkoutNotifier(ref.watch(dioProvider)),
);

// ─── Also fetch current active plan ──────────────────────────────────────────

final currentPlanProvider = FutureProvider<WorkoutPlanModel?>((ref) async {
  try {
    final dio      = ref.watch(dioProvider);
    final response = await dio.get(ApiEndpoints.workoutCurrent);
    return WorkoutPlanModel.fromJson(response.data as Map<String, dynamic>);
  } catch (_) {
    return null; // no plan yet
  }
});

// ─── Notifier ─────────────────────────────────────────────────────────────────

class WorkoutNotifier extends StateNotifier<AsyncValue<WorkoutPlanModel?>> {
  final Dio _dio;
  WorkoutNotifier(this._dio) : super(const AsyncValue.data(null)) {
    _loadCurrentPlan();
  }

  // Load existing plan on init
  Future<void> _loadCurrentPlan() async {
    try {
      final response = await _dio.get(ApiEndpoints.workoutCurrent);
      if (response.data != null) {
        state = AsyncValue.data(
          WorkoutPlanModel.fromJson(response.data as Map<String, dynamic>));
      }
    } catch (_) {
      // No plan yet — stay null
    }
  }

  // Generate new plan
  Future<void> generatePlan(String goal, String experience, int daysPerWeek) async {
    state = const AsyncValue.loading();
    try {
      final response = await _dio.post(
        ApiEndpoints.workoutGenerate,
        data: {
          'goal':        goal,
          'experience':  experience,
          'daysPerWeek': daysPerWeek,
        },
      );
      state = AsyncValue.data(
        WorkoutPlanModel.fromJson(response.data as Map<String, dynamic>));
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  // Reset plan
  void reset() => state = const AsyncValue.data(null);
}