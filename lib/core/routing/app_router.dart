import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme/app_colors.dart';
import '../../features/history/presentation/pages/history_page.dart';
import '../../features/home/presentation/pages/home_page.dart';
import '../../features/statistics/presentation/pages/statistics_page.dart';

/// Top-level navigation destinations shown in the bottom navigation bar.
enum AppTab {
  home('/home', Icons.home_outlined, Icons.home, 'Home'),
  history('/history', Icons.history_outlined, Icons.history, 'History'),
  statistics(
      '/statistics', Icons.bar_chart_outlined, Icons.bar_chart, 'Statistics');

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
                builder: (context, state) => const HomePage(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppTab.history.path,
                builder: (context, state) => const HistoryPage(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppTab.statistics.path,
                builder: (context, state) => const StatisticsPage(),
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
      bottomNavigationBar: DecoratedBox(
        position: DecorationPosition.foreground,
        decoration: const BoxDecoration(
          border: Border(top: BorderSide(color: AppColors.chromeBorder, width: 1)),
        ),
        child: NavigationBar(
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
      ),
    );
  }
}
