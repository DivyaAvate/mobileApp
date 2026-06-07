class ExerciseModel {
  final int    id;
  final String name;
  final String description;
  final String muscleGroup;
  final String equipment;
  final String? videoUrl;

  const ExerciseModel({
    required this.id,
    required this.name,
    required this.description,
    required this.muscleGroup,
    required this.equipment,
    this.videoUrl,
  });

  factory ExerciseModel.fromJson(Map<String, dynamic> j) => ExerciseModel(
    id:          j['id']          as int?    ?? 0,
    name:        j['name']        as String? ?? '',
    description: j['description'] as String? ?? '',
    muscleGroup: j['muscleGroup'] as String? ?? '',
    equipment:   j['equipment']   as String? ?? '',
    videoUrl:    j['videoUrl']    as String?,
  );
}