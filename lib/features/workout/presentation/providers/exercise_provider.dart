import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/network/dio_provider.dart';
import '../../../../core/constants/api_endpoints.dart';
import '../../data/models/exercise_model.dart';

final exerciseListProvider = FutureProvider.family<
    List<ExerciseModel>, Map<String, String>>((ref, filters) async {

  final dio = ref.watch(dioProvider);

  // Remove empty filters so backend doesn't get blank params
  final cleanFilters = Map<String, String>.from(filters)
    ..removeWhere((_, v) => v.isEmpty || v == 'all');

  final response = await dio.get(
    ApiEndpoints.exercises,
    queryParameters: cleanFilters.isNotEmpty ? cleanFilters : null,
  );

  return (response.data as List)
      .map((e) => ExerciseModel.fromJson(e as Map<String, dynamic>))
      .toList();
});