import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../../data/repositories/auth_repository_impl.dart';
import '../../data/models/user_model.dart';
import '../../../../core/network/dio_provider.dart';

// ─── Secure Storage ───────────────────────────────────────────────────────────

final _storage = const FlutterSecureStorage();

// ─── Repository Provider ──────────────────────────────────────────────────────

final authRepositoryProvider = Provider((ref) =>
    AuthRepositoryImpl(ref.watch(dioProvider)));

// ─── Auth State ───────────────────────────────────────────────────────────────

class AuthState {
  final UserModel? user;
  final bool       isLoading;
  final String?    error;

  const AuthState({
    this.user,
    this.isLoading = false,
    this.error,
  });

  bool get isLoggedIn  => user != null;
  bool get isGymOwner  => user?.role == 'gym_owner';
  bool get isMember    => user?.role == 'member';

  AuthState copyWith({UserModel? user, bool? isLoading, String? error}) =>
      AuthState(
        user:      user      ?? this.user,
        isLoading: isLoading ?? this.isLoading,
        error:     error,
      );
}

// ─── Auth Notifier ────────────────────────────────────────────────────────────

class AuthNotifier extends StateNotifier<AuthState> {
  final AuthRepositoryImpl _repo;

  AuthNotifier(this._repo) : super(const AuthState()) {
    _tryAutoLogin();
  }

  // Auto-login on app start if token exists
  Future<void> _tryAutoLogin() async {
    final token = await _storage.read(key: 'auth_token');
    if (token == null) return;
    try {
      final user = await _repo.getProfile();
      state = state.copyWith(user: user);
    } catch (_) {
      await _storage.deleteAll(); // clear invalid token
    }
  }

  // ── Login ────────────────────────────────────────────────────
  Future<String?> login(String email, String password) async {
    state = state.copyWith(isLoading: true);
    try {
      final result = await _repo.login(email, password);

      // Save tokens securely
      await _storage.write(key: 'auth_token',     value: result.accessToken);
      await _storage.write(key: 'refresh_token',  value: result.refreshToken);

      state = state.copyWith(isLoading: false, user: result.user);

      // Return route based on role
      if (result.user.role == 'gym_owner') return '/gym-owner';
      if (result.user.isOnboarded == true) return '/home';
      return '/onboarding'; // new member → onboard first
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      return null;
    }
  }

  // ── Register ─────────────────────────────────────────────────
  Future<bool> register(String email, String password, String name) async {
    state = state.copyWith(isLoading: true);
    try {
      await _repo.register(email, password, name);
      state = state.copyWith(isLoading: false);
      return true;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      return false;
    }
  }

  // ── Logout ───────────────────────────────────────────────────
  Future<void> logout() async {
    await _storage.deleteAll();
    state = const AuthState();
  }
}

// ─── Provider ─────────────────────────────────────────────────────────────────

final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  return AuthNotifier(ref.watch(authRepositoryProvider));
});