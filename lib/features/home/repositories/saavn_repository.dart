import 'dart:async';
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
  /// Added [page] parameter to support fetching fresh data and pagination
  Future<Either<AppFailure, List<SongModel>>> getFeed({
    required String token,
    required String section,
    int limit = 20,
    int page = 1,
  }) {
    return _get(token, '/saavn/feed', {
      'section': section,
      'limit': '$limit',
      'page': '$page',
    });
  }

  /// Added [page] parameter to support fetching deeper search results
  Future<Either<AppFailure, List<SongModel>>> search({
    required String token,
    required String query,
    int limit = 20,
    int page = 1,
  }) {
    return _get(token, '/saavn/search', {
      'q': query,
      'limit': '$limit',
      'page': '$page',
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

      final res = await http
          .get(uri, headers: {'x-auth-token': token})
          .timeout(
        const Duration(seconds: 90),
        onTimeout: () {
          // Explicitly throw a clean timeout exception instead of a raw socket error
          throw TimeoutException("Server is waking up from sleep. Please try again.");
        },
      );

      if (res.statusCode != 200) {
        return Left(AppFailure(_errorMessage(res)));
      }

      final list = jsonDecode(res.body) as List;
      final songs = list
          .map((m) => SongModel.fromMap(m as Map<String, dynamic>))
          .toList();
      return Right(songs);
      
    } on TimeoutException catch (e) {
      return Left(AppFailure(e.message ?? "Connection timed out."));
    } catch (e) {
      // Catching other errors (like "Device connection failed") cleanly
      return Left(AppFailure("Network error: ${e.toString()}"));
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