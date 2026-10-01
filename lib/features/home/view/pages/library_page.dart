import 'package:client/core/providers/current_song_notifier.dart';
import 'package:client/core/providers/current_user_notifier.dart';
import 'package:client/core/theme/app_pallete.dart';
import 'package:client/core/widgets/loader.dart';
import 'package:client/features/auth/repositories/auth_local_repository.dart';
import 'package:client/features/auth/view/pages/signup_page.dart';
import 'package:client/features/home/repositories/home_local_repository.dart';
import 'package:client/features/home/model/song_model.dart';
import 'package:client/features/home/viewmodel/home_viewmodel.dart';
import 'package:client/features/home/widgets/song_widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class LibraryPage extends ConsumerWidget {
  const LibraryPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // WRAPPED IN SCAFFOLD TO ADD APPBAR FOR LOGOUT
    return DefaultTabController(
      length: 2,
      child: Scaffold(
      appBar: AppBar(
        title: const Text('Library'),
        bottom: const TabBar(
          indicatorColor: Pallete.gradient2,
          labelColor: Pallete.whiteColor,
          unselectedLabelColor: Pallete.subtitleText,
          tabs: [Tab(text: 'Discover'), Tab(text: 'Uploads')],
        ),
        actions: [
          IconButton(
            onPressed: () async {
              // 1. Delete token from storage
              await ref.read(authLocalRepositoryProvider).removeToken();
              await ref.read(authLocalRepositoryProvider).removeUser();
              
              // 2. Clear old user's recently played songs from Hive using the repo (No await needed)
              ref.read(homeLocalRepositoryProvider).clearBox();
              
              // 3. Stop the music and clear the active song
              ref.read(currentSongNotifierProvider.notifier).clear();
              
              // 4. Safely reset global user state to null
              ref.read(currentUserNotifierProvider.notifier).addUser(null);
              
              // 5. Send back to Auth screen
              if (!context.mounted) return;
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (context) => const SignupPage()),
                (route) => false,
              );
            },
            icon: const Icon(Icons.logout),
          )
        ],
      ),
      body: ref.watch(getFavSongsProvider).when(
            data: (data) {
              final discover = data.where((s) => s.isExternal).toList();
              final uploaded = data.where((s) => !s.isExternal).toList();
              return TabBarView(
                children: [
                  _FavouritesList(
                    songs: discover,
                    emptyText: 'Songs you like in Discover will show up here',
                  ),
                  _FavouritesList(
                    songs: uploaded,
                    emptyText: 'Songs you like from your uploads will show up here',
                  ),
                ],
              );
            },
            error: (error, st) => Center(child: Text(error.toString())),
            loading: () => const Loader(),
          ),
      ),
    );
  }
}

class _FavouritesList extends ConsumerWidget {
  const _FavouritesList({required this.songs, required this.emptyText});

  final List<SongModel> songs;
  final String emptyText;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (songs.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: Text(
            emptyText,
            textAlign: TextAlign.center,
            style: const TextStyle(color: Pallete.subtitleText),
          ),
        ),
      );
    }
    return ListView.builder(
      padding: const EdgeInsets.only(bottom: 110), // room for the mini player
      itemExtent: 72,
      itemCount: songs.length,
      itemBuilder: (context, i) {
        final song = songs[i];
        return SongTile(
          key: ValueKey(song.id),
          song: song,
          onTap: () => ref
              .read(currentSongNotifierProvider.notifier)
              .updateSong(song, queue: songs),
        );
      },
    );
  }
}