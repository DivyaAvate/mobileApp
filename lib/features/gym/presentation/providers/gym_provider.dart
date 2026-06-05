import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/network/dio_provider.dart';
import '../../../../core/constants/api_endpoints.dart';

// ─── Models ───────────────────────────────────────────────────────────────────

class GymModel {
  final int id;
  final String name;
  final String? logoUrl;
  final String? address;
  final String? city;
  final String? phone;
  final String? description;

  const GymModel({
    required this.id,
    required this.name,
    this.logoUrl,
    this.address,
    this.city,
    this.phone,
    this.description,
  });

  factory GymModel.fromJson(Map<String, dynamic> j) => GymModel(
        id:          j['id']          as int,
        name:        j['name']        as String,
        logoUrl:     j['logoUrl']     as String?,
        address:     j['address']     as String?,
        city:        j['city']        as String?,
        phone:       j['phone']       as String?,
        description: j['description'] as String?,
      );
}

class OfferModel {
  final int id;
  final String title;
  final String? description;
  final String? imageUrl;
  final String type;
  final DateTime? expiresAt;

  const OfferModel({
    required this.id,
    required this.title,
    this.description,
    this.imageUrl,
    required this.type,
    this.expiresAt,
  });

  factory OfferModel.fromJson(Map<String, dynamic> j) => OfferModel(
        id:          j['id']          as int,
        title:       j['title']       as String,
        description: j['description'] as String?,
        imageUrl:    j['imageUrl']    as String?,
        type:        j['type']        as String? ?? 'announcement',
        expiresAt:   j['expiresAt'] != null
            ? DateTime.parse(j['expiresAt'] as String)
            : null,
      );
}

// ─── Gym List Provider (for member to browse) ─────────────────────────────────

final gymListProvider = FutureProvider<List<GymModel>>((ref) async {
  final dio      = ref.watch(dioProvider);
  final response = await dio.get(ApiEndpoints.gyms);
  return (response.data as List).map((e) => GymModel.fromJson(e)).toList();
});

// ─── My Gym Provider (member's joined gym) ────────────────────────────────────

final myGymProvider = FutureProvider<GymModel?>((ref) async {
  try {
    final dio      = ref.watch(dioProvider);
    final response = await dio.get(ApiEndpoints.myGym);
    return GymModel.fromJson(response.data);
  } catch (_) {
    return null; // not joined any gym yet
  }
});

// ─── Gym Offers Provider ──────────────────────────────────────────────────────

final gymOffersProvider = FutureProvider.family<List<OfferModel>, int>((ref, gymId) async {
  final dio      = ref.watch(dioProvider);
  final response = await dio.get(ApiEndpoints.gymOffers(gymId.toString()));
  return (response.data as List).map((e) => OfferModel.fromJson(e)).toList();
});

// ─── Join Gym Notifier ────────────────────────────────────────────────────────

class JoinGymState {
  final bool isLoading;
  final String? referralCode;
  final String? gymName;
  final String? error;

  const JoinGymState({
    this.isLoading    = false,
    this.referralCode,
    this.gymName,
    this.error,
  });
}

class JoinGymNotifier extends StateNotifier<JoinGymState> {
  final Dio _dio;
  JoinGymNotifier(this._dio) : super(const JoinGymState());

  Future<bool> joinGym(int gymId) async {
    state = const JoinGymState(isLoading: true);
    try {
      final response = await _dio.post(
        ApiEndpoints.joinGym,
        data: { 'gymId': gymId },
      );
      state = JoinGymState(
        referralCode: response.data['referralCode'] as String,
        gymName:      response.data['gymName']      as String,
      );
      return true;
    } catch (e) {
      state = JoinGymState(error: 'Failed to join gym. Try again.');
      return false;
    }
  }
}

final joinGymProvider =
    StateNotifierProvider<JoinGymNotifier, JoinGymState>((ref) {
  return JoinGymNotifier(ref.watch(dioProvider));
});