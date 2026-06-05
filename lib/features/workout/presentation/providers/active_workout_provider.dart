import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/network/dio_provider.dart';

// ─── Models ───────────────────────────────────────────────────────────────────

class SetLogEntry {
  final double weight;
  final int reps;
  final bool isPR;

  const SetLogEntry({
    required this.weight,
    required this.reps,
    this.isPR = false,
  });
}

class ActiveExercise {
  final int exerciseId;
  final String name;
  final List<SetLogEntry> sets;

  const ActiveExercise({
    required this.exerciseId,
    required this.name,
    required this.sets,
  });

  // Best previous weight for PR detection (you can wire to local DB later)
  double get bestWeight =>
      sets.isEmpty ? 0 : sets.map((s) => s.weight).reduce((a, b) => a > b ? a : b);

  ActiveExercise copyWith({List<SetLogEntry>? sets}) {
    return ActiveExercise(
      exerciseId: exerciseId,
      name: name,
      sets: sets ?? this.sets,
    );
  }
}

// ─── State ────────────────────────────────────────────────────────────────────

class ActiveWorkoutState {
  final int? sessionId;
  final String name;
  final List<ActiveExercise> exercises;
  final DateTime startTime;
  final bool isFinishing;

  const ActiveWorkoutState({
    this.sessionId,
    required this.name,
    required this.exercises,
    required this.startTime,
    this.isFinishing = false,
  });

  ActiveWorkoutState copyWith({
    int? sessionId,
    String? name,
    List<ActiveExercise>? exercises,
    DateTime? startTime,
    bool? isFinishing,
  }) {
    return ActiveWorkoutState(
      sessionId:   sessionId   ?? this.sessionId,
      name:        name        ?? this.name,
      exercises:   exercises   ?? this.exercises,
      startTime:   startTime   ?? this.startTime,
      isFinishing: isFinishing ?? this.isFinishing,
    );
  }

  int get totalSets =>
      exercises.fold(0, (sum, e) => sum + e.sets.length);

  int get totalVolume =>
      exercises.fold(0, (sum, e) =>
        sum + e.sets.fold(0, (s, set) =>
          s + (set.weight * set.reps).toInt()));

  Duration get elapsed => DateTime.now().difference(startTime);
}

// ─── Notifier ─────────────────────────────────────────────────────────────────

class ActiveWorkoutNotifier extends StateNotifier<ActiveWorkoutState?> {
  final Ref _ref;

  ActiveWorkoutNotifier(this._ref) : super(null);

  // Start a new workout session
  void startWorkout({int? sessionId, required String name}) {
    state = ActiveWorkoutState(
      sessionId: sessionId,
      name: name,
      exercises: const [],
      startTime: DateTime.now(),
    );
  }

  // Add exercise to current session
  void addExercise(int id, String name) {
    if (state == null) return;
    state = state!.copyWith(
      exercises: [
        ...state!.exercises,
        ActiveExercise(exerciseId: id, name: name, sets: const []),
      ],
    );
  }

  // Add set — named params to match screen call + immutable update + PR check
  void addSet(int exerciseIndex, {required double weight, required int reps}) {
    if (state == null) return;
    final exercises = List<ActiveExercise>.from(state!.exercises);
    final exercise  = exercises[exerciseIndex];

    // PR detection — is this weight higher than any previous set?
    final previousBest = exercise.bestWeight;
    final isPR = exercise.sets.isNotEmpty && weight > previousBest;

    final updatedSets = [
      ...exercise.sets,
      SetLogEntry(weight: weight, reps: reps, isPR: isPR),
    ];

    exercises[exerciseIndex] = exercise.copyWith(sets: updatedSets);
    state = state!.copyWith(exercises: exercises);
  }

  // Remove a set
  void removeSet(int exerciseIndex, int setIndex) {
    if (state == null) return;
    final exercises = List<ActiveExercise>.from(state!.exercises);
    final exercise  = exercises[exerciseIndex];
    final updatedSets = List<SetLogEntry>.from(exercise.sets)..removeAt(setIndex);
    exercises[exerciseIndex] = exercise.copyWith(sets: updatedSets);
    state = state!.copyWith(exercises: exercises);
  }

  // Remove an exercise
  void removeExercise(int exerciseIndex) {
    if (state == null) return;
    final exercises = List<ActiveExercise>.from(state!.exercises)
      ..removeAt(exerciseIndex);
    state = state!.copyWith(exercises: exercises);
  }

  // Finish workout — save to backend then clear state
  Future<bool> finishWorkout() async {
    if (state == null) return false;
    state = state!.copyWith(isFinishing: true);

    try {
      final dio = _ref.read(dioProvider);
      final payload = {
        'session_id':  state!.sessionId,
        'name':        state!.name,
        'duration_sec': state!.elapsed.inSeconds,
        'total_sets':   state!.totalSets,
        'total_volume': state!.totalVolume,
        'exercises': state!.exercises.map((e) => {
          'exercise_id': e.exerciseId,
          'name':        e.name,
          'sets': e.sets.map((s) => {
            'weight': s.weight,
            'reps':   s.reps,
            'is_pr':  s.isPR,
          }).toList(),
        }).toList(),
      };

      await dio.post('/api/tracking/finish/${state!.sessionId}', data: payload);
      state = null; // clear session on success
      return true;

    } catch (e) {
      // Revert finishing state so user can retry
      state = state!.copyWith(isFinishing: false);
      return false;
    }
  }

  // Discard workout without saving
  void discardWorkout() => state = null;
}

// ─── Provider ─────────────────────────────────────────────────────────────────

final activeWorkoutProvider =
    StateNotifierProvider<ActiveWorkoutNotifier, ActiveWorkoutState?>(
  (ref) => ActiveWorkoutNotifier(ref),
);