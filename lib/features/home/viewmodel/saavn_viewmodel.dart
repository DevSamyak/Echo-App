import 'dart:async';
import 'dart:convert';

import 'package:client/core/providers/current_user_notifier.dart';
import 'package:client/features/home/model/song_model.dart';
import 'package:client/features/home/repositories/saavn_repository.dart';
import 'package:fpdart/fpdart.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:shared_preferences/shared_preferences.dart';

part 'saavn_viewmodel.g.dart';

/// One provider for every Saavn row on the Discover page.
///
///   ref.watch(saavnFeedProvider('trending'))  -> Top Hindi / Bollywood
///   ref.watch(saavnFeedProvider('punjabi'))   -> Punjabi hits
///   ref.watch(saavnFeedProvider('retro'))     -> Old classics
///
/// [section] must be a key from the server's SECTIONS map.
@riverpod
Future<List<SongModel>> saavnFeed(SaavnFeedRef ref, String section) async {
  final token = ref.watch(currentUserNotifierProvider.select((u) => u?.token));
  if (token == null) throw 'You are not logged in';

  final link = ref.keepAlive();
  final timer = Timer(const Duration(minutes: 10), link.close);
  ref.onDispose(timer.cancel);

  final prefs = await SharedPreferences.getInstance();
  final key = 'feed:$section';

  Future<List<SongModel>> fetchFresh() async {
    final res = await ref
        .read(saavnRepositoryProvider)
        .getFeed(token: token, section: section);
    switch (res) {
      case Left(value: final l):
        throw l.message;
      case Right(value: final r):
        await prefs.setString(key, jsonEncode(r.map((s) => s.toMap()).toList()));
        await prefs.setInt('$key:ts', DateTime.now().millisecondsSinceEpoch);
        return r;
    }
  }

  final cached = prefs.getString(key);
  if (cached != null) {
    final list = (jsonDecode(cached) as List)
        .map((m) => SongModel.fromMap(m as Map<String, dynamic>))
        .toList();
    final ageMs = DateTime.now().millisecondsSinceEpoch - (prefs.getInt('$key:ts') ?? 0);
    if (ageMs > const Duration(minutes: 10).inMilliseconds) {
      var disposed = false;
      ref.onDispose(() => disposed = true);
      // refresh quietly; UI already shows the cached songs
      fetchFresh().then((_) {
        if (!disposed) ref.invalidateSelf();
      }).catchError((_) {});
    }
    return list; // instant
  }

  try {
    return await fetchFresh();
  } catch (e) {
    link.close(); // don't cache a failure, so Retry really retries
    rethrow;
  }
}

/// Used by the Search tab. Auto-disposes so old searches don't pile up.
@riverpod
Future<List<SongModel>> saavnSearch(SaavnSearchRef ref, String query) async {
  final q = query.trim();
  if (q.isEmpty) return [];

  final token = ref.watch(currentUserNotifierProvider.select((u) => u?.token));
  if (token == null) throw 'You are not logged in';

  final res =
      await ref.watch(saavnRepositoryProvider).search(token: token, query: q);

  switch (res) {
    case Left(value: final l):
      throw l.message;
    case Right(value: final r):
      return r;
  }
}