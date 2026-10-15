import 'package:client/core/providers/current_user_notifier.dart';
import 'package:client/core/models/user_model.dart';
import 'package:client/features/auth/repositories/auth_local_repository.dart';
import 'package:client/features/auth/repositories/auth_remote_repository.dart';
import 'package:client/features/auth/repositories/firebase_auth_repository.dart';
import 'package:fpdart/fpdart.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'auth_viewmodel.g.dart';

@riverpod
class AuthViewmodel extends _$AuthViewmodel {
  late AuthRemoteRepository _authRemoteRepository;
  late AuthLocalRepository _authLocalRepository;
  late CurrentUserNotifier _currentUserNotifier;
  late FirebaseAuthRepository _firebaseAuthRepository;
  String? _verificationId;

  @override
  AsyncValue<UserModel>? build() {
    _authRemoteRepository = ref.watch(authRemoteRepositoryProvider);
    _authLocalRepository = ref.watch(authLocalRepositoryProvider);
    _currentUserNotifier = ref.watch(currentUserNotifierProvider.notifier);
    _firebaseAuthRepository = ref.watch(firebaseAuthRepositoryProvider);
    return null;
  }

  Future<void> initSharedPreferences() async {
    await _authLocalRepository.init();
  }

  Future<void> signInWithGoogle() async {
    state = const AsyncValue.loading();
    final tokenRes = await _firebaseAuthRepository.signInWithGoogle();

    switch (tokenRes) {
      case Left(value: final l):
        state = AsyncValue.error(l.message, StackTrace.current);
      case Right(value: final token):
        final res = await _authRemoteRepository.authenticateWithFirebase(
          firebaseToken: token,
        );
        switch (res) {
          case Left(value: final l):
            state = AsyncValue.error(l.message, StackTrace.current);
          case Right(value: final user):
            state = _loginSuccess(user);
        }
    }
  }

  Future<bool> sendOtp(String phoneNumber) async {
    state = const AsyncValue.loading();
    final res = await _firebaseAuthRepository.sendOtp(
      phoneNumber: phoneNumber,
      onCodeSent: (verificationId) {
        _verificationId = verificationId;
      },
      onError: (failure) {
        state = AsyncValue.error(failure.message, StackTrace.current);
      },
    );

    return switch (res) {
      Left(value: final l) => () {
          state = AsyncValue.error(l.message, StackTrace.current);
          return false;
        }(),
      Right(value: final verificationId) => () {
          _verificationId = verificationId;
          state = null;
          return true;
        }(),
    };
  }

  Future<void> verifyOtp(String smsCode) async {
    if (_verificationId == null) {
      state = AsyncValue.error(
        'Verification ID not found. Please resend OTP.',
        StackTrace.current,
      );
      return;
    }
    state = const AsyncValue.loading();
    final tokenRes = await _firebaseAuthRepository.verifyOtp(
      verificationId: _verificationId!,
      smsCode: smsCode,
    );

    switch (tokenRes) {
      case Left(value: final l):
        state = AsyncValue.error(l.message, StackTrace.current);
      case Right(value: final token):
        final res = await _authRemoteRepository.authenticateWithFirebase(
          firebaseToken: token,
        );
        switch (res) {
          case Left(value: final l):
            state = AsyncValue.error(l.message, StackTrace.current);
          case Right(value: final user):
            state = _loginSuccess(user);
        }
    }
  }

  AsyncValue<UserModel>? _loginSuccess(UserModel user) {
    _authLocalRepository.setUserJson(user.toJson());
    _authLocalRepository.setToken(user.token);
    _currentUserNotifier.addUser(user);
    return state = AsyncValue.data(user);
  }

  Future<UserModel?> getData() async {
    final token = _authLocalRepository.getToken();
    if (token == null) return null;

    final res = await _authRemoteRepository.getCurrentUserData(token);
    if (_authLocalRepository.getToken() != token) return null;

    return switch (res) {
      Left() => null,
      Right(value: final r) => _getDataSuccess(r).value,
    };
  }

  AsyncValue<UserModel> _getDataSuccess(UserModel user) {
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