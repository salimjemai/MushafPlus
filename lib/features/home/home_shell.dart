import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../data/downloads.dart';
import '../../data/offline_sync.dart';
import '../../data/reciters.dart';
import '../../data/reminders.dart';
import '../../data/watch_sync.dart';
import '../../state/masjid_providers.dart';
import '../../state/providers.dart';

import '../../core/l10n.dart';
import '../../widgets/mini_player.dart';

/// Adaptive navigation: bottom bar on phones, rail on tablets/desktop/web.
class HomeShell extends ConsumerStatefulWidget {
  const HomeShell({super.key, required this.child});

  final Widget child;

  static const _paths = ['/', '/hadith', '/prayer', '/bookmarks', '/settings'];

  @override
  ConsumerState<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends ConsumerState<HomeShell> with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    // The Apple Watch app gets a fresh week of prayer times and verses
    // whenever the place changes or the app comes back to the foreground.
    ref.listenManual(activePlaceProvider, (_, __) => scheduleWatchSync(ref));
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (!mounted) return;
      scheduleWatchSync(ref);
      await bootstrapReminders(context, ref);
      if (mounted) _startOfflineSync();
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) scheduleWatchSync(ref);
  }

  /// Installed apps download everything for offline use by themselves. The
  /// first launch says so upfront (and lets the user leave out the 700 MB
  /// recitation); every later launch quietly resumes whatever is missing.
  Future<void> _startOfflineSync() async {
    if (!Downloads.supportsCache) return;
    final settings = ref.read(settingsProvider);
    var includeReciter = settings.offlineReciter;
    if (!settings.offlinePromptShown) {
      await Future<void>.delayed(const Duration(seconds: 1));
      if (!mounted) return;
      final l = context.l10n;
      final reciter = reciterById(settings.reciter);
      final choice = await showDialog<bool>(
        context: context,
        barrierDismissible: false,
        builder: (c) {
          var withReciter = includeReciter;
          return StatefulBuilder(
            builder: (c, setDialog) => AlertDialog(
              icon: const Icon(Icons.offline_pin_outlined),
              title: Text(l.offlineAutoTitle),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(l.offlineAutoBody, style: const TextStyle(height: 1.45)),
                  const SizedBox(height: 12),
                  SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    title: Text(l.includeFullRecitation(reciter.name)),
                    subtitle: Text(l.includeFullRecitationHint),
                    value: withReciter,
                    onChanged: (v) => setDialog(() => withReciter = v),
                  ),
                ],
              ),
              actions: [FilledButton(onPressed: () => Navigator.of(c).pop(withReciter), child: Text(l.continueLabel))],
            ),
          );
        },
      );
      includeReciter = choice ?? includeReciter;
      final n = ref.read(settingsProvider.notifier);
      n.setOfflinePromptShown(true);
      n.setOfflineReciter(includeReciter);
    }
    if (!mounted) return;
    ref.read(offlineSyncProvider.notifier).startAll(includeReciter: includeReciter);
  }

  int _indexFor(String location) {
    for (var i = HomeShell._paths.length - 1; i > 0; i--) {
      if (location.startsWith(HomeShell._paths[i])) return i;
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
                  onDestinationSelected: (i) => context.go(HomeShell._paths[i]),
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
                Expanded(child: Column(children: [const _OfflineProgressStrip(), Expanded(child: widget.child)])),
              ],
            ),
            bottomNavigationBar: const MiniPlayer(),
          );
        }
        return Scaffold(
          body: Column(children: [const _OfflineProgressStrip(), Expanded(child: widget.child)]),
          bottomNavigationBar: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const MiniPlayer(),
              NavigationBar(
                selectedIndex: index,
                onDestinationSelected: (i) => context.go(HomeShell._paths[i]),
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

/// Thin banner shown while the offline download runs in the background.
class _OfflineProgressStrip extends ConsumerWidget {
  const _OfflineProgressStrip();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final s = ref.watch(offlineSyncProvider);
    if (!s.running) return const SizedBox.shrink();
    final scheme = Theme.of(context).colorScheme;
    return Material(
      color: scheme.primaryContainer,
      child: InkWell(
        onTap: () => context.push('/settings/offline'),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 6, 12, 6),
              child: Row(
                children: [
                  SizedBox.square(dimension: 14, child: CircularProgressIndicator(strokeWidth: 2, value: s.progress == 0 ? null : s.progress, color: scheme.onPrimaryContainer)),
                  const SizedBox(width: 10),
                  Expanded(child: Text(context.l10n.offlineSyncing(s.percent), style: TextStyle(fontSize: 12.5, color: scheme.onPrimaryContainer), maxLines: 1, overflow: TextOverflow.ellipsis)),
                  Icon(Icons.chevron_right, size: 18, color: scheme.onPrimaryContainer),
                ],
              ),
            ),
            LinearProgressIndicator(value: s.progress == 0 ? null : s.progress, minHeight: 2),
          ],
        ),
      ),
    );
  }
}
