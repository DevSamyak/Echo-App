import 'package:cached_network_image/cached_network_image.dart';
import 'package:client/core/providers/current_song_notifier.dart';
import 'package:client/core/theme/app_pallete.dart';
import 'package:client/features/home/model/song_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Cover art. Cached on disk, decoded at the size it is shown (much less
/// memory than decoding the full image), with a placeholder while loading.
class CoverImage extends StatelessWidget {
  const CoverImage({
    super.key,
    required this.url,
    required this.size,
    this.radius = 8,
  });

  final String url;
  final double size;
  final double radius;

  Widget _placeholder() => Container(
        color: Pallete.cardColor,
        alignment: Alignment.center,
        child: Icon(
          Icons.music_note_rounded,
          color: Pallete.subtitleText,
          size: size * 0.35,
        ),
      );

  @override
  Widget build(BuildContext context) {
    final px = (size * MediaQuery.devicePixelRatioOf(context)).round();
    return ClipRRect(
      borderRadius: BorderRadius.circular(radius),
      child: SizedBox(
        width: size,
        height: size,
        child: url.isEmpty
            ? _placeholder()
            : CachedNetworkImage(
                imageUrl: url,
                fit: BoxFit.cover,
                memCacheWidth: px,
                fadeInDuration: const Duration(milliseconds: 150),
                placeholder: (_, __) => _placeholder(),
                errorWidget: (_, __, ___) => _placeholder(),
              ),
      ),
    );
  }
}

class _NowPlayingBadge extends StatelessWidget {
  const _NowPlayingBadge();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: const BoxDecoration(
        color: Colors.black54,
        shape: BoxShape.circle,
      ),
      child: const Icon(Icons.graphic_eq, size: 16, color: Pallete.gradient2),
    );
  }
}

/// Square card used in the horizontal rows.
class SongCard extends ConsumerWidget {
  const SongCard({
    super.key,
    required this.song,
    required this.onTap,
    this.width = 150,
  });

  final SongModel song;
  final VoidCallback onTap;
  final double width;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Only rebuilds when this card starts/stops being the current song.
    final isCurrent = ref.watch(
      currentSongNotifierProvider.select((s) => s?.id == song.id),
    );

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: SizedBox(
        width: width,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                CoverImage(url: song.thumbnail_url, size: width),
                if (isCurrent)
                  const Positioned(
                    right: 8,
                    bottom: 8,
                    child: _NowPlayingBadge(),
                  ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              song.song_name,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: isCurrent ? Pallete.gradient2 : Pallete.whiteColor,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              song.artist,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: Pallete.subtitleText,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Row used in vertical lists (search results, library).
class SongTile extends ConsumerWidget {
  const SongTile({
    super.key,
    required this.song,
    required this.onTap,
    this.trailing,
  });

  final SongModel song;
  final VoidCallback onTap;
  final Widget? trailing;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isCurrent = ref.watch(
      currentSongNotifierProvider.select((s) => s?.id == song.id),
    );

    return ListTile(
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
      leading: CoverImage(url: song.thumbnail_url, size: 52, radius: 6),
      title: Text(
        song.song_name,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w700,
          color: isCurrent ? Pallete.gradient2 : Pallete.whiteColor,
        ),
      ),
      subtitle: Text(
        song.artist,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: const TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w500,
          color: Pallete.subtitleText,
        ),
      ),
      trailing: isCurrent
          ? const Icon(Icons.graphic_eq, color: Pallete.gradient2)
          : trailing,
    );
  }
}

class _SkeletonCard extends StatelessWidget {
  const _SkeletonCard({required this.width});
  final double width;

  Widget _bar(double w, double h) => Container(
        width: w,
        height: h,
        decoration: BoxDecoration(
          color: Pallete.cardColor,
          borderRadius: BorderRadius.circular(6),
        ),
      );

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _bar(width, width),
        const SizedBox(height: 10),
        _bar(width * 0.8, 12),
        const SizedBox(height: 6),
        _bar(width * 0.5, 10),
      ],
    );
  }
}

/// A titled horizontal row of [SongCard]s that handles loading / error /
/// empty states, so every page gets the same look.
class SongSection extends StatelessWidget {
  const SongSection({
    super.key,
    required this.title,
    required this.songs,
    required this.onSongTap,
    this.onRetry,
    this.emptyText = 'Nothing here yet',
    this.cardWidth = 150,
  });

  final String title;
  final AsyncValue<List<SongModel>> songs;
  final void Function(SongModel song, List<SongModel> queue) onSongTap;
  final VoidCallback? onRetry;
  final String emptyText;
  final double cardWidth;

  double get _height => cardWidth + 64;

  Widget _message(String text, {bool retry = false}) {
    return SizedBox(
      height: _height,
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: Text(
                text,
                textAlign: TextAlign.center,
                style: const TextStyle(color: Pallete.subtitleText),
              ),
            ),
            if (retry && onRetry != null)
              TextButton(onPressed: onRetry, child: const Text('Retry')),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 20, 16, 12),
          child: Text(
            title,
            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w700),
          ),
        ),
        songs.when(
          loading: () => SizedBox(
            height: _height,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              physics: const NeverScrollableScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemExtent: cardWidth + 12,
              itemCount: 4,
              itemBuilder: (_, __) => Padding(
                padding: const EdgeInsets.only(right: 12),
                child: _SkeletonCard(width: cardWidth),
              ),
            ),
          ),
          error: (e, _) {
            debugPrint('SongSection "$title" error: $e');
            return _message(
              "Couldn't load songs. Check your connection and try again.",
              retry: true,
            );
          },
          data: (list) {
            if (list.isEmpty) return _message(emptyText);
            return SizedBox(
              height: _height,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemExtent: cardWidth + 12, // fixed size = cheaper layout
                itemCount: list.length,
                itemBuilder: (context, i) {
                  final song = list[i];
                  return Padding(
                    padding: const EdgeInsets.only(right: 12),
                    child: SongCard(
                      key: ValueKey(song.id),
                      song: song,
                      width: cardWidth,
                      onTap: () => onSongTap(song, list),
                    ),
                  );
                },
              ),
            );
          },
        ),
      ],
    );
  }
}