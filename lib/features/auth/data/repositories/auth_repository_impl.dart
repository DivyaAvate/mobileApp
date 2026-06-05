import 'package:dio/dio.dart';
import '../../domain/repositories/auth_repository.dart';
import '../models/user_model.dart';

class AuthRepositoryImpl implements AuthRepository {
  final Dio dio;

  AuthRepositoryImpl(this.dio);

  @override
  Future<UserModel> login(String email, String password) async {
    final response = await dio.post('/auth/login', data: {
      'email': email,
      'password': password,
    });
    return UserModel.fromJson(response.data);
  }

  @override
  Future<UserModel> register(String email, String password, String name) async {
    final response = await dio.post('/auth/register', data: {
      'email': email,
      'password': password,
      'displayName': name,
    });
    return UserModel.fromJson(response.data);
  }

  @override
  Future<void> googleSignIn() async {}
}