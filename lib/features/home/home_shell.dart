import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/l10n.dart';
import '../../widgets/mini_player.dart';

/// Adaptive navigation: bottom bar on phones, rail on tablets/desktop/web.
class HomeShell extends StatelessWidget {
  const HomeShell({super.key, required this.child});

  final Widget child;

  static const _paths = ['/', '/hadith', '/prayer', '/bookmarks', '/settings'];

  int _indexFor(String location) {
    for (var i = _paths.length - 1; i > 0; i--) {
      if (location.startsWith(_paths[i])) return i;
    }
    return 0;
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final location = GoRouterState.of(context).uri.path;
    final index = _indexFor(location);
    final destinations = [
      (icon: Icons.menu_book_outlined, selected: Icons.menu_book, label: l.navRead),
      (icon: Icons.format_quote_outlined, selected: Icons.format_quote, label: l.navHadith),
      (icon: Icons.mosque_outlined, selected: Icons.mosque, label: l.navPrayer),
      (icon: Icons.bookmark_border, selected: Icons.bookmark, label: l.navSaved),
      (icon: Icons.tune_outlined, selected: Icons.tune, label: l.navSettings),
    ];

    return LayoutBuilder(
      builder: (context, constraints) {
        final wide = constraints.maxWidth >= 840;
        if (wide) {
          return Scaffold(
            body: Row(
              children: [
                NavigationRail(
                  extended: constraints.maxWidth >= 1200,
                  selectedIndex: index,
                  groupAlignment: -0.9,
                  onDestinationSelected: (i) => context.go(_paths[i]),
                  leading: const Padding(
                    padding: EdgeInsets.symmetric(vertical: 12),
                    child: _Logo(),
                  ),
                  destinations: [
                    for (final d in destinations)
                      NavigationRailDestination(
                        icon: Icon(d.icon),
                        selectedIcon: Icon(d.selected),
                        label: Text(d.label),
                      ),
                  ],
                ),
                const VerticalDivider(width: 1),
                Expanded(child: child),
              ],
            ),
            bottomNavigationBar: const MiniPlayer(),
          );
        }
        return Scaffold(
          body: child,
          bottomNavigationBar: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const MiniPlayer(),
              NavigationBar(
                selectedIndex: index,
                onDestinationSelected: (i) => context.go(_paths[i]),
                destinations: [
                  for (final d in destinations)
                    NavigationDestination(
                      icon: Icon(d.icon),
                      selectedIcon: Icon(d.selected),
                      label: d.label,
                    ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}

class _Logo extends StatelessWidget {
  const _Logo();

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      width: 44,
      height: 44,
      decoration: BoxDecoration(
        color: scheme.primary,
        borderRadius: BorderRadius.circular(14),
      ),
      alignment: Alignment.center,
      child: const Text(
        'ق',
        style: TextStyle(
          fontFamily: 'Amiri',
          fontSize: 26,
          color: Colors.white,
          fontWeight: FontWeight.w700,
          height: 1.1,
        ),
      ),
    );
  }
}
