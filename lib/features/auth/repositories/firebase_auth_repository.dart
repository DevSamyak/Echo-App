import 'dart:async';

import 'package:client/core/failure/failure.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fpdart/fpdart.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'firebase_auth_repository.g.dart';

@Riverpod(keepAlive: true)
FirebaseAuthRepository firebaseAuthRepository(FirebaseAuthRepositoryRef ref) {
  return FirebaseAuthRepository();
}

class FirebaseAuthRepository {
  final FirebaseAuth _firebaseAuth;
  final GoogleSignIn _googleSignIn;

  FirebaseAuthRepository({
    FirebaseAuth? firebaseAuth,
    GoogleSignIn? googleSignIn,
  })  : _firebaseAuth = firebaseAuth ?? FirebaseAuth.instance,
        _googleSignIn = googleSignIn ?? GoogleSignIn();

  Future<Either<AppFailure, String>> signInWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
        return Left(AppFailure('Google sign in was cancelled'));
      }
      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;
      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );
      final UserCredential userCredential =
          await _firebaseAuth.signInWithCredential(credential);
      final String? idToken = await userCredential.user?.getIdToken();
      if (idToken == null) {
        return Left(AppFailure('Failed to retrieve Firebase ID token'));
      }
      return Right(idToken);
    } catch (e) {
      return Left(AppFailure(e.toString()));
    }
  }

  Future<Either<AppFailure, String>> sendOtp({
    required String phoneNumber,
    required Function(String verificationId) onCodeSent,
    required Function(AppFailure) onError,
  }) async {
    try {
      final completer = Completer<Either<AppFailure, String>>();

      await _firebaseAuth.verifyPhoneNumber(
        phoneNumber: phoneNumber,
        verificationCompleted: (PhoneAuthCredential credential) {},
        verificationFailed: (FirebaseAuthException e) {
          final failure = AppFailure(e.message ?? 'Phone verification failed');
          onError(failure);
          if (!completer.isCompleted) {
            completer.complete(Left(failure));
          }
        },
        codeSent: (String verificationId, int? resendToken) {
          onCodeSent(verificationId);
          if (!completer.isCompleted) {
            completer.complete(Right(verificationId));
          }
        },
        codeAutoRetrievalTimeout: (String verificationId) {},
      );

      return await completer.future;
    } catch (e) {
      final failure = AppFailure(e.toString());
      onError(failure);
      return Left(failure);
    }
  }

  Future<Either<AppFailure, String>> verifyOtp({
    required String verificationId,
    required String smsCode,
  }) async {
    try {
      final PhoneAuthCredential credential = PhoneAuthProvider.credential(
        verificationId: verificationId,
        smsCode: smsCode,
      );
      final UserCredential userCredential =
          await _firebaseAuth.signInWithCredential(credential);
      final String? idToken = await userCredential.user?.getIdToken();
      if (idToken == null) {
        return Left(AppFailure('Failed to retrieve Firebase ID token'));
      }
      return Right(idToken);
    } catch (e) {
      return Left(AppFailure(e.toString()));
    }
  }

  Future<void> signOut() async {
    try {
      await _firebaseAuth.signOut();
      await _googleSignIn.signOut();
    } catch (_) {}
  }
}
