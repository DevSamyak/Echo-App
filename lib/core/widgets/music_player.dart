import 'package:cached_network_image/cached_network_image.dart';
import 'package:client/core/providers/current_song_notifier.dart';
import 'package:client/core/providers/current_user_notifier.dart';
import 'package:client/core/theme/app_pallete.dart';
import 'package:client/core/utils.dart';
import 'package:client/features/home/model/song_model.dart';
import 'package:client/features/home/viewmodel/home_viewmodel.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// JioSaavn thumbnails usually end in e.g. "150x150.jpg". Ask for a larger
/// version so the full-screen cover stays sharp on high-density phones.
/// URLs without that pattern (Cloudinary uploads etc.) are left untouched.
String _hiResCover(String url) {
  return url.replaceAllMapped(
    RegExp(r'\d{2,3}x\d{2,3}(\.(?:jpg|jpeg|png|webp))', caseSensitive: false),
    (m) => '500x500${m.group(1)}',
  );
}

class MusicPlayer extends ConsumerWidget {
  const MusicPlayer({super.key});

  static const double _smallIcon = 26;
  static const double _skipIcon = 32;

  Widget _coverPlaceholder() => Container(
        color: Pallete.cardColor,
        child: const Center(
          child: Icon(
            CupertinoIcons.music_note,
            size: 64,
            color: Pallete.subtitleText,
          ),
        ),
      );

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentSong = ref.watch(currentSongNotifierProvider);
    final songNotifier = ref.read(currentSongNotifierProvider.notifier);
    final userFavourites = ref.watch(
      currentUserNotifierProvider.select((data) => data!.favourites),
    );

    // Decode the cover at screen resolution: sharp, but not wasteful.
    final dpr = MediaQuery.devicePixelRatioOf(context);
    final screenWidth = MediaQuery.sizeOf(context).width;
    final coverPx = (screenWidth * dpr).round();

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [hexToColor(currentSong!.hex_code), const Color(0xff121212)],
        ),
      ),
      child: Scaffold(
        backgroundColor: Pallete.transparentColor,
        appBar: AppBar(
          backgroundColor: Pallete.transparentColor,
          leading: Transform.translate(
            offset: const Offset(-15, 0),
            child: InkWell(
              highlightColor: Pallete.transparentColor,
              focusColor: Pallete.transparentColor,
              splashColor: Pallete.transparentColor,
              onTap: () => Navigator.pop(context),
              child: const Padding(
                padding: EdgeInsets.all(10.0),
                child: Icon(
                  CupertinoIcons.chevron_down,
                  color: Pallete.whiteColor,
                  size: 26,
                ),
              ),
            ),
          ),
        ),
        body: Column(
          children: [
            Expanded(
              flex: 5,
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 30.0),
                child: Hero(
                  tag: 'music-image',
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: currentSong.thumbnail_url.isEmpty
                        ? _coverPlaceholder()
                        : CachedNetworkImage(
                            imageUrl: _hiResCover(currentSong.thumbnail_url),
                            width: double.infinity,
                            fit: BoxFit.cover,
                            filterQuality: FilterQuality.high,
                            memCacheWidth: coverPx,
                            fadeInDuration: const Duration(milliseconds: 150),
                            // Show the already-cached small thumbnail while the
                            // hi-res one loads, so there is no empty flash.
                            placeholder: (_, __) => CachedNetworkImage(
                              imageUrl: currentSong.thumbnail_url,
                              width: double.infinity,
                              fit: BoxFit.cover,
                              placeholder: (_, __) =>
                                  Container(color: Pallete.cardColor),
                              errorWidget: (_, __, ___) =>
                                  Container(color: Pallete.cardColor),
                            ),
                            errorWidget: (_, __, ___) => _coverPlaceholder(),
                          ),
                  ),
                ),
              ),
            ),
            Expanded(
              flex: 4,
              child: Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              currentSong.song_name,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                color: Pallete.whiteColor,
                                fontSize: 24,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            Text(
                              currentSong.artist,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                color: Pallete.subtitleText,
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      if (!currentSong.isExternal)
                        IconButton(
                          onPressed: () async {
                            await ref
                                .read(homeViewmodelProvider.notifier)
                                .favSong(SongId: currentSong.id);
                          },
                          icon: Icon(
                            userFavourites
                                    .where(
                                      (fav) => fav.song_id == currentSong.id,
                                    )
                                    .toList()
                                    .isNotEmpty
                                ? CupertinoIcons.heart_fill
                                : CupertinoIcons.heart,
                            color: Pallete.whiteColor,
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 15),
                  // StreamBuilder only rebuilds this Column on every position
                  // tick, instead of the whole widget like setState would.
                  StreamBuilder(
                    stream: songNotifier.audioPlayer!.positionStream,
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const SizedBox();
                      }
                      final position = snapshot.data;
                      final duration = songNotifier.audioPlayer!.duration;
                      double sliderValue = 0.0;

                      // Guard against null / zero duration (NaN or Infinity
                      // would crash the Slider while a stream is still loading).
                      if (position != null &&
                          duration != null &&
                          duration.inMilliseconds > 0) {
                        sliderValue =
                            (position.inMilliseconds / duration.inMilliseconds)
                                .clamp(0.0, 1.0);
                      }
                      return Column(
                        children: [
                          SliderTheme(
                            data: SliderTheme.of(context).copyWith(
                              activeTrackColor: Pallete.whiteColor,
                              inactiveTrackColor:
                                  Pallete.whiteColor.withOpacity(0.117),
                              thumbColor: Pallete.whiteColor,
                              trackHeight: 4,
                              overlayShape: SliderComponentShape.noOverlay,
                            ),
                            child: Slider(
                              value: sliderValue,
                              min: 0,
                              max: 1,
                              onChanged: (val) {
                                sliderValue = val;
                              },
                              onChangeEnd: (val) {
                                songNotifier.seek(val);
                              },
                            ),
                          ),
                          Row(
                            children: [
                              Text(
                                '${position?.inMinutes ?? 0}:${((position?.inSeconds ?? 0) % 60).toString().padLeft(2, '0')}',
                                style: const TextStyle(
                                  color: Pallete.subtitleText,
                                  fontSize: 13,
                                  fontWeight: FontWeight.w300,
                                ),
                              ),
                              const Expanded(child: SizedBox()),
                              Text(
                                '${duration?.inMinutes ?? 0}:${((duration?.inSeconds ?? 0) % 60).toString().padLeft(2, '0')}',
                                style: const TextStyle(
                                  color: Pallete.subtitleText,
                                  fontSize: 13,
                                  fontWeight: FontWeight.w300,
                                ),
                              ),
                            ],
                          ),
                        ],
                      );
                    },
                  ),

                  const SizedBox(height: 15),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Padding(
                        padding: EdgeInsets.all(10.0),
                        child: Icon(
                          CupertinoIcons.shuffle,
                          color: Pallete.whiteColor,
                          size: _smallIcon,
                        ),
                      ),
                      GestureDetector(
                        behavior: HitTestBehavior.opaque,
                        onTap: songNotifier.previous,
                        child: const Padding(
                          padding: EdgeInsets.all(10.0),
                          child: Icon(
                            CupertinoIcons.backward_fill,
                            color: Pallete.whiteColor,
                            size: _skipIcon,
                          ),
                        ),
                      ),
                      IconButton(
                        onPressed: songNotifier.playPause,
                        icon: Icon(
                          songNotifier.isPlaying
                              ? CupertinoIcons.pause_circle_fill
                              : CupertinoIcons.play_circle_fill,
                          color: Pallete.whiteColor,
                          size: 80,
                        ),
                      ),
                      GestureDetector(
                        behavior: HitTestBehavior.opaque,
                        onTap: songNotifier.next,
                        child: Padding(
                          padding: const EdgeInsets.all(10.0),
                          child: Icon(
                            CupertinoIcons.forward_fill,
                            // dimmed when there is no next song in the queue
                            color: songNotifier.hasNext
                                ? Pallete.whiteColor
                                : Pallete.whiteColor.withOpacity(0.4),
                            size: _skipIcon,
                          ),
                        ),
                      ),
                      const Padding(
                        padding: EdgeInsets.all(10.0),
                        child: Icon(
                          CupertinoIcons.repeat,
                          color: Pallete.whiteColor,
                          size: _smallIcon,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 25),
                  const Row(
                    children: [
                      Padding(
                        padding: EdgeInsets.all(10.0),
                        child: Icon(
                          CupertinoIcons.speaker_2,
                          color: Pallete.whiteColor,
                          size: _smallIcon,
                        ),
                      ),
                      Expanded(child: SizedBox()),
                      Padding(
                        padding: EdgeInsets.all(10.0),
                        child: Icon(
                          CupertinoIcons.music_note_list,
                          color: Pallete.whiteColor,
                          size: _smallIcon,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}