class ExerciseModel {
  final int id;
  final String name;
  final String description;
  final String muscleGroup;
  final String equipment;
  final String? videoUrl;

  ExerciseModel({
    required this.id,
    required this.name,
    required this.description,
    required this.muscleGroup,
    required this.equipment,
    this.videoUrl,
  });

  factory ExerciseModel.fromJson(Map<String, dynamic> json) {
    return ExerciseModel(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      muscleGroup: json['muscleGroup'],
      equipment: json['equipment'],
      videoUrl: json['videoUrl'],
    );
  }
}