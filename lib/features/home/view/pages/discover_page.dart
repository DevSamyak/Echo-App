import 'package:client/core/providers/current_song_notifier.dart';
import 'package:client/core/theme/app_pallete.dart';
import 'package:client/core/utils.dart';
import 'package:client/features/home/model/song_model.dart';
import 'package:client/features/home/viewmodel/home_viewmodel.dart';
import 'package:client/features/home/viewmodel/saavn_viewmodel.dart';
import 'package:client/features/home/widgets/song_widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

typedef _Row = (String, String);

const _categories = <(String, List<_Row>)>[
  ('Hindi', [('trending', 'Trending in Hindi'), ('new', 'New releases')]),
  ('Romantic', [('romantic', 'Romantic hits')]),
  ('Punjabi', [('punjabi', 'Punjabi hits')]),
  ('Retro', [('retro', 'Old is gold')]),
  ('Party', [('party', 'Party anthems')]),
  ('Tamil', [('tamil', 'Tamil hits')]),
  ('Telugu', [('telugu', 'Telugu hits')]),
  ('Arijit Singh', [('arijit', 'Arijit Singh')]),
];

class DiscoverPage extends ConsumerStatefulWidget {
  const DiscoverPage({super.key});

  @override
  ConsumerState<DiscoverPage> createState() => _DiscoverPageState();
}

class _DiscoverPageState extends ConsumerState<DiscoverPage> {
  int _selected = 0;
  
  // Track the current page for each section to fetch fresh data on refresh
  final Map<String, int> _sectionPages = {};

  List<_Row> get _rows => _categories[_selected].$2;

  void _play(SongModel song, List<SongModel> queue) {
    ref.read(currentSongNotifierProvider.notifier).updateSong(song, queue: queue);
  }

  Future<void> _refresh() async {
    for (final row in _rows) {
      // Increment the page, loop back to 1 after 5 pages so you don't run out of JioSaavn data
      final currentPage = _sectionPages[row.$1] ?? 1;
      _sectionPages[row.$1] = currentPage >= 5 ? 1 : currentPage + 1;
      
      ref.invalidate(saavnFeedProvider(row.$1, page: _sectionPages[row.$1]!));
    }
    try {
      await ref.read(saavnFeedProvider(_rows.first.$1, page: _sectionPages[_rows.first.$1] ?? 1).future);
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    final hex = ref.watch(currentSongNotifierProvider.select((s) => s?.hex_code));
    ref.watch(currentSongNotifierProvider.select((s) => s?.id));

    final recent = ref
        .read(homeViewmodelProvider.notifier)
        .getRecentlyPlayedSong()
        .where((s) => s.isSaavn)
        .take(10)
        .toList();

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
          onRefresh: _refresh,
          child: ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.only(bottom: 110),
            children: [
              const Padding(
                padding: EdgeInsets.fromLTRB(16, 16, 16, 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Discover',
                      style: TextStyle(fontSize: 30, fontWeight: FontWeight.w800),
                    ),
                    SizedBox(height: 2),
                    Text(
                      'Bollywood, Punjabi, South Indian and more',
                      style: TextStyle(fontSize: 13, color: Pallete.subtitleText),
                    ),
                  ],
                ),
              ),
              SizedBox(
                height: 44,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: _categories.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 8),
                  itemBuilder: (context, i) {
                    final selected = i == _selected;
                    return ChoiceChip(
                      label: Text(_categories[i].$1),
                      selected: selected,
                      showCheckmark: false,
                      selectedColor: Pallete.gradient2,
                      backgroundColor: Pallete.cardColor,
                      side: BorderSide(
                        color: selected ? Pallete.gradient2 : Pallete.borderColor,
                      ),
                      labelStyle: TextStyle(
                        color: Pallete.whiteColor,
                        fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                      ),
                      onSelected: (_) => setState(() => _selected = i),
                    );
                  },
                ),
              ),
              if (recent.isNotEmpty && _selected == 0)
                SongSection(
                  title: 'Recently played',
                  songs: AsyncData(recent),
                  onSongTap: _play,
                ),
              for (final row in _rows)
                Builder(
                  builder: (context) {
                    final currentPage = _sectionPages[row.$1] ?? 1;
                    return SongSection(
                      // ValueKey tied to currentPage ensures UI rebuilds when page changes
                      key: ValueKey('${row.$1}_$currentPage'),
                      title: row.$2,
                      songs: ref.watch(saavnFeedProvider(row.$1, page: currentPage)),
                      onSongTap: _play,
                      onRetry: () => ref.invalidate(saavnFeedProvider(row.$1, page: currentPage)),
                      emptyText: 'No songs found right now',
                    );
                  }
                ),
            ],
          ),
        ),
      ),
    );
  }
}