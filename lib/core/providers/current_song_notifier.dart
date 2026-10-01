import 'dart:async';

import 'package:client/core/providers/current_user_notifier.dart';
import 'package:client/features/home/model/song_model.dart';
import 'package:client/features/home/repositories/home_local_repository.dart';
import 'package:just_audio_background/just_audio_background.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:just_audio/just_audio.dart';
part 'current_song_notifier.g.dart';

@riverpod
class CurrentSongNotifier extends _$CurrentSongNotifier {
  late HomeLocalRepository _homeLocalRepository;
  AudioPlayer? audioPlayer;
  bool isPlaying = false;

  // The list of songs the player can move through (next / previous).
  List<SongModel> _queue = [];
  StreamSubscription<int?>? _indexSub;
  StreamSubscription<PlayerState>? _playerStateSub;

  bool get hasNext => audioPlayer?.hasNext ?? false;
  bool get hasPrevious => audioPlayer?.hasPrevious ?? false;

  @override
  SongModel? build() {
    _homeLocalRepository = ref.watch(homeLocalRepositoryProvider);
    ref.onDispose(() {
      _indexSub?.cancel();
      _playerStateSub?.cancel();
    });
    return null;
  }

  /// Plays [song]. Pass the list it was tapped from as [queue] so that
  /// next/previous know what to move through.
  Future<void> updateSong(SongModel song, {List<SongModel>? queue}) async {
    // Fall back to a single-song queue if the song isn't in the given list.
    var songs = queue ?? [song];
    var index = songs.indexWhere((s) => s.id == song.id);
    if (index == -1) {
      songs = [song];
      index = 0;
    }
    _queue = List.of(songs);

    final player = _ensurePlayer();
    await player.stop();

    final playlist = ConcatenatingAudioSource(
      useLazyPreparation: true, // only prepares the song about to play
      children: _queue.map(_toAudioSource).toList(),
    );
    await player.setAudioSource(
      playlist,
      initialIndex: index,
      initialPosition: Duration.zero,
    );

    _onSongChanged(_queue[index]);
    player.play(); // don't await: the future completes when playback stops
  }

  AudioSource _toAudioSource(SongModel song) {
    return AudioSource.uri(
      Uri.parse(song.song_url),
      tag: MediaItem(
        id: song.id,
        title: song.song_name,
        artist: song.artist,
        artUri: Uri.parse(song.thumbnail_url),
      ),
    );
  }

  /// Creates the player once and reuses it, so listeners are only attached once.
  AudioPlayer _ensurePlayer() {
    if (audioPlayer != null) return audioPlayer!;

    final player = AudioPlayer();
    audioPlayer = player;

    // Fires whenever the current song changes: next, previous, auto-advance,
    // or the buttons on the notification / lock screen.
    _indexSub = player.currentIndexStream.listen((index) {
      if (index == null || index < 0 || index >= _queue.length) return;
      final song = _queue[index];
      if (state?.id != song.id) {
        _onSongChanged(song);
      }
    });

    _playerStateSub = player.playerStateStream.listen((playerState) {
      // End of the last song: rewind and pause (same behaviour as before).
      if (playerState.processingState == ProcessingState.completed) {
        player.seek(Duration.zero);
        player.pause();
      }
      if (playerState.playing != isPlaying) {
        isPlaying = playerState.playing;
        _notify();
      }
    });

    return player;
  }

  void _onSongChanged(SongModel song) {
    final userId = ref.read(currentUserNotifierProvider)?.id;
    if (userId != null) {
      _homeLocalRepository.uploadLocalsong(song, userId);
    }
    isPlaying = audioPlayer?.playing ?? false;
    state = song;
  }

  // Re-emits the same song so widgets rebuild (e.g. play/pause icon).
  void _notify() {
    state = state?.copyWith(hex_code: state?.hex_code);
  }

  Future<void> next() async {
    final player = audioPlayer;
    if (player == null || !player.hasNext) return;
    await player.seekToNext();
    player.play();
  }

  /// Spotify-style: if the song is more than 3s in, restart it;
  /// otherwise go to the previous song.
  Future<void> previous() async {
    final player = audioPlayer;
    if (player == null) return;
    if (player.position > const Duration(seconds: 3) || !player.hasPrevious) {
      await player.seek(Duration.zero);
    } else {
      await player.seekToPrevious();
    }
    player.play();
  }

  void playPause() {
    final player = audioPlayer;
    if (player == null) return;
    if (player.playing) {
      player.pause();
    } else {
      player.play();
    }
    // isPlaying + rebuild are handled by playerStateStream
  }

  void seek(val) {
    audioPlayer!.seek(
      Duration(
        milliseconds: (val * audioPlayer!.duration!.inMilliseconds).toInt(),
      ),
    );
  }

  void clear() {
    _indexSub?.cancel();
    _playerStateSub?.cancel();
    audioPlayer?.stop();
    audioPlayer?.dispose();
    audioPlayer = null;
    _queue = [];
    isPlaying = false;
    state = null;
  }
}