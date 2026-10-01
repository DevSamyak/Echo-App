import 'package:client/core/providers/current_user_notifier.dart';
import 'package:client/core/models/user_model.dart';
import 'package:client/features/auth/repositories/auth_local_repository.dart';
import 'package:client/features/auth/repositories/auth_remote_repository.dart';
import 'package:fpdart/fpdart.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'auth_viewmodel.g.dart';

@riverpod
class AuthViewmodel extends _$AuthViewmodel {
  late AuthRemoteRepository _authRemoteRepository;
  late AuthLocalRepository _authLocalRepository;
  late CurrentUserNotifier _currentUserNotifier;

  @override
  AsyncValue<UserModel>? build() {
    _authRemoteRepository = ref.watch(authRemoteRepositoryProvider);
    _authLocalRepository = ref.watch(authLocalRepositoryProvider);
    _currentUserNotifier = ref.watch(currentUserNotifierProvider.notifier); 
    return null;
  }

  Future<void> initSharedPreferences() async {
    await _authLocalRepository.init();
  }

  Future<void> signUpUser({
    required String name,
    required String email,
    required String password,
  }) async {
    state = const AsyncValue.loading();

    final res = await _authRemoteRepository.signup(
      name: name,
      email: email,
      password: password,
    );

    final val = switch (res) {
      Left(value: final l) =>
        state = AsyncValue.error(l.message, StackTrace.current),
      Right(value: final r) => state = AsyncValue.data(r),
    };
    //print(val);
  }

  Future<void> loginUser({
    required String email,
    required String password,
  }) async {
    state = const AsyncValue.loading();

    final res = await _authRemoteRepository.login(
      email: email,
      password: password,
    );

    final val = switch(res){
      Left(value:final l)=> state = AsyncValue.error(
        l.message,
        StackTrace.current
      ),
      Right(value:final r)=> state = _loginSuccess(r)
    };
    print(val);
  }

  AsyncValue<UserModel>? _loginSuccess(UserModel user) {
    _authLocalRepository.setUserJson(user.toJson());
    _authLocalRepository.setToken(user.token);
    _currentUserNotifier.addUser(user);
    return state = AsyncValue.data(user);
  }

  Future<UserModel?> getData() async {
    //state = const AsyncValue.loading();
    final token = _authLocalRepository.getToken();
    if (token == null) return null; // nothing to verify, don't touch state

    final res = await _authRemoteRepository.getCurrentUserData(token);
    if (_authLocalRepository.getToken() != token) return null; // logged out meanwhile

    return switch (res) {
      Left() => null, // offline or Echo asleep: keep the cached user
      Right(value: final r) => _getDataSuccess(r).value,
    };
  }
  AsyncValue<UserModel> _getDataSuccess(UserModel user){
    _authLocalRepository.setUserJson(user.toJson());
    _currentUserNotifier.addUser(user);
    return state = AsyncValue.data(user);
  }

  UserModel? loadCachedUser() {
    final raw = _authLocalRepository.getUserJson();
    if (raw == null) return null;
    try {
      final u = UserModel.fromJson(raw);
      _currentUserNotifier.addUser(u);
      return u;
    } catch (_) {
      return null;
    }
  }
}