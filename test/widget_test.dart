import 'package:client/core/failure/failure.dart';
import 'package:client/features/auth/repositories/firebase_auth_repository.dart';
import 'package:client/main.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';

class FakeFirebaseAuthRepository implements FirebaseAuthRepository {
  @override
  Future<Either<AppFailure, String>> signInWithGoogle() async =>
      const Right('fake-token');

  @override
  Future<Either<AppFailure, String>> sendOtp({
    required String phoneNumber,
    required Function(String verificationId) onCodeSent,
    required Function(AppFailure) onError,
  }) async {
    onCodeSent('fake-verification-id');
    return const Right('fake-verification-id');
  }

  @override
  Future<Either<AppFailure, String>> verifyOtp({
    required String verificationId,
    required String smsCode,
  }) async =>
      const Right('fake-token');

  @override
  Future<void> signOut() async {}
}

void main() {
  testWidgets('AuthPage smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          firebaseAuthRepositoryProvider
              .overrideWithValue(FakeFirebaseAuthRepository()),
        ],
        child: const MyApp(),
      ),
    );

    expect(find.text('Echo'), findsOneWidget);
    expect(find.text('Sign in to continue'), findsOneWidget);
    expect(find.text('Send OTP'), findsOneWidget);
    expect(find.text('Sign in with Google'), findsOneWidget);
  });
}
