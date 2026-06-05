import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/util/api_client.dart';
import '../../data/models/dashboard_model.dart';

final dashboardProvider = FutureProvider<DashboardModel>((ref) async {
  final dio = ref.watch(dioProvider);
  final response = await dio.get('/dashboard');
  return DashboardModel.fromJson(response.data);
});