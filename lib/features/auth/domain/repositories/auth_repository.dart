import '../../data/models/user_model.dart';

abstract class AuthRepository {
  Future<LoginResult> login(String email, String password);
  Future<void>        register(String email, String password, String name);
  Future<UserModel>   getProfile();
  Future<LoginResult> googleSignIn();
  Future<void>        logout();
}