class WorkoutPlanModel {
  final int id;
  final String goal;
  final List<WorkoutDayModel> days;

  WorkoutPlanModel({
    required this.id,
    required this.goal,
    required this.days,
  });

  factory WorkoutPlanModel.fromJson(Map<String, dynamic> json) {
    return WorkoutPlanModel(
      id: json['id'] ?? 0,
      goal: json['goal'] ?? '',
      days: (json['days'] as List? ?? [])
          .map((i) => WorkoutDayModel.fromJson(i))
          .toList(),
    );
  }
}

class WorkoutDayModel {
  final String dayName;
  final List<WorkoutExerciseModel> exercises;

  WorkoutDayModel({
    required this.dayName,
    required this.exercises,
  });

  factory WorkoutDayModel.fromJson(Map<String, dynamic> json) {
    return WorkoutDayModel(
      dayName: json['dayName'] ?? '',
      exercises: (json['exercises'] as List? ?? [])
          .map((i) => WorkoutExerciseModel.fromJson(i))
          .toList(),
    );
  }
}

class WorkoutExerciseModel {
  final String name;
  final int sets;
  final String reps;

  WorkoutExerciseModel({
    required this.name,
    required this.sets,
    required this.reps,
  });

  factory WorkoutExerciseModel.fromJson(Map<String, dynamic> json) {
    final details = json['details'] as Map<String, dynamic>?;

    return WorkoutExerciseModel(
      name: details?['name'] ?? '',
      sets: json['sets'] ?? 0,
      reps: json['reps']?.toString() ?? '',
    );
  }
}