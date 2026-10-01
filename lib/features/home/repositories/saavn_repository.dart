import 'dart:convert';

import 'package:client/core/constants/server_constants.dart';
import 'package:client/core/failure/failure.dart';
import 'package:client/features/home/model/song_model.dart';
import 'package:fpdart/fpdart.dart';
import 'package:http/http.dart' as http;
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'saavn_repository.g.dart';

@Riverpod(keepAlive: true)
SaavnRepository saavnRepository(SaavnRepositoryRef ref) {
  return SaavnRepository();
}

/// Talks to our own FastAPI server (/saavn/...), which proxies the JioSaavn
/// API and returns songs already shaped like SongModel.
class SaavnRepository {
  /// [section] is one of the keys defined in the server's SECTIONS map:
  /// trending, new, punjabi, romantic, retro, arijit, party, tamil, telugu.
  Future<Either<AppFailure, List<SongModel>>> getFeed({
    required String token,
    required String section,
    int limit = 20,
  }) {
    return _get(token, '/saavn/feed', {
      'section': section,
      'limit': '$limit',
    });
  }

  Future<Either<AppFailure, List<SongModel>>> search({
    required String token,
    required String query,
    int limit = 20,
  }) {
    return _get(token, '/saavn/search', {
      'q': query,
      'limit': '$limit',
    });
  }

  Future<Either<AppFailure, List<SongModel>>> _get(
    String token,
    String path,
    Map<String, String> params,
  ) async {
    try {
      final uri = Uri.parse('${ServerConstants.serverUrl}$path')
          .replace(queryParameters: params);

      // Long timeout: Echo's server AND the Saavn service on Render may both
      // be asleep, and the first request has to wake them one after the other.
      final res = await http
          .get(uri, headers: {'x-auth-token': token})
          .timeout(const Duration(seconds: 90));

      if (res.statusCode != 200) {
        return Left(AppFailure(_errorMessage(res)));
      }

      final list = jsonDecode(res.body) as List;
      final songs = list
          .map((m) => SongModel.fromMap(m as Map<String, dynamic>))
          .toList();
      return Right(songs);
    } catch (e) {
      return Left(AppFailure(e.toString()));
    }
  }

  String _errorMessage(http.Response res) {
    try {
      final body = jsonDecode(res.body);
      if (body is Map && body['detail'] != null) {
        return body['detail'].toString();
      }
    } catch (_) {}
    return 'Request failed (${res.statusCode})';
  }
}