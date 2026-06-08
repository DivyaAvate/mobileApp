import 'package:dio/dio.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../../domain/repositories/auth_repository.dart';
import '../models/user_model.dart';
import '../../../../core/constants/api_endpoints.dart';

class AuthRepositoryImpl implements AuthRepository {
  final Dio _dio;
  final _googleSignIn = GoogleSignIn();

  AuthRepositoryImpl(this._dio);

  // ── Login ─────────────────────────────────────────────────
  @override
  Future<LoginResult> login(String email, String password) async {
    final response = await _dio.post(
      ApiEndpoints.login,
      data: { 'email': email, 'password': password },
    );
    return LoginResult.fromJson(response.data as Map<String, dynamic>);
  }

  // ── Register ──────────────────────────────────────────────
  @override
  Future<void> register(
    String email,
    String password,
    String name, {
    String role = 'member',
  }) async {
    await _dio.post(
      ApiEndpoints.register,
      data: {
        'email':       email,
        'password':    password,
        'displayName': name,
        'role':        role,
      },
    );
  }

  // ── Get profile ───────────────────────────────────────────
  @override
  Future<UserModel> getProfile() async {
    final response = await _dio.get(ApiEndpoints.profile);
    return UserModel.fromJson(response.data as Map<String, dynamic>);
  }

  // ── Google Sign-In ────────────────────────────────────────
  @override
  Future<LoginResult> googleSignIn() async {
    final account = await _googleSignIn.signIn();
    if (account == null) throw Exception('Google sign-in cancelled');

    final auth    = await account.authentication;
    final idToken = auth.idToken;
    if (idToken == null) throw Exception('Failed to get Google ID token');

    final response = await _dio.post(
      ApiEndpoints.googleAuth,
      data: { 'idToken': idToken },
    );
    return LoginResult.fromJson(response.data as Map<String, dynamic>);
  }

  // ── Logout ────────────────────────────────────────────────
  @override
  Future<void> logout() async {
    try {
      await _dio.post(ApiEndpoints.logout);
    } catch (_) {}
  }
}