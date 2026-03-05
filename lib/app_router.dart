import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lock_in/features/streak/presentation/screens/home_screen.dart';
import 'package:lock_in/features/calendar/presentation/screens/calendar_screen.dart';
import 'package:lock_in/features/stats/presentation/screens/stats_screen.dart';
import 'package:lock_in/features/achievements/presentation/screens/achievements_screen.dart';
import 'package:lock_in/features/urge/presentation/screens/urge_screen.dart';
import 'package:lock_in/features/journal/presentation/screens/journal_screen.dart';
import 'package:lock_in/features/settings/presentation/screens/settings_screen.dart';
import 'package:lock_in/shared/widgets/app_bottom_nav.dart';

final _rootNavigatorKey = GlobalKey<NavigatorState>();
final _shellNavigatorKey = GlobalKey<NavigatorState>();

final appRouter = GoRouter(
  navigatorKey: _rootNavigatorKey,
  initialLocation: '/',
  routes: [
    ShellRoute(
      navigatorKey: _shellNavigatorKey,
      builder: (context, state, child) {
        return AppShell(child: child);
      },
      routes: [
        GoRoute(
          path: '/',
          pageBuilder: (context, state) {
            return const NoTransitionPage(child: HomeScreen());
          },
        ),
        GoRoute(
          path: '/calendar',
          pageBuilder: (context, state) {
            return const NoTransitionPage(child: CalendarScreen());
          },
        ),
        GoRoute(
          path: '/stats',
          pageBuilder: (context, state) {
            return const NoTransitionPage(child: StatsScreen());
          },
        ),
        GoRoute(
          path: '/achievements',
          pageBuilder: (context, state) {
            return const NoTransitionPage(child: AchievementsScreen());
          },
        ),
      ],
    ),
    // Routes outside the shell (full screen)
    GoRoute(
      path: '/urge',
      parentNavigatorKey: _rootNavigatorKey,
      builder: (context, state) => const UrgeScreen(),
    ),
    GoRoute(
      path: '/journal',
      parentNavigatorKey: _rootNavigatorKey,
      builder: (context, state) => const JournalScreen(),
    ),
    GoRoute(
      path: '/settings',
      parentNavigatorKey: _rootNavigatorKey,
      builder: (context, state) => const SettingsScreen(),
    ),
  ],
);

/// App shell with bottom navigation.
class AppShell extends StatelessWidget {
  final Widget child;

  const AppShell({super.key, required this.child});

  int _getCurrentIndex(BuildContext context) {
    final location = GoRouterState.of(context).uri.path;
    if (location == '/') return 0;
    if (location == '/calendar') return 1;
    if (location == '/stats') return 2;
    if (location == '/achievements') return 3;
    return 0;
  }

  @override
  Widget build(BuildContext context) {
    final currentIndex = _getCurrentIndex(context);

    return Scaffold(
      body: child,
      bottomNavigationBar: AppBottomNav(
        currentIndex: currentIndex,
        onTap: (index) {
          switch (index) {
            case 0:
              context.go('/');
              break;
            case 1:
              context.go('/calendar');
              break;
            case 2:
              context.go('/stats');
              break;
            case 3:
              context.go('/achievements');
              break;
          }
        },
      ),
    );
  }
}
