import 'package:client/core/theme/app_pallete.dart';
import 'package:client/features/home/model/song_model.dart';
import 'package:flutter/material.dart';

/// Same card layout as uploaded "Latest Today" songs.
/// [accentColor] lets Discover/Jamendo rows feel slightly different without
/// changing the overall look.
class SongCard extends StatelessWidget {
  final SongModel song;
  final VoidCallback onTap;
  final Color? accentColor;
  final double size;

  const SongCard({
    super.key,
    required this.song,
    required this.onTap,
    this.accentColor,
    this.size = 180,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.only(left: 16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: size,
              height: size,
              decoration: BoxDecoration(
                color: Pallete.borderColor,
                borderRadius: BorderRadius.circular(7),
                border: accentColor != null
                    ? Border.all(color: accentColor!.withOpacity(0.35), width: 1)
                    : null,
              ),
              clipBehavior: Clip.antiAlias,
              child: Image.network(
                song.thumbnail_url,
                fit: BoxFit.cover,
                // Decode at display size to cut memory / jank on long lists.
                cacheWidth: (size * MediaQuery.devicePixelRatioOf(context))
                    .round(),
                errorBuilder: (_, __, ___) => ColoredBox(
                  color: Pallete.borderColor,
                  child: Icon(
                    Icons.music_note,
                    color: accentColor ?? Pallete.subtitleText,
                    size: 40,
                  ),
                ),
                loadingBuilder: (context, child, progress) {
                  if (progress == null) return child;
                  return ColoredBox(
                    color: Pallete.borderColor,
                    child: Center(
                      child: SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: accentColor ?? Pallete.whiteColor,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 5),
            SizedBox(
              width: size,
              child: Text(
                song.song_name,
                style: const TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 16,
                ),
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
              ),
            ),
            SizedBox(
              width: size,
              child: Text(
                song.artist,
                style: TextStyle(
                  fontWeight: FontWeight.w500,
                  fontSize: 13,
                  color: accentColor?.withOpacity(0.85) ?? Pallete.subtitleText,
                ),
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
