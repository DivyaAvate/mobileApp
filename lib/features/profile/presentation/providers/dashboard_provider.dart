import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/network/dio_provider.dart';
import '../../../../core/constants/api_endpoints.dart';
import '../../data/models/dashboard_model.dart';

final dashboardProvider = FutureProvider<DashboardModel>((ref) async {
  final dio      = ref.watch(dioProvider);
  final response = await dio.get(ApiEndpoints.dashboard);
  return DashboardModel.fromJson(response.data as Map<String, dynamic>);
});