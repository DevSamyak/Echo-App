import 'dart:io';
import 'dart:ui';

import 'package:client/core/providers/current_user_notifier.dart';
import 'package:client/core/utils.dart';
import 'package:client/features/home/model/fav_song_model.dart';
import 'package:client/features/home/model/song_model.dart';
import 'package:client/features/home/repositories/home_local_repository.dart';
import 'package:client/features/home/repositories/home_repository.dart';
import 'package:fpdart/fpdart.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
part 'home_viewmodel.g.dart';


@riverpod
Future<List<SongModel>> getAllSongs(GetAllSongsRef ref) async{
  final token = ref.watch(currentUserNotifierProvider.select((user)=> user!.token));
  final res= await ref.watch(homeRepositoryProvider).getAllSongs(token:token,);

  final val = switch(res){
    Left(value:final l)=> throw l.message,
    Right(value:final r)=>r,
  };
  return val;
}
@riverpod
Future<List<SongModel>> getFavSongs(GetFavSongsRef ref) async{
  final token = ref.watch(currentUserNotifierProvider.select((user)=> user!.token));
  final res= await ref.watch(homeRepositoryProvider).getFavSongs(token:token,);

  final val = switch(res){
    Left(value:final l)=> throw l.message,
    Right(value:final r)=>r,
  };
  return val;
}

@riverpod
class HomeViewmodel extends _$HomeViewmodel{
  late HomeRepository _homeRepository;
  late HomeLocalRepository _homeLocalRepository;
  @override
  AsyncValue? build(){
    _homeRepository= ref.watch(homeRepositoryProvider);
    _homeLocalRepository = ref.watch(homeLocalRepositoryProvider); 
    return null;
  }

  Future<void> uploadSong({
  required File selectedAudio,
  required File selectedThumbnail,
  required String song_name,
  required String artist_name,
  required Color selectedColor
  }) async{
    state = const AsyncValue.loading();
    final res = await  _homeRepository.uploadSong(
      selectedThumbnail: selectedThumbnail, 
      selectedAudio: selectedAudio, 
      artist: artist_name, 
      songName: song_name, 
      hexCode: rgbtoHex(selectedColor), 
      token: ref.read(currentUserNotifierProvider)!.token
    );
    final val= switch(res) {
      Left(value:final l) => state = AsyncValue.error(l.message, StackTrace.current),
      Right(value:final r) => state = AsyncValue.data(r)
    };
    print(val);
  }
  //function for getting recentlyplayed songs from the
  List<SongModel> getRecentlyPlayedSong(){
    //it is like wrapper function so that the viewmodel is called not the
    //repository
    final userId = ref.read(currentUserNotifierProvider)?.id;
    if (userId == null) return [];
    return _homeLocalRepository.loadSong(userId);
  }

   Future<void> favSong({
    required String SongId
  }) async{
    state = const AsyncValue.loading();
    final res = await  _homeRepository.favSong(
      songId: SongId,
      token: ref.read(currentUserNotifierProvider)!.token
    );
    final val= switch(res) {
      Left(value:final l) => state = AsyncValue.error(l.message, StackTrace.current),
      Right(value:final r) => state = _favSongSuccess(r, SongId)
    };
    print(val);
  }
   AsyncValue _favSongSuccess(bool isFavorited, String songId) {
    final userNotifier = ref.read(currentUserNotifierProvider.notifier);
    if (isFavorited) {
      userNotifier.addUser(
        ref.read(currentUserNotifierProvider)!.copyWith(
          favourites: [
            ...ref.read(currentUserNotifierProvider)!.favourites,
            FavSongModel(
              id: '',
              song_id: songId,
              user_id: '',
            ),
          ],
        ),
      );
    } else {
      userNotifier.addUser(
        ref.read(currentUserNotifierProvider)!.copyWith(
              favourites: ref
                  .read(currentUserNotifierProvider)!
                  .favourites
                  .where(
                    (fav) => fav.song_id != songId,
                  )
                  .toList(),
            ),
      );
    }
    ref.invalidate(getFavSongsProvider);
    return state = AsyncValue.data(isFavorited);
  }
}