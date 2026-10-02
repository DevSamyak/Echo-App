import 'dart:convert';

import 'package:client/core/constants/server_constants.dart';
import 'package:client/core/failure/failure.dart';
import 'package:client/core/models/user_model.dart';
//import 'package:flutter/material.dart';
import 'package:fpdart/fpdart.dart';
import 'package:http/http.dart' as http;
import 'package:riverpod_annotation/riverpod_annotation.dart';
part 'auth_remote_repository.g.dart';

@Riverpod(keepAlive: true)
AuthRemoteRepository authRemoteRepository(AuthRemoteRepositoryRef ref){
  return AuthRemoteRepository();
}
class AuthRemoteRepository {
  Future<Either<AppFailure, UserModel>> signup({
    required String name,
    required String email,
    required String password,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('${ServerConstants.serverUrl}/auth/signup'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'name': name, 'email': email, 'password': password}),
      ).timeout(const Duration(seconds: 90));

      final resBodyMap = jsonDecode(response.body) as Map<String, dynamic>;
      if (response.statusCode != 201) {
        //{'detail':'error message'}
        return Left(AppFailure(resBodyMap['detail']));
      }
      return Right(UserModel.fromMap(resBodyMap));
    } catch (e) {
      // print(e);
      return Left(AppFailure(e.toString()));
    }
  }

  Future<Either<AppFailure, UserModel>> login({
    required String email,
    required String password,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('${ServerConstants.serverUrl}/auth/login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email, 'password': password}),
      ).timeout(const Duration(seconds: 90));
      final resBodyMap = json.decode(response.body) as Map<String, dynamic>;
      if (response.statusCode != 200) {
        return Left(AppFailure(resBodyMap['detail']));
      } else {
        final token = resBodyMap['token'] as String?;
        //print('x-auth-token (from login): $token');
        return Right(
          UserModel.
          fromMap(resBodyMap['user']).
          copyWith(token:resBodyMap['token'])
        );
      }
    } catch (e) {
      return Left(AppFailure(e.toString()));
    }
  }

  Future<Either<AppFailure, UserModel>> getCurrentUserData(String token) async {
    try {
      print('x-auth-token (sent in header): $token');
      final response = await http.get(
        Uri.parse('${ServerConstants.serverUrl}/auth/'),
        headers: {
          'Content-Type': 'application/json',
          'x-auth-token': token,
        },
      );
      final resBodyMap = json.decode(response.body) as Map<String, dynamic>;
      if (response.statusCode != 200) {
        return Left(AppFailure(resBodyMap['detail']));
      } else {
       
        return Right(
          UserModel.
          fromMap(resBodyMap).
          copyWith(token:token)
        );
      }
    } catch (e) {
      return Left(AppFailure(e.toString()));
    }
  }
}
