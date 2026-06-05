class SetLogModel {
  final double weight;
  final int reps;
  final bool isPR;

  SetLogModel({required this.weight, required this.reps, this.isPR = false});
}

class ActiveExercise {
  final int exerciseId;
  final String name;
  final List<SetLogModel> sets;

  ActiveExercise({required this.exerciseId, required this.name, required this.sets});
}