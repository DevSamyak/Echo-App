import 'dart:async';

import 'package:client/core/providers/current_song_notifier.dart';
import 'package:client/core/theme/app_pallete.dart';
import 'package:client/core/widgets/loader.dart';
import 'package:client/features/home/viewmodel/saavn_viewmodel.dart';
import 'package:client/features/home/widgets/song_widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

const _suggestions = [
  'Arijit Singh',
  'Diljit Dosanjh',
  'Kishore Kumar',
  'Anirudh',
  'Atif Aslam',
  'Lofi Hindi',
];

/// Search tab: searches JioSaavn (through our own server).
class SearchPage extends ConsumerStatefulWidget {
  const SearchPage({super.key});

  @override
  ConsumerState<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends ConsumerState<SearchPage> {
  final _controller = TextEditingController();
  Timer? _debounce;
  String _query = '';

  @override
  void dispose() {
    _debounce?.cancel();
    _controller.dispose();
    super.dispose();
  }

  // Wait until the user stops typing so we don't call the API on every key.
  void _onChanged(String value) {
    setState(() {}); // shows/hides the clear button
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      if (mounted) setState(() => _query = value.trim());
    });
  }

  void _submit(String value) {
    _debounce?.cancel();
    setState(() => _query = value.trim());
  }

  void _useSuggestion(String text) {
    _controller.text = text;
    _controller.selection = TextSelection.collapsed(offset: text.length);
    _submit(text);
  }

  void _clear() {
    _debounce?.cancel();
    _controller.clear();
    setState(() => _query = '');
  }

  OutlineInputBorder get _noBorder => OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide.none,
      );

  Widget _centered(Widget child) => Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: child,
        ),
      );

  Widget _body() {
    if (_query.isEmpty) {
      return _centered(
        Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.search, size: 56, color: Pallete.subtitleText),
            const SizedBox(height: 12),
            const Text(
              'Search songs and artists',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              alignment: WrapAlignment.center,
              children: [
                for (final s in _suggestions)
                  ActionChip(
                    label: Text(s),
                    backgroundColor: Pallete.cardColor,
                    side: const BorderSide(color: Pallete.borderColor),
                    onPressed: () => _useSuggestion(s),
                  ),
              ],
            ),
          ],
        ),
      );
    }

    final provider = saavnSearchProvider(_query);
    return ref.watch(provider).when(
          loading: () => const Loader(),
          error: (e, _) {
            debugPrint('Search error: $e');
            return _centered(
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    "Couldn't search right now. Check your connection.",
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Pallete.subtitleText),
                  ),
                  TextButton(
                    onPressed: () => ref.invalidate(provider),
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          },
          data: (songs) {
            if (songs.isEmpty) {
              return _centered(
                Text(
                  'No results for "$_query"',
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Pallete.subtitleText),
                ),
              );
            }
            return ListView.builder(
              keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
              padding: const EdgeInsets.only(bottom: 110),
              itemExtent: 72,
              itemCount: songs.length,
              itemBuilder: (context, i) {
                final song = songs[i];
                return SongTile(
                  key: ValueKey(song.id),
                  song: song,
                  onTap: () {
                    FocusScope.of(context).unfocus();
                    ref
                        .read(currentSongNotifierProvider.notifier)
                        .updateSong(song, queue: songs);
                  },
                );
              },
            );
          },
        );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      bottom: false,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.fromLTRB(16, 16, 16, 12),
            child: Text(
              'Search',
              style: TextStyle(fontSize: 30, fontWeight: FontWeight.w800),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
            child: TextField(
              controller: _controller,
              onChanged: _onChanged,
              onSubmitted: _submit,
              textInputAction: TextInputAction.search,
              decoration: InputDecoration(
                hintText: 'Songs, artists, albums',
                hintStyle: const TextStyle(color: Pallete.subtitleText),
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _controller.text.isEmpty
                    ? null
                    : IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: _clear,
                      ),
                filled: true,
                fillColor: Pallete.cardColor,
                // the app theme sets big padding/borders, so override them here
                contentPadding: const EdgeInsets.symmetric(vertical: 14),
                border: _noBorder,
                enabledBorder: _noBorder,
                focusedBorder: _noBorder,
              ),
            ),
          ),
          Expanded(child: _body()),
        ],
      ),
    );
  }
}