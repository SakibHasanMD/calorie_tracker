import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// Top-level navigation destinations shown in the bottom navigation bar.
enum AppTab {
  home('/home', Icons.home_outlined, Icons.home, 'Home'),
  history('/history', Icons.history_outlined, Icons.history, 'History'),
  statistics('/statistics', Icons.bar_chart_outlined, Icons.bar_chart,
      'Statistics');

  const AppTab(
    this.path,
    this.icon,
    this.selectedIcon,
    this.label,
  );

  final String path;
  final IconData icon;
  final IconData selectedIcon;
  final String label;
}

/// Placeholder page shown until a track replaces it with the real screen.
///
/// Track 1 wires these behind the bottom navigation so DI, routing and theming
/// are all proven before any real feature exists.
class PlaceholderPage extends StatelessWidget {
  const PlaceholderPage({super.key, required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(label)),
      body: const Center(child: Text('Coming soon')),
    );
  }
}

/// Builds the application's [GoRouter].
///
/// Uses a [StatefulShellRoute.indexedStack] so the three top-level tabs keep
/// their state while switching via the bottom navigation bar.
GoRouter buildAppRouter() {
  return GoRouter(
    initialLocation: AppTab.home.path,
    routes: [
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) =>
            AppShell(navigationShell: navigationShell),
        branches: [
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppTab.home.path,
                builder: (context, state) =>
                    const PlaceholderPage(label: 'Home'),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppTab.history.path,
                builder: (context, state) =>
                    const PlaceholderPage(label: 'History'),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppTab.statistics.path,
                builder: (context, state) =>
                    const PlaceholderPage(label: 'Statistics'),
              ),
            ],
          ),
        ],
      ),
    ],
  );
}

/// Scaffold that owns the persistent bottom navigation bar and swaps the
/// active branch's child into its body.
class AppShell extends StatelessWidget {
  const AppShell({super.key, required this.navigationShell});

  final StatefulNavigationShell navigationShell;

  void _onDestinationSelected(int index) {
    navigationShell.goBranch(
      index,
      initialLocation: index == navigationShell.currentIndex,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: navigationShell,
      bottomNavigationBar: NavigationBar(
        selectedIndex: navigationShell.currentIndex,
        onDestinationSelected: _onDestinationSelected,
        destinations: AppTab.values
            .map(
              (tab) => NavigationDestination(
                icon: Icon(tab.icon),
                selectedIcon: Icon(tab.selectedIcon),
                label: tab.label,
              ),
            )
            .toList(),
      ),
    );
  }
}