import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'core/theme.dart';
import 'data/quran_repository.dart';
import 'features/bookmarks/bookmarks_screen.dart';
import 'features/home/home_shell.dart';
import 'features/home/surah_list_screen.dart';
import 'features/memorize/memorize_screen.dart';
import 'features/reader/page_reader_screen.dart';
import 'features/reader/reader_screen.dart';
import 'features/search/search_screen.dart';
import 'features/settings/offline_packs_screen.dart';
import 'features/settings/settings_screen.dart';
import 'features/settings/translation_picker_screen.dart';
import 'state/providers.dart';
import 'widgets/surah_number_badge.dart';

final _router = GoRouter(
  initialLocation: '/',
  routes: [
    ShellRoute(
      builder: (context, state, child) => HomeShell(child: child),
      routes: [
        GoRoute(path: '/', builder: (c, s) => const SurahListScreen()),
        GoRoute(path: '/search', builder: (c, s) => const SearchScreen()),
        GoRoute(path: '/bookmarks', builder: (c, s) => const BookmarksScreen()),
        GoRoute(
          path: '/settings',
          builder: (c, s) => const SettingsScreen(),
          routes: [
            GoRoute(
              path: 'translations',
              builder: (c, s) => const TranslationPickerScreen(),
            ),
            GoRoute(
              path: 'offline',
              builder: (c, s) => const OfflinePacksScreen(),
            ),
          ],
        ),
      ],
    ),
    GoRoute(
      path: '/memorize/:n',
      builder: (c, s) {
        final n = (int.tryParse(s.pathParameters['n'] ?? '') ?? 1).clamp(1, 114);
        return MemorizeScreen(
          surah: n,
          from: int.tryParse(s.uri.queryParameters['from'] ?? ''),
          to: int.tryParse(s.uri.queryParameters['to'] ?? ''),
        );
      },
    ),
    GoRoute(
      path: '/page/:n',
      builder: (c, s) {
        final n = int.tryParse(s.pathParameters['n'] ?? '') ?? 1;
        return PageReaderScreen(page: n.clamp(1, QuranRepository.totalPages));
      },
    ),
    GoRoute(
      path: '/surah/:n',
      builder: (c, s) {
        final n = int.tryParse(s.pathParameters['n'] ?? '') ?? 1;
        final ayah = int.tryParse(s.uri.queryParameters['ayah'] ?? '');
        return ReaderScreen(surahNumber: n.clamp(1, 114), initialAyah: ayah);
      },
    ),
  ],
);

class QuranPlusApp extends ConsumerWidget {
  const QuranPlusApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider);
    final repo = ref.watch(repositoryProvider);

    return repo.when(
      data: (_) => MaterialApp.router(
        title: 'Quran+',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.light(),
        darkTheme: AppTheme.dark(),
        themeMode: settings.themeMode,
        routerConfig: _router,
      ),
      loading: () => MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: AppTheme.light(),
        darkTheme: AppTheme.dark(),
        themeMode: settings.themeMode,
        home: const _Splash(),
      ),
      error: (e, _) => MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: AppTheme.light(),
        darkTheme: AppTheme.dark(),
        home: Scaffold(
          body: Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.error_outline, size: 48),
                  const SizedBox(height: 12),
                  Text('Could not load the Quran data.\n$e', textAlign: TextAlign.center),
                  const SizedBox(height: 16),
                  FilledButton(
                    onPressed: () => ref.invalidate(repositoryProvider),
                    child: const Text('Retry'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _Splash extends StatelessWidget {
  const _Splash();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          PatternPanel(
            borderRadius: BorderRadius.zero,
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'ٱلْقُرْآنُ ٱلْكَرِيمُ',
                    style: ArabicStyles.surahName(context, size: 40, color: AppColors.goldLight),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Quran+',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 2,
                    ),
                  ),
                  const SizedBox(height: 28),
                  const SizedBox(
                    width: 28,
                    height: 28,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.5,
                      color: AppColors.goldLight,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
