import 'package:client/core/providers/current_song_notifier.dart';
import 'package:client/core/theme/app_pallete.dart';
import 'package:client/core/widgets/loader.dart';
import 'package:client/features/home/model/song_model.dart';
import 'package:client/features/home/widgets/song_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Section title + horizontal song rail, matching the uploaded-songs layout.
class SongHorizontalList extends ConsumerWidget {
  final String title;
  final AsyncValue<List<SongModel>> songsAsync;
  final Color? accentColor;
  final String? subtitle;

  const SongHorizontalList({
    super.key,
    required this.title,
    required this.songsAsync,
    this.accentColor,
    this.subtitle,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: 23,
                  fontWeight: FontWeight.w700,
                  color: accentColor ?? Pallete.whiteColor,
                ),
              ),
              if (subtitle != null)
                Text(
                  subtitle!,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: Pallete.subtitleText,
                  ),
                ),
            ],
          ),
        ),
        songsAsync.when(
          data: (songs) {
            if (songs.isEmpty) {
              return const Padding(
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 24),
                child: Text(
                  'No tracks yet',
                  style: TextStyle(color: Pallete.subtitleText),
                ),
              );
            }
            return SizedBox(
              height: 260,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                // Keep a few cards warm off-screen for smoother fling.
                cacheExtent: 400,
                itemCount: songs.length,
                itemBuilder: (context, index) {
                  final song = songs[index];
                  return SongCard(
                    song: song,
                    accentColor: accentColor,
                    onTap: () {
                      ref
                          .read(currentSongNotifierProvider.notifier)
                          .updateSong(song, queue: songs);
                    },
                  );
                },
              ),
            );
          },
          error: (error, _) => Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Text(
              error.toString(),
              style: const TextStyle(color: Pallete.errorColor, fontSize: 13),
            ),
          ),
          loading: () => const SizedBox(height: 260, child: Loader()),
        ),
      ],
    );
  }
}
