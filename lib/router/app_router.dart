import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../screens/home_screen.dart';
import '../screens/add_screen.dart';
import '../screens/history_screen.dart';
import '../screens/stats_screen.dart';
import '../screens/settings_screen.dart';

class AppRouter {
  static final router = GoRouter(
    // Initial route when the app launches
    initialLocation: '/',

    routes: [
      // ShellRoute wraps the 4 main tabs inside a persistent
      // bottom navigation bar — like a layout in Nuxt.js
      ShellRoute(
        builder: (context, state, child) {
          return MainShell(child: child);
          // ↑ "child" is the current active screen
          //   MainShell draws the bottom nav bar around it
        },
        routes: [
          GoRoute(
            path: '/',
            builder: (context, state) => const HomeScreen(),
          ),
          GoRoute(
            path: '/history',
            builder: (context, state) => const HistoryScreen(),
          ),
          GoRoute(
            path: '/stats',
            builder: (context, state) => const StatsScreen(),
          ),
          GoRoute(
            path: '/settings',
            builder: (context, state) => const SettingsScreen(),
          ),
        ],
      ),

      // AddScreen is outside the ShellRoute — it opens as a
      // full screen modal, without the bottom navigation bar
      GoRoute(
        path: '/add',
        builder: (context, state) => const AddScreen(),
      ),
    ],
  );
}

// ─── MAIN SHELL ──────────────────────────────────────────────
// The persistent layout that wraps the 4 main tabs

class MainShell extends StatelessWidget {
  final Widget child;
  const MainShell({super.key, required this.child});

  // Returns the current tab index based on the active route
  int _currentIndex(BuildContext context) {
    final location = GoRouterState.of(context).uri.toString();
    if (location.startsWith('/history')) return 1;
    if (location.startsWith('/stats')) return 2;
    if (location.startsWith('/settings')) return 3;
    return 0; // default: home
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // "child" is the active screen rendered here
      body: child,

      // Floating action button — opens AddScreen as modal
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.push('/add'),
        // ↑ context.push keeps the bottom nav visible
        //   when coming back from AddScreen
        backgroundColor: Theme.of(context).colorScheme.primary,
        child: const Icon(Icons.add, color: Colors.white),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      // ↑ Centers the FAB in the bottom nav bar

      bottomNavigationBar: BottomAppBar(
        shape: const CircularNotchedRectangle(),
        // ↑ Creates the notch for the centered FAB
        notchMargin: 8,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            // Left side of the FAB
            _NavItem(
              icon: Icons.home_outlined,
              activeIcon: Icons.home,
              label: 'Home',
              index: 0,
              currentIndex: _currentIndex(context),
              onTap: () => context.go('/'),
            ),
            _NavItem(
              icon: Icons.history_outlined,
              activeIcon: Icons.history,
              label: 'History',
              index: 1,
              currentIndex: _currentIndex(context),
              onTap: () => context.go('/history'),
            ),

            // Empty space for the FAB notch
            const SizedBox(width: 48),

            // Right side of the FAB
            _NavItem(
              icon: Icons.bar_chart_outlined,
              activeIcon: Icons.bar_chart,
              label: 'Stats',
              index: 2,
              currentIndex: _currentIndex(context),
              onTap: () => context.go('/stats'),
            ),
            _NavItem(
              icon: Icons.settings_outlined,
              activeIcon: Icons.settings,
              label: 'Settings',
              index: 3,
              currentIndex: _currentIndex(context),
              onTap: () => context.go('/settings'),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── NAV ITEM ────────────────────────────────────────────────
// Reusable bottom nav tab item

class _NavItem extends StatelessWidget {
  final IconData icon;
  final IconData activeIcon;
  final String label;
  final int index;
  final int currentIndex;
  final VoidCallback onTap;

  const _NavItem({
    required this.icon,
    required this.activeIcon,
    required this.label,
    required this.index,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isActive = index == currentIndex;
    final color = isActive
        ? Theme.of(context).colorScheme.primary
        : Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.5);

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: SizedBox(
        width: 64,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              isActive ? activeIcon : icon,
              color: color,
              size: 22,
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                color: color,
                fontWeight: isActive ? FontWeight.w500 : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
