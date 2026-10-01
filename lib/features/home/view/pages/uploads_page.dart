import 'package:client/core/providers/current_song_notifier.dart';
import 'package:client/core/theme/app_pallete.dart';
import 'package:client/core/utils.dart';
import 'package:client/features/home/model/song_model.dart';
import 'package:client/features/home/view/pages/upload_song_page.dart';
import 'package:client/features/home/viewmodel/home_viewmodel.dart';
import 'package:client/features/home/widgets/song_widgets.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// "My Uploads" tab: only songs the user uploaded. The upload page is
/// reachable only from here.
class UploadsPage extends ConsumerWidget {
  const UploadsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final hex = ref.watch(currentSongNotifierProvider.select((s) => s?.hex_code));
    ref.watch(currentSongNotifierProvider.select((s) => s?.id)); // refresh "recent"

    final uploads = ref.watch(getAllSongsProvider);
    final recent = ref
        .read(homeViewmodelProvider.notifier)
        .getRecentlyPlayedSong()
        .where((s) => !s.isExternal)
        .take(10)
        .toList();

    void play(SongModel song, List<SongModel> queue) {
      ref
          .read(currentSongNotifierProvider.notifier)
          .updateSong(song, queue: queue);
    }

    return AnimatedContainer(
      duration: const Duration(milliseconds: 500),
      decoration: hex == null
          ? null
          : BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [hexToColor(hex), Pallete.transparentColor],
                stops: const [0.0, 0.3],
              ),
            ),
      child: SafeArea(
        bottom: false,
        child: RefreshIndicator(
          color: Pallete.gradient2,
          backgroundColor: Pallete.cardColor,
          onRefresh: () async {
            ref.invalidate(getAllSongsProvider);
            try {
              await ref.read(getAllSongsProvider.future);
            } catch (_) {}
          },
          child: ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.only(bottom: 110),
            children: [
              const Padding(
                padding: EdgeInsets.fromLTRB(16, 16, 16, 4),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'My Uploads',
                      style: TextStyle(fontSize: 30, fontWeight: FontWeight.w800),
                    ),
                    SizedBox(height: 2),
                    Text(
                      'Songs you uploaded yourself',
                      style: TextStyle(fontSize: 13, color: Pallete.subtitleText),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                child: FilledButton.icon(
                  style: FilledButton.styleFrom(
                    backgroundColor: Pallete.gradient2,
                    foregroundColor: Pallete.whiteColor,
                    minimumSize: const Size.fromHeight(48),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => const UploadSongPage(),
                      ),
                    );
                  },
                  icon: const Icon(CupertinoIcons.cloud_upload),
                  label: const Text(
                    'Upload new song',
                    style: TextStyle(fontWeight: FontWeight.w700),
                  ),
                ),
              ),
              if (recent.isNotEmpty)
                SongSection(
                  title: 'Recently played',
                  songs: AsyncData(recent),
                  onSongTap: play,
                ),
              SongSection(
                title: 'Your uploads',
                songs: uploads,
                onSongTap: play,
                onRetry: () => ref.invalidate(getAllSongsProvider),
                emptyText: "You haven't uploaded any songs yet",
              ),
            ],
          ),
        ),
      ),
    );
  }
}