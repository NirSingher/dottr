import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'screens/timeline/timeline_screen.dart';
import 'screens/editor/editor_screen.dart';
import 'screens/viewer/viewer_screen.dart';
import 'screens/search/search_screen.dart';
import 'screens/settings/settings_screen.dart';
import 'screens/settings/schema_manager_screen.dart';
import 'screens/settings/template_manager_screen.dart';
import 'screens/tag_browser/tag_browser_screen.dart';

final _rootNavigatorKey = GlobalKey<NavigatorState>();
final _shellNavigatorKey = GlobalKey<NavigatorState>();

final router = GoRouter(
  navigatorKey: _rootNavigatorKey,
  initialLocation: '/timeline',
  routes: [
    ShellRoute(
      navigatorKey: _shellNavigatorKey,
      builder: (context, state, child) => AppShell(child: child),
      routes: [
        GoRoute(
          path: '/timeline',
          pageBuilder: (context, state) => const NoTransitionPage(
            child: TimelineScreen(),
          ),
        ),
        GoRoute(
          path: '/search',
          pageBuilder: (context, state) => const NoTransitionPage(
            child: SearchScreen(),
          ),
        ),
        GoRoute(
          path: '/tags',
          pageBuilder: (context, state) => const NoTransitionPage(
            child: TagBrowserScreen(),
          ),
        ),
        GoRoute(
          path: '/settings',
          pageBuilder: (context, state) => const NoTransitionPage(
            child: SettingsScreen(),
          ),
        ),
      ],
    ),
    GoRoute(
      path: '/editor',
      parentNavigatorKey: _rootNavigatorKey,
      builder: (context, state) {
        final filePath = state.uri.queryParameters['path'];
        final templateId = state.uri.queryParameters['template'];
        return EditorScreen(filePath: filePath, templateId: templateId);
      },
    ),
    GoRoute(
      path: '/viewer',
      parentNavigatorKey: _rootNavigatorKey,
      builder: (context, state) {
        final filePath = state.uri.queryParameters['path']!;
        return ViewerScreen(filePath: filePath);
      },
    ),
    GoRoute(
      path: '/settings/schemas',
      parentNavigatorKey: _rootNavigatorKey,
      builder: (context, state) => const SchemaManagerScreen(),
    ),
    GoRoute(
      path: '/settings/templates',
      parentNavigatorKey: _rootNavigatorKey,
      builder: (context, state) => const TemplateManagerScreen(),
    ),
  ],
);

class AppShell extends StatelessWidget {
  final Widget child;

  const AppShell({super.key, required this.child});

  static int _indexOf(String location) {
    if (location.startsWith('/timeline')) return 0;
    if (location.startsWith('/search')) return 1;
    if (location.startsWith('/tags')) return 2;
    if (location.startsWith('/settings')) return 3;
    return 0;
  }

  @override
  Widget build(BuildContext context) {
    final location = GoRouterState.of(context).uri.toString();
    final theme = Theme.of(context);

    return Scaffold(
      body: child,
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          border: Border(
            top: BorderSide(
              color: theme.colorScheme.outline,
              width: 2,
            ),
          ),
        ),
        child: BottomNavigationBar(
          currentIndex: _indexOf(location),
          onTap: (index) {
            switch (index) {
              case 0:
                context.go('/timeline');
              case 1:
                context.go('/search');
              case 2:
                context.go('/tags');
              case 3:
                context.go('/settings');
            }
          },
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.view_timeline_outlined),
              activeIcon: Icon(Icons.view_timeline),
              label: 'Timeline',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.search_outlined),
              activeIcon: Icon(Icons.search),
              label: 'Search',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.tag_outlined),
              activeIcon: Icon(Icons.tag),
              label: 'Tags',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.settings_outlined),
              activeIcon: Icon(Icons.settings),
              label: 'Settings',
            ),
          ],
        ),
      ),
    );
  }
}
