// lib/features/profile/data/models/dashboard_model.dart
// Used in dashboard_page.dart at lines 38, 58, 89, 110

class ActivityItem {
  final double value;
  const ActivityItem(this.value);
}

class DashboardModel {
  final int totalWorkouts;
  final int currentStreak;
  final double weightLost;       // kg
  final double strengthGainPct;  // e.g. 8.0 for 8%
  final int stepsToday;
  final int stepsGoal;
  final String sleepScore;       // "Good", "Fair", "Poor"
  final double sleepHours;
  final String recoveryStatus;   // "Ready", "Moderate", "Rest"

  const DashboardModel({
    required this.totalWorkouts,
    required this.currentStreak,
    required this.weightLost,
    required this.strengthGainPct,
    required this.stepsToday,
    this.stepsGoal = 10000,
    this.sleepScore = 'Good',
    this.sleepHours = 7.5,
    this.recoveryStatus = 'Ready',
  });

  factory DashboardModel.fromJson(Map<String, dynamic> json) => DashboardModel(
        totalWorkouts: json['total_workouts'] as int? ?? 0,
        currentStreak: json['current_streak'] as int? ?? 0,
        weightLost: (json['weight_lost'] as num?)?.toDouble() ?? 0.0,
        strengthGainPct: (json['strength_gain_pct'] as num?)?.toDouble() ?? 0.0,
        stepsToday: json['steps_today'] as int? ?? 0,
        stepsGoal: json['steps_goal'] as int? ?? 10000,
        sleepScore: json['sleep_score'] as String? ?? 'Good',
        sleepHours: (json['sleep_hours'] as num?)?.toDouble() ?? 7.5,
        recoveryStatus: json['recovery_status'] as String? ?? 'Ready',
      );

  Map<String, dynamic> toJson() => {
        'total_workouts': totalWorkouts,
        'current_streak': currentStreak,
        'weight_lost': weightLost,
        'strength_gain_pct': strengthGainPct,
        'steps_today': stepsToday,
        'steps_goal': stepsGoal,
        'sleep_score': sleepScore,
        'sleep_hours': sleepHours,
        'recovery_status': recoveryStatus,
      };

  // Convenience factory for mock/local data
  factory DashboardModel.mock() => const DashboardModel(
        totalWorkouts: 24,
        currentStreak: 12,
        weightLost: 4.2,
        strengthGainPct: 8.0,
        stepsToday: 7142,
        stepsGoal: 10000,
        sleepScore: 'Good',
        sleepHours: 7.33,
        recoveryStatus: 'Ready',
      );

  String get userName => "Athlete";
  int get streak => currentStreak;
  int get steps => stepsToday;
  int get recoveryScore => 85;
  String? get todayWorkoutName => "Leg Day";
  List<ActivityItem> get activity => const [
        ActivityItem(100.0),
        ActivityItem(150.0),
        ActivityItem(120.0),
        ActivityItem(200.0),
        ActivityItem(180.0),
        ActivityItem(220.0),
        ActivityItem(250.0),
      ];
}