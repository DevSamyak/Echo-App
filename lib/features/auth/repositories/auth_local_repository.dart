import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:shared_preferences/shared_preferences.dart';

part 'auth_local_repository.g.dart';

@Riverpod(keepAlive: true)
AuthLocalRepository authLocalRepository(AuthLocalRepositoryRef ref) {
  return AuthLocalRepository();
}

class AuthLocalRepository {
  late SharedPreferences _sharedPreferences;

  Future<void> init() async {
    _sharedPreferences = await SharedPreferences.getInstance();
  }

  // FIXED: Changed to Future<void> so it finishes saving
  Future<void> setToken(String? token) async {
    if (token != null) {
      await _sharedPreferences.setString('x-auth-token', token);
    }
  }

  String? getToken() {
    return _sharedPreferences.getString('x-auth-token');
  }

  // ADDED: Needed for logout functionality
  Future<void> removeToken() async {
    await _sharedPreferences.remove('x-auth-token');
  }

  Future<void> setUserJson(String json) async => _sharedPreferences.setString('cached-user', json);
  String? getUserJson() => _sharedPreferences.getString('cached-user');
  Future<void> removeUser() async => _sharedPreferences.remove('cached-user');
}