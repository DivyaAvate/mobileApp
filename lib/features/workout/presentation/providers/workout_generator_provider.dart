import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dio/dio.dart';

// 🔴 ADD YOUR PROJECT IMPORTS HERE
import 'package:gymbuddy_ai/core/network/dio_provider.dart';
import 'package:gymbuddy_ai/features/workout/data/models/workout_plan_model.dart';

final workoutGeneratorProvider = StateNotifierProvider<
    WorkoutNotifier, AsyncValue<WorkoutPlanModel?>>((ref) {
  return WorkoutNotifier(ref.watch(dioProvider));
});

class WorkoutNotifier extends StateNotifier<AsyncValue<WorkoutPlanModel?>> {
  final Dio _dio;

  WorkoutNotifier(this._dio) : super(const AsyncValue.data(null));

  Future<void> generatePlan(String goal, String exp, int days) async {
    state = const AsyncValue.loading();

    try {
      final res = await _dio.post(
        '/workouts/generate',
        data: {
          'goal': goal,
          'experience': exp,
          'daysPerWeek': days,
        },
      );

      state = AsyncValue.data(
        WorkoutPlanModel.fromJson(res.data),
      );
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }
}