import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';

import '../../core/arabic_utils.dart';
import '../../core/l10n.dart';
import '../../core/theme.dart';
import '../../data/fullscreen.dart';
import '../../data/models.dart';
import '../../data/quran_repository.dart';
import '../../state/audio_controller.dart';
import '../../state/providers.dart';
import '../../widgets/book_spread.dart';
import '../../widgets/mini_player.dart';
import '../../widgets/mushaf_cover.dart';
import '../../widgets/surah_number_badge.dart';
import '../../widgets/zoomable.dart';
import '../reader/mushaf_view.dart';
import '../reader/reader_settings_sheet.dart';
import '../reader/tajweed_guide.dart';
import '../reader/verse_panel.dart';

/// The Quran as a printed book: 604 pages in a vertical scroll, a one-page
/// flip, or a two-page spread you flip like a real Mushaf.
class MushafBookScreen extends ConsumerStatefulWidget {
  const MushafBookScreen({super.key, required this.initialPage});
  final int initialPage;

  @override
  ConsumerState<MushafBookScreen> createState() => _MushafBookScreenState();
}

class _MushafBookScreenState extends ConsumerState<MushafBookScreen> {
  late int _page = widget.initialPage.clamp(1, QuranRepository.totalPages);
  PageController? _flip; // one page per view
  final _book = BookSpreadController(); // two-page book
  final _scroll = ItemScrollController();
  final _positions = ItemPositionsListener.create();
  final _scaffold = GlobalKey<ScaffoldState>();
  final _zoom = ZoomController();
  bool _programmatic = false;
  bool _immersive = false;

  /// The book starts closed on its cover when opened at the first page.
  late bool _closed = widget.initialPage <= 1;

  /// Spread k shows pages 2k+1 (right) and 2k+2 (left).
  int _spreadOf(int page) => (page - 1) ~/ 2;

  @override
  void initState() {
    super.initState();
    _flip = PageController(initialPage: _page - 1);
    _positions.itemPositions.addListener(_onScrollPositions);
    WidgetsBinding.instance.addPostFrameCallback((_) => _markRead(_page));
  }

  @override
  void dispose() {
    _positions.itemPositions.removeListener(_onScrollPositions);
    _flip?.dispose();
    super.dispose();
  }

  void _onScrollPositions() {
    final positions = _positions.itemPositions.value;
    if (positions.isEmpty) return;
    final top = positions
        .where((p) => p.itemTrailingEdge > 0.3)
        .fold<int?>(null, (m, p) => m == null || p.index < m ? p.index : m);
    if (top != null && top + 1 != _page) {
      setState(() => _page = top + 1);
      _markRead(_page);
    }
  }

  void _markRead(int page) {
    final first = ref.quran.ayahsOfPage(page).first;
    ref.read(lastReadProvider.notifier).set(first.number);
  }

  void _setImmersive(bool on) {
    setState(() => _immersive = on);
    if (on) {
      Fullscreen.enter();
    } else {
      Fullscreen.exit();
    }
  }

  @override
  void deactivate() {
    if (_immersive) Fullscreen.exit();
    super.deactivate();
  }

  MushafLayout _layout(BoxConstraints c) {
    final s = ref.read(settingsProvider).mushafLayout;
    if (s != MushafLayout.auto) return s;
    return c.maxWidth >= 900 ? MushafLayout.book : MushafLayout.flip;
  }

  Future<void> _goTo(int page, MushafLayout layout,
      {bool animate = true}) async {
    page = page.clamp(1, QuranRepository.totalPages);
    _programmatic = true;
    setState(() => _page = page);
    switch (layout) {
      case MushafLayout.scroll:
        if (_scroll.isAttached) {
          if (animate) {
            await _scroll.scrollTo(
                index: page - 1, duration: const Duration(milliseconds: 400));
          } else {
            _scroll.jumpTo(index: page - 1);
          }
        }
      case MushafLayout.flip:
        if (animate && _flip!.hasClients) {
          await _flip!.animateToPage(page - 1,
              duration: const Duration(milliseconds: 450),
              curve: Curves.easeInOutCubic);
        } else if (_flip!.hasClients) {
          _flip!.jumpToPage(page - 1);
        }
      case MushafLayout.book:
      case MushafLayout.auto:
        _closed = false;
        if (animate) {
          await _book.animateTo(_spreadOf(page));
        } else {
          _book.jumpTo(_spreadOf(page));
        }
    }
    _programmatic = false;
    _markRead(page);
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final repo = ref.quran;
    final settings = ref.watch(settingsProvider);
    final scheme = Theme.of(context).colorScheme;
    final ayahs = repo.ayahsOfPage(_page);
    final surahNames = ayahs
        .map((a) => a.surah)
        .toSet()
        .map((s) => repo.surah(s).englishName)
        .join(' · ');

    return LayoutBuilder(
      builder: (context, constraints) {
        final layout = _layout(constraints);

        // Follow the recitation across pages.
        ref.listen<int?>(audioProvider.select((a) => a.ayah), (prev, next) {
          if (next == null || next == prev) return;
          final p = repo.ayah(next).page;
          if (p != _page) _goTo(p, layout);
        });

        final bookBody = switch (layout) {
          MushafLayout.scroll => _scrollLayout(),
          MushafLayout.flip => Zoomable(controller: _zoom, child: _flipLayout()),
          _ => Zoomable(controller: _zoom, child: _bookLayout(constraints)),
        };
        if (_immersive) {
          return Scaffold(
            body: Stack(
              children: [
                Positioned.fill(child: bookBody),
                PositionedDirectional(
                  top: MediaQuery.paddingOf(context).top + 6,
                  end: 6,
                  child: _ImmersiveExit(onTap: () => _setImmersive(false), label: l.exitFullScreen),
                ),
                PositionedDirectional(
                  bottom: MediaQuery.paddingOf(context).bottom + 6,
                  start: 0,
                  end: 0,
                  child: Center(
                    child: _ImmersivePager(
                      page: _page,
                      onPrev: _page > 1 ? () => _goTo(_page - 1, layout) : null,
                      onNext: _page < QuranRepository.totalPages ? () => _goTo(_page + 1, layout) : null,
                    ),
                  ),
                ),
              ],
            ),
          );
        }
        return Scaffold(
          key: _scaffold,
          drawer: _ChaptersDrawer(onPage: (p) {
            Navigator.of(context).pop();
            _goTo(p, layout);
          }),
          appBar: AppBar(
            leading: IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () =>
                  context.canPop() ? context.pop() : context.go('/'),
            ),
            title: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(surahNames, maxLines: 1, overflow: TextOverflow.ellipsis),
                Text(l.pageJuz(_page, ayahs.first.juz),
                    style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: scheme.onSurfaceVariant)),
              ],
            ),
            actions: [
              IconButton(
                tooltip: l.tableOfContents,
                icon: const Icon(Icons.toc),
                onPressed: () => _scaffold.currentState?.openDrawer(),
              ),
              IconButton(
                tooltip: l.tajweedLegend,
                icon: const Icon(Icons.palette_outlined),
                onPressed: () => showTajweedLegend(context),
              ),
              PlaybackMenu(
                playLabel: l.playThisPage,
                onPlay: () => ref
                    .read(audioProvider.notifier)
                    .playAyah(ayahs.first.number, until: ayahs.last.number),
              ),
              IconButton(
                tooltip: l.fullScreen,
                icon: const Icon(Icons.fullscreen),
                onPressed: () => _setImmersive(true),
              ),
              PopupMenuButton<MushafLayout>(
                tooltip: l.mushafLayout,
                icon: Icon(switch (layout) {
                  MushafLayout.scroll => Icons.swap_vert,
                  MushafLayout.flip => Icons.auto_stories_outlined,
                  _ => Icons.menu_book_outlined,
                }),
                onSelected: (v) {
                  ref.read(settingsProvider.notifier).setMushafLayout(v);
                  WidgetsBinding.instance.addPostFrameCallback((_) => _goTo(
                      _page, v == MushafLayout.auto ? _layout(constraints) : v,
                      animate: false));
                },
                itemBuilder: (_) => [
                  _layoutItem(MushafLayout.auto, Icons.auto_awesome_outlined,
                      l.layoutAutomatic, settings.mushafLayout),
                  _layoutItem(MushafLayout.scroll, Icons.swap_vert,
                      l.layoutScroll, settings.mushafLayout),
                  _layoutItem(MushafLayout.flip, Icons.auto_stories_outlined,
                      l.layoutFlip, settings.mushafLayout),
                  _layoutItem(MushafLayout.book, Icons.menu_book_outlined,
                      l.layoutBook, settings.mushafLayout),
                ],
              ),
              IconButton(
                tooltip: l.readingSettings,
                icon: const Icon(Icons.text_fields),
                onPressed: () => showReaderSettings(context),
              ),
              if (layout != MushafLayout.scroll)
                PopupMenuButton<String>(
                  tooltip: l.zoomIn,
                  icon: const Icon(Icons.zoom_in),
                  onSelected: (v) => handleZoomMenu(v, _zoom),
                  itemBuilder: (_) => zoomMenuItems(context, zoomIn: l.zoomIn, zoomOut: l.zoomOut, fit: l.fitPage),
                ),
            ],
          ),
          body: bookBody,
          bottomNavigationBar: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const ListenBar(),
              _PageBar(
                page: _page,
                onChanged: (p) => _goTo(p, layout),
                onGoTo: () => _goToDialog(layout),
              ),
            ],
          ),
        );
      },
    );
  }

  PopupMenuItem<MushafLayout> _layoutItem(
      MushafLayout v, IconData icon, String label, MushafLayout current) {
    return PopupMenuItem(
      value: v,
      child: ListTile(
        leading: Icon(icon),
        title: Text(label),
        trailing: current == v ? const Icon(Icons.check) : null,
        contentPadding: EdgeInsets.zero,
      ),
    );
  }

  // ---- layouts ---------------------------------------------------------

  Widget _scrollLayout() {
    return ScrollablePositionedList.builder(
      itemScrollController: _scroll,
      itemPositionsListener: _positions,
      initialScrollIndex: _page - 1,
      itemCount: QuranRepository.totalPages,
      padding: const EdgeInsets.symmetric(vertical: 12),
      itemBuilder: (context, i) => Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 640),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: MushafPage(
                page: i + 1,
                onAyahTap: (a) => showVersePanel(context, a),
                onWordTap: (a, w) => showVersePanel(context, a, word: w, tab: VerseTab.word)),
          ),
        ),
      ),
    );
  }

  // The book's geometry is fixed regardless of the interface language: page
  // views and the page bar are laid out left-to-right, with `reverse` giving
  // the Arabic reading order (next page comes from the left).

  Widget _flipLayout() {
    return Directionality(
      textDirection: TextDirection.ltr,
      child: PageView.builder(
        controller: _flip,
        reverse: true, // next page comes from the left, like an Arabic book
        itemCount: QuranRepository.totalPages,
        onPageChanged: (i) {
          if (_programmatic) return;
          setState(() => _page = i + 1);
          _markRead(_page);
        },
        itemBuilder: (context, i) => _Flipping(
          controller: _flip!,
          index: i,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(12, 8, 12, 8),
            child: _FitPage(
                page: i + 1,
                onAyahTap: (a) => showVersePanel(context, a),
                onWordTap: (a, w) => showVersePanel(context, a, word: w, tab: VerseTab.word)),
          ),
        ),
      ),
    );
  }

  Widget _bookLayout(BoxConstraints constraints) {
    final spreads = (QuranRepository.totalPages / 2).ceil();
    final dark = Theme.of(context).brightness == Brightness.dark;
    Widget? pageAt(int page) => page < 1 || page > QuranRepository.totalPages
        ? null
        : MushafPage(
            key: ValueKey('book-$page'),
            page: page,
            onAyahTap: (a) => showVersePanel(context, a),
                onWordTap: (a, w) => showVersePanel(context, a, word: w, tab: VerseTab.word),
            fitToPage: true,
          );
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: dark
              ? const [Color(0xFF0B100E), Color(0xFF161D19)]
              : const [Color(0xFFEDE6D6), Color(0xFFD9CFBC)],
        ),
      ),
      padding: _immersive || constraints.maxHeight < 500
          ? const EdgeInsets.fromLTRB(6, 4, 6, 4)
          : const EdgeInsets.fromLTRB(20, 14, 20, 14),
      child: Directionality(
        textDirection: TextDirection.ltr,
        child: BookSpreadView(
          key: const ValueKey('mushaf-book'),
          controller: _book,
          style: switch (ref.watch(settingsProvider).pageAnimation) {
            PageAnimation.curl => BookTurnStyle.curl,
            PageAnimation.flip => BookTurnStyle.flip,
            PageAnimation.slide => BookTurnStyle.slide,
            PageAnimation.fade => BookTurnStyle.fade,
          },
          spreadCount: spreads,
          initialSpread: _closed ? -1 : _spreadOf(_page),
          cover: const MushafCover(subtitle: 'QURAN+'),
          leftPage: (k) => pageAt(k * 2 + 2),
          rightPage: (k) => pageAt(k * 2 + 1),
          onSpreadChanged: (k) {
            setState(() {
              _closed = k < 0;
              if (k >= 0) _page = k * 2 + 1;
            });
            if (k >= 0) _markRead(_page);
          },
        ),
      ),
    );
  }

  Future<void> _goToDialog(MushafLayout layout) async {
    final repo = ref.quran;
    final controller = TextEditingController(text: '$_page');
    final result = await showDialog<int>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(context.l10n.goTo),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: controller,
              autofocus: true,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(labelText: context.l10n.pageRange),
              onSubmitted: (v) => Navigator.pop(context, int.tryParse(v)),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: [
                for (final j in repo.juzs)
                  ActionChip(
                    label: Text(context.l10n.juzN(j.number)),
                    visualDensity: VisualDensity.compact,
                    onPressed: () =>
                        Navigator.pop(context, repo.ayah(j.startAyah).page),
                  ),
              ],
            ),
          ],
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(context.l10n.cancel)),
          FilledButton(
              onPressed: () =>
                  Navigator.pop(context, int.tryParse(controller.text)),
              child: Text(context.l10n.open)),
        ],
      ),
    );
    controller.dispose();
    if (result != null) _goTo(result, layout);
  }
}

/// QuranFlash-style side drawer: Suras, Juz and Bookmarks, each jumping to
/// the page where the item starts.
class _ChaptersDrawer extends ConsumerWidget {
  const _ChaptersDrawer({required this.onPage});
  final ValueChanged<int> onPage;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = context.l10n;
    final repo = ref.quran;
    final scheme = Theme.of(context).colorScheme;
    final bookmarks = ref.watch(bookmarksProvider);
    return Drawer(
      width: 320,
      child: SafeArea(
        child: DefaultTabController(
          length: 3,
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
                child: Row(children: [
                  Icon(Icons.menu_book, color: scheme.primary),
                  const SizedBox(width: 10),
                  Text(l.tableOfContents, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
                ]),
              ),
              TabBar(tabs: [Tab(text: l.tabSurah), Tab(text: l.tabJuz), Tab(text: l.navSaved)]),
              Expanded(
                child: TabBarView(
                  children: [
                    ListView.builder(
                      itemCount: repo.surahs.length,
                      itemBuilder: (context, i) {
                        final s = repo.surahs[i];
                        return ListTile(
                          dense: true,
                          leading: SurahNumberBadge(number: s.number),
                          title: Text(s.englishName),
                          subtitle: Text('${l.pageN(s.startPage)} · ${s.numberOfAyahs}', style: const TextStyle(fontSize: 11.5)),
                          trailing: Text(s.name, style: ArabicStyles.surahName(context, size: 18)),
                          onTap: () => onPage(s.startPage),
                        );
                      },
                    ),
                    ListView.builder(
                      itemCount: repo.juzs.length,
                      itemBuilder: (context, i) {
                        final j = repo.juzs[i];
                        final a = repo.ayah(j.startAyah);
                        final s = repo.surah(a.surah);
                        return ListTile(
                          dense: true,
                          leading: CircleAvatar(radius: 16, child: Text('${j.number}', style: const TextStyle(fontSize: 13))),
                          title: Text(l.juzN(j.number)),
                          subtitle: Text('${s.englishName} ${a.numberInSurah} · ${l.pageN(a.page)}', style: const TextStyle(fontSize: 11.5)),
                          trailing: Text(s.name, style: ArabicStyles.surahName(context, size: 16)),
                          onTap: () => onPage(a.page),
                        );
                      },
                    ),
                    bookmarks.isEmpty
                        ? Center(child: Padding(padding: const EdgeInsets.all(24), child: Text(l.noBookmarksYet, style: TextStyle(color: scheme.onSurfaceVariant))))
                        : ListView.builder(
                            itemCount: bookmarks.length,
                            itemBuilder: (context, i) {
                              final a = repo.ayah(bookmarks[i].ayahNumber);
                              final s = repo.surah(a.surah);
                              return ListTile(
                                dense: true,
                                leading: Icon(Icons.bookmark, color: scheme.secondary),
                                title: Text('${s.englishName} · ${l.ayahN(a.numberInSurah)}'),
                                subtitle: Text(a.text, maxLines: 1, overflow: TextOverflow.ellipsis, textDirection: TextDirection.rtl,
                                    style: const TextStyle(fontFamily: ArabicStyles.nameFont, fontSize: 14)),
                                trailing: Text(l.pageN(a.page), style: const TextStyle(fontSize: 11.5)),
                                onTap: () => onPage(a.page),
                              );
                            },
                          ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// A page-turn feel: the page rotates slightly around its spine edge while
/// being dragged, with a soft shadow.
class _Flipping extends StatelessWidget {
  const _Flipping(
      {required this.controller, required this.index, required this.child});
  final PageController controller;
  final int index;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (context, _) {
        double delta = 0;
        if (controller.hasClients && controller.position.haveDimensions) {
          delta =
              (controller.page ?? controller.initialPage.toDouble()) - index;
        }
        final t = delta.clamp(-1.0, 1.0);
        final angle = -t * math.pi / 2 * 0.35;
        return Transform(
          alignment: t >= 0 ? Alignment.centerRight : Alignment.centerLeft,
          transform: Matrix4.identity()
            ..setEntry(3, 2, 0.0012)
            ..rotateY(angle),
          child: Opacity(opacity: 1 - t.abs() * 0.25, child: child),
        );
      },
    );
  }
}

/// A page with the proportions of a printed Mushaf (about 2:3), as large as
/// the frame allows; the text block is scaled to fill it, so every page shows
/// in full with no inner scrolling.
class _FitPage extends StatelessWidget {
  const _FitPage({required this.page, required this.onAyahTap, this.onWordTap});
  final int page;
  final ValueChanged<Ayah> onAyahTap;
  final void Function(Ayah, int)? onWordTap;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: AspectRatio(
        aspectRatio: MushafPage.pageAspect,
        child: MushafPage(page: page, onAyahTap: onAyahTap, onWordTap: onWordTap, fitToPage: true),
      ),
    );
  }
}

/// One printed Mushaf page: ornamental frame, running head (surah / juz),
/// the ayahs of the page with surah banners, and the page number.
class MushafPage extends ConsumerWidget {
  const MushafPage(
      {super.key,
      required this.page,
      required this.onAyahTap,
      this.onWordTap,
      this.fitToPage = false});
  final int page;
  final ValueChanged<Ayah> onAyahTap;
  final void Function(Ayah, int)? onWordTap;

  /// When true the page has a bounded height and the text is scaled to fill it.
  final bool fitToPage;

  /// Width : height of a printed page.
  static const pageAspect = 0.68;

  /// Logical width the text is laid out at before scaling (about nine words
  /// per line, like the Madani Mushaf).
  static const layoutWidth = 540.0;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final repo = ref.quran;
    final settings = ref.watch(settingsProvider);
    final ayahs = repo.ayahsOfPage(page);
    final dark = Theme.of(context).brightness == Brightness.dark;
    final paper = dark ? const Color(0xFF1C1A15) : const Color(0xFFFDF6E3);
    final ink = dark ? const Color(0xFFE8E2D0) : const Color(0xFF2B2416);
    final frame = AppColors.gold.withValues(alpha: dark ? 0.55 : 0.8);

    final groups = <List<Ayah>>[];
    for (final a in ayahs) {
      if (groups.isEmpty || groups.last.first.surah != a.surah) {
        groups.add([a]);
      } else {
        groups.last.add(a);
      }
    }
    final headSurah = repo.surah(ayahs.last.surah);
    final textStyle = fitToPage
        ? ArabicStyles.ayah(context, font: settings.arabicFont)
            .copyWith(fontSize: 27, height: 1.95, color: ink)
        : null;

    final body = Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (final g in groups) ...[
          if (g.first.numberInSurah == 1)
            _Banner(surah: repo.surah(g.first.surah), frame: frame, ink: ink),
          _InkTheme(
            ink: ink,
            child: MushafText(
              key: ValueKey('mp$page-${g.first.surah}'),
              ayahs: g,
              onAyahTap: onAyahTap,
              onWordTap: onWordTap,
              style: textStyle,
            ),
          ),
        ],
      ],
    );

    return Container(
      decoration: BoxDecoration(
        color: paper,
        borderRadius: BorderRadius.circular(6),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withValues(alpha: dark ? 0.5 : 0.18),
              blurRadius: 14,
              offset: const Offset(0, 6))
        ],
      ),
      padding: const EdgeInsets.all(10),
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(color: frame, width: 1.6),
          borderRadius: BorderRadius.circular(4),
        ),
        padding: const EdgeInsets.all(4),
        child: Container(
          decoration: BoxDecoration(
              border:
                  Border.all(color: frame.withValues(alpha: 0.5), width: 0.8)),
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 10),
          child: DefaultTextStyle(
            style: TextStyle(color: ink),
            child: Column(
              mainAxisSize: fitToPage ? MainAxisSize.max : MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  children: [
                    Text('الجزء ${toArabicDigits(ayahs.first.juz)}',
                        style: TextStyle(
                            fontFamily: ArabicStyles.nameFont,
                            fontSize: 14,
                            color: ink.withValues(alpha: 0.75))),
                    const Spacer(),
                    Text(headSurah.name,
                        style: TextStyle(
                            fontFamily: ArabicStyles.nameFont,
                            fontSize: 15,
                            color: ink.withValues(alpha: 0.85))),
                  ],
                ),
                Divider(color: frame.withValues(alpha: 0.5), height: 14),
                if (fitToPage)
                  Expanded(
                    child: FittedBox(
                      fit: BoxFit.contain,
                      alignment: Alignment.topCenter,
                      child: SizedBox(width: layoutWidth, child: body),
                    ),
                  )
                else
                  body,
                const SizedBox(height: 8),
                Center(
                  child: Text(toArabicDigits(page),
                      style: TextStyle(
                          fontFamily: ArabicStyles.nameFont,
                          fontSize: 16,
                          color: ink.withValues(alpha: 0.8))),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Overrides the colour scheme's onSurface so MushafText draws in page ink.
class _InkTheme extends StatelessWidget {
  const _InkTheme({required this.ink, required this.child});
  final Color ink;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Theme(
      data: theme.copyWith(
          colorScheme: theme.colorScheme.copyWith(onSurface: ink)),
      child: child,
    );
  }
}

class _Banner extends StatelessWidget {
  const _Banner({required this.surah, required this.frame, required this.ink});
  final Surah surah;
  final Color frame;
  final Color ink;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Column(
        children: [
          Container(
            height: 54,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF0E5C47), Color(0xFF177A5E), Color(0xFF0E5C47)],
              ),
              border: Border.symmetric(horizontal: BorderSide(color: frame, width: 1.4)),
            ),
            child: Stack(
              alignment: Alignment.center,
              children: [
                Positioned.fill(child: CustomPaint(painter: _BandPatternPainter(color: frame.withValues(alpha: 0.35)))),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 26, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFDF6E3),
                    borderRadius: BorderRadius.circular(22),
                    border: Border.all(color: AppColors.gold, width: 1.4),
                    boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 4, offset: Offset(0, 1))],
                  ),
                  child: Text(surah.name,
                      style: const TextStyle(
                          fontFamily: ArabicStyles.nameFont,
                          fontSize: 24,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF0E5C47))),
                ),
              ],
            ),
          ),
          if (surah.hasBismillahHeader)
            Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Text(bismillah,
                  textDirection: TextDirection.rtl,
                  style: TextStyle(
                      fontFamily: ArabicStyles.quranFont,
                      fontSize: 24,
                      height: 1.8,
                      color: ink)),
            ),
        ],
      ),
    );
  }
}

/// Translucent exit button shown in full-screen reading.
class _ImmersiveExit extends StatelessWidget {
  const _ImmersiveExit({required this.onTap, required this.label});
  final VoidCallback onTap;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.black.withValues(alpha: 0.35),
      shape: const CircleBorder(),
      child: IconButton(
        tooltip: label,
        icon: const Icon(Icons.fullscreen_exit, color: Colors.white),
        onPressed: onTap,
      ),
    );
  }
}

/// Minimal page controls shown in full-screen reading.
class _ImmersivePager extends StatelessWidget {
  const _ImmersivePager({required this.page, required this.onPrev, required this.onNext});
  final int page;
  final VoidCallback? onPrev;
  final VoidCallback? onNext;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.black.withValues(alpha: 0.35),
      borderRadius: BorderRadius.circular(24),
      child: Directionality(
        textDirection: TextDirection.ltr,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(icon: const Icon(Icons.chevron_left, color: Colors.white), onPressed: onPrev),
            Text('$page / ${QuranRepository.totalPages}', style: const TextStyle(color: Colors.white, fontSize: 12.5)),
            IconButton(icon: const Icon(Icons.chevron_right, color: Colors.white), onPressed: onNext),
          ],
        ),
      ),
    );
  }
}

/// Interlaced geometric lattice drawn over the surah band.
class _BandPatternPainter extends CustomPainter {
  const _BandPatternPainter({required this.color});
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final p = Paint()
      ..color = color
      ..strokeWidth = 0.9
      ..style = PaintingStyle.stroke;
    const step = 16.0;
    for (var x = -size.height; x < size.width + size.height; x += step) {
      canvas.drawLine(Offset(x, 0), Offset(x + size.height, size.height), p);
      canvas.drawLine(Offset(x + size.height, 0), Offset(x, size.height), p);
    }
    final dot = Paint()..color = color;
    for (var x = step / 2; x < size.width; x += step) {
      canvas.drawCircle(Offset(x, size.height / 2), 1.3, dot);
    }
  }

  @override
  bool shouldRepaint(covariant _BandPatternPainter old) => old.color != color;
}

class _PageBar extends StatelessWidget {
  const _PageBar(
      {required this.page, required this.onChanged, required this.onGoTo});
  final int page;
  final ValueChanged<int> onChanged;
  final VoidCallback onGoTo;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Material(
      color: scheme.surface,
      child: SafeArea(
        top: false,
        child: Container(
          height: 56,
          decoration: BoxDecoration(
              border: Border(
                  top: BorderSide(
                      color: scheme.outlineVariant.withValues(alpha: 0.5)))),
          child: Directionality(
            textDirection: TextDirection.ltr,
            child: Row(
              children: [
                IconButton(
                    tooltip: context.l10n.previousPage,
                    onPressed: page > 1 ? () => onChanged(page - 1) : null,
                    icon: const Icon(Icons.chevron_left)),
                Expanded(
                  child: Directionality(
                    textDirection: TextDirection.rtl,
                    child: Slider(
                      value: page.toDouble(),
                      min: 1,
                      max: QuranRepository.totalPages.toDouble(),
                      divisions: QuranRepository.totalPages - 1,
                      label: '$page',
                      onChanged: (v) => onChanged(v.round()),
                    ),
                  ),
                ),
                TextButton(
                    onPressed: onGoTo,
                    child: Text('$page / ${QuranRepository.totalPages}')),
                IconButton(
                    tooltip: context.l10n.nextPage,
                    onPressed: page < QuranRepository.totalPages
                        ? () => onChanged(page + 1)
                        : null,
                    icon: const Icon(Icons.chevron_right)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
