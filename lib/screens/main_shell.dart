import 'package:flutter/material.dart';

import '../utils/app_theme.dart';
import '../utils/responsive.dart';
import 'explore_screen.dart';
import 'home_screen.dart';
import 'profile_screen.dart';
import 'watchlist_screen.dart';

/// Kerangka navigasi utama.
/// Compact: NavigationBar di bawah. Medium/Expanded: NavigationRail di kiri.
class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _index = 0;

  static const _destinations = [
    (icon: Icons.home_outlined, selected: Icons.home, label: 'Beranda'),
    (icon: Icons.explore_outlined, selected: Icons.explore, label: 'Eksplor'),
    (
      icon: Icons.bookmark_border,
      selected: Icons.bookmark,
      label: 'Watchlist'
    ),
    (icon: Icons.person_outline, selected: Icons.person, label: 'Profil'),
  ];

  void _onSelect(int index) => setState(() => _index = index);

  @override
  Widget build(BuildContext context) {
    final pages = <Widget>[
      HomeScreen(onSeeAll: () => _onSelect(1)),
      const ExploreScreen(),
      const WatchlistScreen(),
      const ProfileScreen(),
    ];
    final body = IndexedStack(index: _index, children: pages);

    if (Responsive.isCompact(context)) {
      return Scaffold(
        body: body,
        bottomNavigationBar: NavigationBar(
          selectedIndex: _index,
          onDestinationSelected: _onSelect,
          destinations: [
            for (final d in _destinations)
              NavigationDestination(
                icon: Icon(d.icon),
                selectedIcon: Icon(d.selected, color: Colors.white),
                label: d.label,
              ),
          ],
        ),
      );
    }

    final extended = Responsive.of(context) == ScreenSize.expanded;
    return Scaffold(
      body: Row(
        children: [
          NavigationRail(
            selectedIndex: _index,
            onDestinationSelected: _onSelect,
            extended: extended,
            labelType: extended
                ? NavigationRailLabelType.none
                : NavigationRailLabelType.all,
            leading: Padding(
              padding: const EdgeInsets.symmetric(vertical: 16),
              child: Text(
                extended ? 'CINEMAY' : 'C',
                style: const TextStyle(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w900,
                  fontSize: 22,
                  letterSpacing: 2,
                ),
              ),
            ),
            destinations: [
              for (final d in _destinations)
                NavigationRailDestination(
                  icon: Icon(d.icon),
                  selectedIcon: Icon(d.selected, color: Colors.white),
                  label: Text(d.label),
                ),
            ],
          ),
          const VerticalDivider(width: 1),
          Expanded(child: body),
        ],
      ),
    );
  }
}
