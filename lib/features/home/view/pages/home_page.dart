import 'package:client/core/theme/app_pallete.dart';
import 'package:client/features/home/view/pages/discover_page.dart';
import 'package:client/features/home/view/pages/library_page.dart';
import 'package:client/features/home/view/pages/search_page.dart';
import 'package:client/features/home/view/pages/uploads_page.dart';
import 'package:client/features/home/widgets/music_slab.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class HomePage extends ConsumerStatefulWidget {
  const HomePage({super.key, this.initialIndex = 0});

  /// 0 Discover, 1 Search, 2 My Uploads, 3 Library
  final int initialIndex;

  @override
  ConsumerState<HomePage> createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<HomePage> {
  late int selectedIndex = widget.initialIndex;

  final pages = const [
    DiscoverPage(),
    SearchPage(),
    UploadsPage(),
    LibraryPage(),
  ];

  Color _tint(int index) => selectedIndex == index
      ? Pallete.whiteColor
      : Pallete.inactiveBottomBarItemColor;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // IndexedStack keeps every tab alive: instant tab switches, scroll
          // position and search text are kept.
          IndexedStack(index: selectedIndex, children: pages),
          const Positioned(bottom: 0, child: MusicSlab()),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: selectedIndex,
        selectedItemColor: Pallete.whiteColor,
        unselectedItemColor: Pallete.inactiveBottomBarItemColor,
        onTap: (value) => setState(() => selectedIndex = value),
        items:const[
          BottomNavigationBarItem(
            icon: Icon(CupertinoIcons.house),
            activeIcon: Icon(CupertinoIcons.house_fill),
            label: 'Discover',
          ),
          BottomNavigationBarItem(
            icon: Icon(CupertinoIcons.search),
            activeIcon: Icon(CupertinoIcons.search),
            label: 'Search',
          ),
          BottomNavigationBarItem(
            icon: Icon(CupertinoIcons.cloud_upload),
            activeIcon: Icon(CupertinoIcons.cloud_upload_fill),
            label: 'My Uploads',
          ),
          BottomNavigationBarItem(
            icon: Icon(CupertinoIcons.music_albums),
            activeIcon: Icon(CupertinoIcons.music_albums_fill),
            label: 'Library',
          ),
        ],
      ),
    );
  }
}
