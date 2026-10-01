import 'package:client/features/home/model/song_model.dart';
import 'package:hive/hive.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
part 'home_local_repository.g.dart';

@riverpod
HomeLocalRepository homeLocalRepository(HomeLocalRepositoryRef ref) {
  return HomeLocalRepository();
}

class HomeLocalRepository {
  final Box box = Hive.box();

  void uploadLocalsong(SongModel song, String userId) {
    box.put('${userId}_${song.id}', song.toJson());
  }

  List<SongModel> loadSong(String userId) {
    List<SongModel> songs = [];
    for (final key in box.keys) {
      // only load keys that belong to this user
      if (key.toString().startsWith('${userId}_')) {
        songs.add(SongModel.fromJson(box.get(key)));
      }
    }
    return songs;
  }

  void clearBox() {
    box.clear();
  }
}