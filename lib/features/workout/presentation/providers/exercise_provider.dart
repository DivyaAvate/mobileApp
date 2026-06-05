import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/util/api_client.dart';
import '../../data/models/exercise_model.dart';

final exerciseListProvider = FutureProvider.family<List<ExerciseModel>, Map<String, String>>((ref, filters) async {
  final dio = ref.watch(dioProvider);
  final response = await dio.get('/exercises', queryParameters: filters);
  return (response.data as List).map((e) => ExerciseModel.fromJson(e)).toList();
});