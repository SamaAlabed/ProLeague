import 'package:flutter/material.dart';
import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:grad_project/core/providers/favoritesProvider.dart';
import 'package:grad_project/screens/tabs/FavTeams.dart';
import 'package:grad_project/screens/tabs/communityPage.dart';
import 'package:grad_project/screens/tabs/newsPage.dart';
import 'package:grad_project/screens/tabs/statsPage.dart';
import 'package:grad_project/screens/tabs/morePage.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Tabs extends ConsumerStatefulWidget {
  const Tabs({super.key});

  @override
  ConsumerState<Tabs> createState() => _TabsState();
}

class _TabsState extends ConsumerState<Tabs> {
  int _selectedPageIndex = 0;

  @override
  void initState() {
    super.initState();
    _loadSavedTabIndex();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(favoriteTeamsProvider.notifier).loadFavorites();
    });
  }

  Future<void> _loadSavedTabIndex() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _selectedPageIndex = prefs.getInt('selectedTabIndex') ?? 0;
    });
  }

  void _selectPage(int index) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('selectedTabIndex', index);
    setState(() {
      _selectedPageIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    Widget activePage = const NewsPage();

    if (_selectedPageIndex == 1) {
      activePage = const FavTeamsScreen();
    } else if (_selectedPageIndex == 2) {
      activePage = const CommunityPage();
    } else if (_selectedPageIndex == 3) {
      activePage = const StatsPage();
    } else if (_selectedPageIndex == 4) {
      activePage = const MorePage();
    }

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.primary,
      body: activePage,
      bottomNavigationBar: CurvedNavigationBar(
        backgroundColor: Theme.of(context).colorScheme.primary,
        color: Theme.of(context).colorScheme.primaryContainer,
        animationDuration: const Duration(milliseconds: 400),
        onTap: _selectPage,
        index: _selectedPageIndex,
        items: [
          const Icon(Icons.newspaper),
          Image.asset('assets/images/logo1.png', width: 30, height: 30),
          const Icon(Icons.people_alt_rounded),
          const Icon(Icons.bar_chart),
          const Icon(Icons.more_vert),
        ],
      ),
    );
  }
}
