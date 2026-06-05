
class StepsModel {
  final DateTime date;
  final int stepCount;
  final int goal;

  const StepsModel({
    required this.date,
    required this.stepCount,
    this.goal = 10000,
  });

  factory StepsModel.fromJson(Map<String, dynamic> json) => StepsModel(
        date: DateTime.parse(json['date'] as String),
        stepCount: json['step_count'] as int,
        goal: json['goal'] as int? ?? 10000,
      );

  Map<String, dynamic> toJson() => {
        'date': date.toIso8601String(),
        'step_count': stepCount,
        'goal': goal,
      };

  double get progressPct => (stepCount / goal).clamp(0.0, 1.0);
  bool get goalReached => stepCount >= goal;
}

class StepTrend {
  final DateTime date;
  final int steps;

  const StepTrend({
    required this.date,
    required this.steps,
  });
}

