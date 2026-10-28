import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'core/l10n.dart';
import 'core/theme.dart';
import 'data/quran_repository.dart';
import 'features/bookmarks/bookmarks_screen.dart';
import 'features/hadith/hadith_book_screen.dart';
import 'features/hadith/hadith_screens.dart';
import 'features/home/home_shell.dart';
import 'features/home/surah_list_screen.dart';
import 'features/memorize/memorize_screen.dart';
import 'features/plan/plan_screen.dart';
import 'features/prayer/adhan_screen.dart';
import 'features/prayer/masjid_edit_screen.dart';
import 'features/prayer/monthly_timetable_screen.dart';
import 'features/prayer/prayer_screen.dart';
import 'features/prayer/qibla_screen.dart';
import 'features/adhkar/adhkar_screens.dart';
import 'features/mushaf/mushaf_book_screen.dart';
import 'features/prayer/personal_location_screen.dart';
import 'features/prayer/publish_screen.dart';
import 'features/prayer/reminders_screen.dart';
import 'features/settings/profile_screen.dart';
import 'features/reader/tajweed_guide.dart';
import 'features/prayer/widget_screen.dart';
import 'data/masjid_share.dart';
import 'features/reader/reader_screen.dart';
import 'features/recite/recite_screen.dart';
import 'features/search/search_screen.dart';
import 'features/settings/offline_packs_screen.dart';
import 'features/settings/settings_screen.dart';
import 'features/settings/translation_picker_screen.dart';
import 'state/providers.dart';
import 'widgets/surah_number_badge.dart';

/// The route the platform asked for at startup (a web deep link such as
/// `#/hadith/muslim`). Captured in main() before the splash screen can reset
/// the browser URL to "/".
String initialRouteAtStartup = '/';

GoRouter? _routerInstance;

/// The app's router, for navigation from outside the widget tree
/// (notification taps).
GoRouter get appRouter => _router;
GoRouter get _router => _routerInstance ??= GoRouter(
      initialLocation: initialRouteAtStartup.startsWith('/') ? initialRouteAtStartup : '/',
      routes: _routes,
    );

final _routes = <RouteBase>[
    ShellRoute(
      builder: (context, state, child) => HomeShell(child: child),
      routes: [
        GoRoute(path: '/', builder: (c, s) => const SurahListScreen()),
        GoRoute(path: '/search', builder: (c, s) => SearchScreen(initialQuery: s.uri.queryParameters['q'])),
        GoRoute(
          path: '/hadith',
          builder: (c, s) => const HadithBooksScreen(),
          routes: [
            GoRoute(
              path: ':book',
              builder: (c, s) => HadithBookReaderScreen(
                bookId: s.pathParameters['book']!,
                chapter: int.tryParse(s.uri.queryParameters['chapter'] ?? ''),
                page: int.tryParse(s.uri.queryParameters['page'] ?? ''),
              ),
              routes: [
                GoRoute(
                  path: 'contents',
                  builder: (c, s) => HadithBookScreen(bookId: s.pathParameters['book']!),
                ),
                GoRoute(
                  path: ':section',
                  builder: (c, s) => HadithSectionScreen(
                    bookId: s.pathParameters['book']!,
                    section: int.tryParse(s.pathParameters['section'] ?? '') ?? 1,
                  ),
                ),
              ],
            ),
          ],
        ),
        GoRoute(
          path: '/adhkar',
          builder: (c, s) => const AdhkarScreen(),
          routes: [
            GoRoute(path: ':id', builder: (c, s) => AdhkarChapterScreen(chapterId: int.tryParse(s.pathParameters['id'] ?? '') ?? 27)),
          ],
        ),
        GoRoute(path: '/bookmarks', builder: (c, s) => const BookmarksScreen()),
        GoRoute(
          path: '/prayer',
          builder: (c, s) => const PrayerScreen(),
          routes: [
            GoRoute(
              path: 'edit',
              builder: (c, s) => MasjidEditScreen(masjidId: s.uri.queryParameters['id']),
            ),
            GoRoute(path: 'month', builder: (c, s) => const MonthlyTimetableScreen()),
            GoRoute(path: 'me', builder: (c, s) => const PersonalLocationScreen()),
            GoRoute(path: 'reminders', builder: (c, s) => const RemindersScreen()),
            GoRoute(path: 'qibla', builder: (c, s) => const QiblaScreen()),
            GoRoute(path: 'publish', builder: (c, s) => PublishScreen(masjidId: s.uri.queryParameters['id'])),
            GoRoute(
              path: 'adhan',
              builder: (c, s) => AdhanScreen(
                autoplay: s.uri.queryParameters['play'] == '1',
                fajr: s.uri.queryParameters['fajr'] == '1',
              ),
            ),
          ],
        ),
        GoRoute(
          path: '/settings',
          builder: (c, s) => const SettingsScreen(),
          routes: [
            GoRoute(path: 'profile', builder: (c, s) => const ProfileScreen()),
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
    GoRoute(path: '/plan', builder: (c, s) => const PlanScreen()),
    GoRoute(path: '/tajweed', builder: (c, s) => TajweedGuideScreen(highlight: s.uri.queryParameters['rule'])),
    GoRoute(
      path: '/recite/:n',
      builder: (c, s) {
        final n = (int.tryParse(s.pathParameters['n'] ?? '') ?? 1).clamp(1, 114);
        return ReciteScreen(
          surah: n,
          from: int.tryParse(s.uri.queryParameters['from'] ?? ''),
          to: int.tryParse(s.uri.queryParameters['to'] ?? ''),
          autoStart: s.uri.queryParameters['auto'] == '1',
        );
      },
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
      path: '/mushaf',
      builder: (c, s) {
        final n = int.tryParse(s.uri.queryParameters['page'] ?? '') ?? 1;
        return MushafBookScreen(initialPage: n.clamp(1, QuranRepository.totalPages));
      },
    ),
    GoRoute(
      path: '/w',
      builder: (c, s) {
        final q = s.uri.queryParameters;
        return PrayerWidgetScreen(
          code: q['c'] ?? '',
          view: WidgetView.values.where((v) => v.name == q['v']).firstOrNull ?? WidgetView.combined,
          theme: q['theme'],
          scale: (int.tryParse(q['scale'] ?? '') ?? 100) / 100,
          lang: q['lang'],
        );
      },
    ),
    GoRoute(
      path: '/tv',
      builder: (c, s) => PrayerWidgetScreen(code: s.uri.queryParameters['c'] ?? '', tv: true, theme: s.uri.queryParameters['theme'], lang: s.uri.queryParameters['lang']),
    ),
    GoRoute(
      path: '/page/:n',
      redirect: (c, s) => '/mushaf?page=${s.pathParameters['n']}',
    ),
    GoRoute(
      path: '/surah/:n',
      builder: (c, s) {
        final n = int.tryParse(s.pathParameters['n'] ?? '') ?? 1;
        final ayah = int.tryParse(s.uri.queryParameters['ayah'] ?? '');
        return ReaderScreen(surahNumber: n.clamp(1, 114), initialAyah: ayah);
      },
    ),
  ];

class MushafPlusApp extends ConsumerWidget {
  const MushafPlusApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider);
    final repo = ref.watch(repositoryProvider);

    final locale = settings.locale == null ? null : Locale(settings.locale!);

    return repo.when(
      data: (_) => MaterialApp.router(
        onGenerateTitle: (context) => context.l10n.appTitle,
        debugShowCheckedModeBanner: false,
        theme: AppTheme.light(),
        darkTheme: AppTheme.dark(),
        themeMode: settings.themeMode,
        locale: locale,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        routerConfig: _router,
      ),
      loading: () => MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: AppTheme.light(),
        darkTheme: AppTheme.dark(),
        themeMode: settings.themeMode,
        locale: locale,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: const _Splash(),
      ),
      error: (e, _) => MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: AppTheme.light(),
        darkTheme: AppTheme.dark(),
        locale: locale,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Builder(
          builder: (context) => Scaffold(
            body: Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.error_outline, size: 48),
                    const SizedBox(height: 12),
                    Text('${context.l10n.couldNotLoadQuran}\n$e', textAlign: TextAlign.center),
                    const SizedBox(height: 16),
                    FilledButton(
                      onPressed: () => ref.invalidate(repositoryProvider),
                      child: Text(context.l10n.retry),
                    ),
                  ],
                ),
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
                    'Mushaf+',
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
