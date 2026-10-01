import 'dart:convert';
import 'dart:io';

import 'package:client/core/constants/server_constants.dart';
import 'package:client/core/failure/failure.dart';
import 'package:client/features/auth/repositories/auth_local_repository.dart';
import 'package:client/features/home/model/song_model.dart';
import 'package:fpdart/fpdart.dart';
import 'package:http/http.dart' as http;
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'home_repository.g.dart';

@riverpod
HomeRepository homeRepository(HomeRepositoryRef ref) {
  return HomeRepository(ref.watch(authLocalRepositoryProvider));
}

class HomeRepository {
  final AuthLocalRepository _authLocal;
  
  HomeRepository(this._authLocal);

  Future<Either<AppFailure, String>> uploadSong({
    required File selectedThumbnail,
    required File selectedAudio,
    required String artist,
    required String songName,
    required String hexCode,
    required String token
  }) async {
    try {
      final token = _authLocal.getToken();
      if (token == null) {
        return Left(AppFailure('User is not authenticated.'));
      }

      final request = http.MultipartRequest(
        'POST',
        Uri.parse('${ServerConstants.serverUrl}/song/upload'),
      );

      request.files.addAll([
        await http.MultipartFile.fromPath(
          'song',
          selectedAudio.path,
        ),
        await http.MultipartFile.fromPath(
          'thumbnail',
          selectedThumbnail.path,
        ),
      ]);

      request.fields.addAll({
        'artist': artist,
        'song_name': songName,
        'hex_code': hexCode,
      });

      request.headers.addAll({'x-auth-token': token});

      final streamedResponse = await request.send().timeout(const Duration(minutes: 5));
      final response = await http.Response.fromStream(streamedResponse);

      // Checking for both 200 and 201 to be safe based on your backend implementation
      if (response.statusCode != 201 && response.statusCode != 200) {
        return Left(AppFailure(response.body));
      }
      
      return Right(response.body);
    } catch (e) {
      return Left(AppFailure('Upload failed: $e'));
    }
  }

  Future<Either<AppFailure,List<SongModel>>> getAllSongs({
    required String token,
  }) async{
    try{
      final res = await http.get(
        Uri.parse(
          '${ServerConstants.serverUrl}/song/list'
        ),
        headers: {
          'Content-Type':'application/json',
          'x-auth-token':token,
        }
      );
      var resBodyMap = jsonDecode(res.body);
      if(res.statusCode!=200){
        resBodyMap = resBodyMap  as Map<String,dynamic>;
        return Left(AppFailure(resBodyMap['detail']));
      }
      resBodyMap = resBodyMap as List;

      List<SongModel> songs=[];
      for(final map in resBodyMap){
        songs.add(SongModel.fromMap(map));
      }
      return Right(songs);
    }
    catch(e){
      return Left(AppFailure(e.toString()));
    }
  }
   Future<Either<AppFailure, bool>> favSong({
    required String token,
    required String songId,
  }) async {
    try {
      final res = await http.post(
        Uri.parse('${ServerConstants.serverUrl}/song/favourite'),
        headers: {
          'Content-Type': 'application/json',
          'x-auth-token': token,
        },
        body: jsonEncode(
          {
            "song_id": songId,
          },
        ),
      );
      var resBodyMap = jsonDecode(res.body);

      if (res.statusCode != 200) {
        resBodyMap = resBodyMap as Map<String, dynamic>;
        return Left(AppFailure(resBodyMap['detail']));
      }

      return Right(resBodyMap['message']);
    } catch (e) {
      return Left(AppFailure(e.toString()));
    }
  }

  Future<Either<AppFailure, List<SongModel>>> getFavSongs({
    required String token,
  }) async {
    try {
      final res = await http.get(
        Uri.parse('${ServerConstants.serverUrl}/song/list/favourites'),
        headers: {
          'Content-Type': 'application/json',
          'x-auth-token': token,
        },
      );
      var resBodyMap = jsonDecode(res.body);

      if (res.statusCode != 200) {
        resBodyMap = resBodyMap as Map<String, dynamic>;
        return Left(AppFailure(resBodyMap['detail']));
      }
      resBodyMap = resBodyMap as List;

      List<SongModel> songs = [];

      for (final map in resBodyMap) {
        songs.add(SongModel.fromMap(map['song']));
      }

      return Right(songs);
    } catch (e) {
      return Left(AppFailure(e.toString()));
    }
  }
}