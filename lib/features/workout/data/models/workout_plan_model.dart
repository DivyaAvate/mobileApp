class WorkoutPlanModel {
  final int    id;
  final String goal;
  final String experience;
  final int    daysPerWeek;
  final bool   isActive;
  final List<WorkoutDayModel> days;

  const WorkoutPlanModel({
    required this.id,
    required this.goal,
    required this.experience,
    required this.daysPerWeek,
    required this.isActive,
    required this.days,
  });

  factory WorkoutPlanModel.fromJson(Map<String, dynamic> j) => WorkoutPlanModel(
    id:          j['id']          as int?    ?? 0,
    goal:        j['goal']        as String? ?? '',
    experience:  j['experience']  as String? ?? '',
    daysPerWeek: j['daysPerWeek'] as int?    ?? 3,
    isActive:    j['isActive']    as bool?   ?? true,
    days: (j['days'] as List? ?? [])
        .map((d) => WorkoutDayModel.fromJson(d as Map<String, dynamic>))
        .toList(),
  );

  Map<String, dynamic> toJson() => {
    'id':          id,
    'goal':        goal,
    'experience':  experience,
    'daysPerWeek': daysPerWeek,
    'isActive':    isActive,
    'days':        days.map((d) => d.toJson()).toList(),
  };
}

class WorkoutDayModel {
  final int    id;
  final String dayName;
  final int    dayNumber;
  final List<WorkoutExerciseModel> exercises;

  const WorkoutDayModel({
    required this.id,
    required this.dayName,
    required this.dayNumber,
    required this.exercises,
  });

  factory WorkoutDayModel.fromJson(Map<String, dynamic> j) => WorkoutDayModel(
    id:        j['id']        as int?    ?? 0,
    dayName:   j['dayName']   as String? ?? '',
    dayNumber: j['dayNumber'] as int?    ?? 0,
    exercises: (j['exercises'] as List? ?? [])
        .map((e) => WorkoutExerciseModel.fromJson(e as Map<String, dynamic>))
        .toList(),
  );

  Map<String, dynamic> toJson() => {
    'id':        id,
    'dayName':   dayName,
    'dayNumber': dayNumber,
    'exercises': exercises.map((e) => e.toJson()).toList(),
  };
}

class WorkoutExerciseModel {
  final int    id;
  final int    exerciseId;
  final String name;
  final int    sets;
  final String reps;
  final int    order;
  final String? muscleGroup;
  final String? videoUrl;

  const WorkoutExerciseModel({
    required this.id,
    required this.exerciseId,
    required this.name,
    required this.sets,
    required this.reps,
    required this.order,
    this.muscleGroup,
    this.videoUrl,
  });

  factory WorkoutExerciseModel.fromJson(Map<String, dynamic> j) {
    // details is nested exercise info from backend include
    final details = j['details'] as Map<String, dynamic>? ?? {};
    return WorkoutExerciseModel(
      id:          j['id']          as int?    ?? 0,
      exerciseId:  j['exerciseId']  as int?    ?? 0,
      name:        details['name']  as String? ?? j['name'] as String? ?? '',
      sets:        j['sets']        as int?    ?? 3,
      reps:        j['reps']        as String? ?? '10',
      order:       j['order']       as int?    ?? 0,
      muscleGroup: details['muscleGroup'] as String?,
      videoUrl:    details['videoUrl']    as String?,
    );
  }

  Map<String, dynamic> toJson() => {
    'id':          id,
    'exerciseId':  exerciseId,
    'name':        name,
    'sets':        sets,
    'reps':        reps,
    'order':       order,
    'muscleGroup': muscleGroup,
    'videoUrl':    videoUrl,
  };
}