import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/repositories/auth_repository_impl.dart';
import '../../../../core/util/api_client.dart';
import '../../data/models/user_model.dart';

// 1. Define the Repository Provider
final authRepositoryProvider = Provider((ref) => AuthRepositoryImpl(ref.watch(dioProvider)));

// 2. Define the StateNotifier Provider
final authControllerProvider = StateNotifierProvider<AuthController, AsyncValue<UserModel?>>((ref) {
  final repo = ref.watch(authRepositoryProvider);
  return AuthController(repo); // This now matches the constructor below
});

// 3. The Controller Class
class AuthController extends StateNotifier<AsyncValue<UserModel?>> {
  final AuthRepositoryImpl _repository; // <--- This was missing!

  // Constructor must take the repository AND pass initial state to super
  AuthController(this._repository) : super(const AsyncValue.data(null));

  Future<void> login(String email, String password) async {
    state = const AsyncValue.loading();
    try {
      final user = await _repository.login(email, password);
      state = AsyncValue.data(user);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> register(String email, String password, String name) async {
    state = const AsyncValue.loading();
    try {
      final user = await _repository.register(email, password, name);
      state = AsyncValue.data(user);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }
}