class ActivityPoint {
  final String label; // e.g. "Mon"
  final double value; // volume in kg

  const ActivityPoint({required this.label, required this.value});

  factory ActivityPoint.fromJson(Map<String, dynamic> j) => ActivityPoint(
        label: j['label'] as String? ?? '',
        value: (j['value'] as num?)?.toDouble() ?? 0,
      );
}

class DashboardModel {
  final String   userName;
  final int      streak;
  final int      steps;
  final int      recoveryScore;
  final String?  todayWorkoutName;
  final int      level;
  final int      xp;
  final int      totalWorkouts;
  final List<ActivityPoint> activity;

  const DashboardModel({
    required this.userName,
    required this.streak,
    required this.steps,
    required this.recoveryScore,
    this.todayWorkoutName,
    required this.level,
    required this.xp,
    required this.totalWorkouts,
    required this.activity,
  });

  factory DashboardModel.fromJson(Map<String, dynamic> j) => DashboardModel(
        userName:         j['userName']        as String?  ?? 'Athlete',
        streak:           j['streakDays']       as int?     ?? 0,
        steps:            j['todaySteps']       as int?     ?? 0,
        recoveryScore:    j['recoveryScore']    as int?     ?? 0,
        todayWorkoutName: j['todayWorkoutName'] as String?,
        level:            j['level']            as int?     ?? 1,
        xp:               j['xp']               as int?     ?? 0,
        totalWorkouts:    j['totalWorkouts']    as int?     ?? 0,
        activity: (j['weeklyActivity'] as List? ?? [])
            .map((e) => ActivityPoint.fromJson(e as Map<String, dynamic>))
            .toList(),
      );
}