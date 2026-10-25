import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/l10n.dart';
import '../../core/theme.dart';
import '../../data/hadith_service.dart';
import '../../state/providers.dart';
import '../../widgets/book_spread.dart';
import 'hadith_export.dart';
import 'hadith_screens.dart';

/// Reads a hadith collection as a printed book: chapters are split into
/// fixed-density pages shown as paper pages you flip (one page or a two-page
/// spread) or scroll.
class HadithBookReaderScreen extends ConsumerStatefulWidget {
  const HadithBookReaderScreen({super.key, required this.bookId, this.chapter, this.page});
  final String bookId;
  final int? chapter;
  final int? page;

  @override
  ConsumerState<HadithBookReaderScreen> createState() => _HadithBookReaderScreenState();
}

/// Characters of text per printed page; a hadith longer than this gets a
/// page of its own and is scaled down.
// A page holds about 38 lines of 13px translation (~4200 chars) or 21 lines
// of 19px Arabic (~1575 chars), so Arabic characters weigh ~2.6x.
const _pageBudget = 3300.0;
const _arabicWeight = 2.6;
const _arabicChunk = 900; // raw characters, roughly 520 visible letters
const _textChunk = 1000;

/// Tashkeel and other combining marks take no horizontal space.
final _combiningMarks = RegExp('[ؐ-ًؚ-ٰٟۖ-ۭ]');
int _visibleLength(String s) => s.replaceAll(_combiningMarks, '').length;

/// A piece of a hadith placed on a page: a run of its Arabic or of its
/// translation. Long hadiths are split into several blocks so pages stay
/// evenly filled; [continued] marks a block that carries on from the
/// previous page and [continues] one that goes on to the next.
class HadithBlock {
  const HadithBlock({
    required this.hadith,
    this.arabic = '',
    this.text = '',
    this.continued = false,
    this.continues = false,
  });
  final Hadith hadith;
  final String arabic;
  final String text;
  final bool continued;
  final bool continues;

  double get weight => _visibleLength(arabic) * _arabicWeight + text.length + (continued ? 10 : 70);
}

/// Splits [s] into pieces of at most [max] characters at word boundaries.
List<String> _chunk(String s, int max) {
  final out = <String>[];
  var rest = s.trim();
  while (rest.length > max) {
    var cut = rest.lastIndexOf(' ', max);
    if (cut < max ~/ 2) cut = max;
    out.add(rest.substring(0, cut).trim());
    rest = rest.substring(cut).trim();
  }
  if (rest.isNotEmpty || out.isEmpty) out.add(rest);
  return out;
}

List<List<HadithBlock>> paginateHadiths(List<Hadith> hadiths, {double budget = _pageBudget}) {
  final blocks = <HadithBlock>[];
  for (final h in hadiths) {
    final units = <({String arabic, String text})>[
      for (final a in (h.arabic.isEmpty ? const <String>[] : _chunk(h.arabic, _arabicChunk))) (arabic: a, text: ''),
      for (final t in (h.text.isEmpty ? const <String>[] : _chunk(h.text, _textChunk))) (arabic: '', text: t),
    ];
    if (units.isEmpty) units.add((arabic: '', text: ''));
    for (var i = 0; i < units.length; i++) {
      blocks.add(HadithBlock(
        hadith: h,
        arabic: units[i].arabic,
        text: units[i].text,
        continued: i > 0,
        continues: i < units.length - 1,
      ));
    }
  }

  // Merge consecutive blocks of one hadith on the same page back together,
  // so a hadith that fits is shown as one piece.
  final pages = <List<HadithBlock>>[];
  var current = <HadithBlock>[];
  var used = 0.0;
  for (final b in blocks) {
    if (current.isNotEmpty && used + b.weight > budget) {
      pages.add(current);
      current = <HadithBlock>[];
      used = 0;
    }
    final last = current.isNotEmpty ? current.last : null;
    if (last != null && identical(last.hadith, b.hadith)) {
      current[current.length - 1] = HadithBlock(
        hadith: b.hadith,
        arabic: [last.arabic, b.arabic].where((s) => s.isNotEmpty).join(' '),
        text: [last.text, b.text].where((s) => s.isNotEmpty).join(' '),
        continued: last.continued,
        continues: b.continues,
      );
    } else {
      current.add(b);
    }
    used += b.weight;
  }
  if (current.isNotEmpty) pages.add(current);
  return pages.isEmpty ? [const []] : pages;
}

class _HadithBookReaderScreenState extends ConsumerState<HadithBookReaderScreen> {
  late int _chapter = widget.chapter ?? 1;
  late int _page = widget.page ?? 1; // 1-based within the chapter
  bool _jumpToLastPage = false;
  PageController? _flip;
  final _book = BookSpreadController();
  late bool _closed = (widget.chapter ?? 1) <= 1 && (widget.page ?? 1) <= 1;

  int _spreadOf(int page) => (page - 1) ~/ 2;

  @override
  void dispose() {
    _flip?.dispose();
    super.dispose();
  }

  MushafLayout _layout(BoxConstraints c) {
    final s = ref.read(settingsProvider).mushafLayout;
    if (s != MushafLayout.auto) return s;
    return c.maxWidth >= 900 ? MushafLayout.book : MushafLayout.flip;
  }

  void _openChapter(int chapter, {int page = 1, bool last = false}) {
    setState(() {
      _chapter = chapter;
      _page = page;
      _jumpToLastPage = last;
      _closed = false;
      _flip?.dispose();
      _flip = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final books = ref.watch(hadithBooksProvider);
    final settings = ref.watch(settingsProvider);
    final lang = settings.hadithLanguage;
    final scheme = Theme.of(context).colorScheme;

    final book = books.asData?.value.where((b) => b.id == widget.bookId).firstOrNull;
    if (book == null) {
      return Scaffold(
        appBar: AppBar(),
        body: Center(
          child: books.hasError ? Text(l.couldNotLoadHadithBooks('${books.error}')) : const CircularProgressIndicator(),
        ),
      );
    }
    final sections = book.sections;
    final idx = sections.indexWhere((s) => s.number == _chapter);
    final section = idx >= 0 ? sections[idx] : sections.first;
    final hadiths = ref.watch(hadithSectionProvider((book: book.id, section: section.number, lang: lang)));

    return LayoutBuilder(
      builder: (context, constraints) {
        final layout = _layout(constraints);
        return Scaffold(
          appBar: AppBar(
            leading: IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () => context.canPop() ? context.pop() : context.go('/hadith'),
            ),
            title: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(book.name, maxLines: 1, overflow: TextOverflow.ellipsis),
                Text('${section.number}. ${section.name}',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: scheme.onSurfaceVariant)),
              ],
            ),
            actions: [
              IconButton(
                tooltip: l.tableOfContents,
                icon: const Icon(Icons.toc),
                onPressed: () => _showContents(book),
              ),
              const HadithLanguageDropdown(),
              PopupMenuButton<String>(
                tooltip: l.more,
                onSelected: (v) {
                  switch (v) {
                    case 'list':
                      context.push('/hadith/${book.id}/${section.number}');
                    case 'pdf_chapter':
                      exportHadith(context, ref, book, chapterOnly: section, pdf: true);
                    case 'pdf_book':
                      exportHadith(context, ref, book, pdf: true);
                    case 'offline':
                      exportHadith(context, ref, book, pdf: false);
                    case 'layout_auto':
                      ref.read(settingsProvider.notifier).setMushafLayout(MushafLayout.auto);
                    case 'layout_scroll':
                      ref.read(settingsProvider.notifier).setMushafLayout(MushafLayout.scroll);
                    case 'layout_flip':
                      ref.read(settingsProvider.notifier).setMushafLayout(MushafLayout.flip);
                    case 'layout_book':
                      ref.read(settingsProvider.notifier).setMushafLayout(MushafLayout.book);
                  }
                },
                itemBuilder: (_) => [
                  PopupMenuItem(value: 'list', child: ListTile(leading: const Icon(Icons.view_list_outlined), title: Text(l.listView))),
                  PopupMenuItem(value: 'pdf_chapter', child: ListTile(leading: const Icon(Icons.picture_as_pdf_outlined), title: Text(l.downloadChapterPdf))),
                  PopupMenuItem(value: 'pdf_book', child: ListTile(leading: const Icon(Icons.library_books_outlined), title: Text(l.downloadBookPdf))),
                  PopupMenuItem(value: 'offline', child: ListTile(leading: const Icon(Icons.download_for_offline_outlined), title: Text(l.downloadForOffline))),
                  const PopupMenuDivider(),
                  _layoutItem('layout_auto', Icons.auto_awesome_outlined, l.layoutAutomatic, settings.mushafLayout == MushafLayout.auto),
                  _layoutItem('layout_scroll', Icons.swap_vert, l.layoutScroll, settings.mushafLayout == MushafLayout.scroll),
                  _layoutItem('layout_flip', Icons.auto_stories_outlined, l.layoutFlip, settings.mushafLayout == MushafLayout.flip),
                  _layoutItem('layout_book', Icons.menu_book_outlined, l.layoutBook, settings.mushafLayout == MushafLayout.book),
                ],
              ),
            ],
          ),
          body: hadiths.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (e, _) => Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.cloud_off, size: 40, color: scheme.error),
                    const SizedBox(height: 8),
                    Text('${l.chapterNeedsInternet}\n$e', textAlign: TextAlign.center),
                    const SizedBox(height: 12),
                    FilledButton.tonal(
                      onPressed: () => ref.invalidate(hadithSectionProvider((book: book.id, section: section.number, lang: lang))),
                      child: Text(l.retry),
                    ),
                  ],
                ),
              ),
            ),
            data: (list) {
              final pages = paginateHadiths(list);
              if (_jumpToLastPage) {
                _page = pages.length;
                _jumpToLastPage = false;
              }
              _page = _page.clamp(1, pages.length);
              _flip ??= PageController(initialPage: _page - 1);
              final bookIndex = BookCover.indexOf(books.asData?.value ?? const [], book);
              final lastChapter = idx >= sections.length - 1;
              final firstChapter = idx <= 0;

              // [fit]: keep the 2:3 page shape inside a loose frame (flip view).
              // [exact]: the frame already has the page's exact size (book view).
              Widget pageWidget(int i, {bool fit = true, bool exact = false}) => _HadithPaperPage(
                    key: ValueKey('hp-${section.number}-$i-$lang'),
                    book: book,
                    section: section,
                    blocks: pages[i],
                    pageNumber: i + 1,
                    totalPages: pages.length,
                    lang: lang,
                    fitToPage: fit || exact,
                    exactFrame: exact,
                  );

              final body = switch (layout) {
                MushafLayout.scroll => ListView.builder(
                    key: ValueKey('scroll-${book.id}-${section.number}-$lang'),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    itemCount: pages.length + 1,
                    itemBuilder: (context, i) {
                      if (i == pages.length) {
                        return _ChapterNav(
                          onPrev: firstChapter ? null : () => _openChapter(sections[idx - 1].number),
                          onNext: lastChapter ? null : () => _openChapter(sections[idx + 1].number),
                        );
                      }
                      return Center(
                        child: ConstrainedBox(
                          constraints: const BoxConstraints(maxWidth: 640),
                          child: Padding(
                            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                            child: pageWidget(i, fit: false),
                          ),
                        ),
                      );
                    },
                  ),
                MushafLayout.flip => Directionality(
                    textDirection: TextDirection.ltr,
                    child: PageView.builder(
                      key: ValueKey('flip-${book.id}-${section.number}-$lang'),
                      controller: _flip,
                      reverse: true,
                      itemCount: pages.length,
                      onPageChanged: (i) => setState(() => _page = i + 1),
                      itemBuilder: (context, i) => _Flipping(
                        controller: _flip!,
                        index: i,
                        child: Padding(padding: const EdgeInsets.fromLTRB(12, 8, 12, 8), child: pageWidget(i)),
                      ),
                    ),
                  ),
                _ => Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: Theme.of(context).brightness == Brightness.dark
                            ? const [Color(0xFF0B100E), Color(0xFF161D19)]
                            : const [Color(0xFFEDE6D6), Color(0xFFD9CFBC)],
                      ),
                    ),
                    padding: const EdgeInsets.fromLTRB(20, 14, 20, 14),
                    child: Directionality(
                      textDirection: TextDirection.ltr,
                      child: BookSpreadView(
                        key: ValueKey('book-${book.id}-${section.number}-$lang'),
                        controller: _book,
                        style: switch (settings.pageAnimation) {
                          PageAnimation.curl => BookTurnStyle.curl,
                          PageAnimation.flip => BookTurnStyle.flip,
                          PageAnimation.slide => BookTurnStyle.slide,
                          PageAnimation.fade => BookTurnStyle.fade,
                        },
                        spreadCount: (pages.length / 2).ceil(),
                        initialSpread: _closed && idx == 0 ? -1 : _spreadOf(_page),
                        cover: idx == 0 ? BookCover(book: book, index: bookIndex, showCaption: false) : null,
                        rightPage: (k) => k * 2 < pages.length ? pageWidget(k * 2, fit: false, exact: true) : null,
                        leftPage: (k) => k * 2 + 1 < pages.length ? pageWidget(k * 2 + 1, fit: false, exact: true) : null,
                        onSpreadChanged: (k) => setState(() {
                          _closed = k < 0;
                          if (k >= 0) _page = k * 2 + 1;
                        }),
                      ),
                    ),
                  ),
              };

              return Column(
                children: [
                  Expanded(child: body),
                  _PageBar(
                    label: l.chapterPage(section.number, _page, pages.length),
                    canPrev: _page > 1 || !firstChapter,
                    canNext: _page < pages.length || !lastChapter,
                    onLabelTap: () => _showContents(book),
                    onPrev: () {
                      if (_page > 1) {
                        _goTo(_page - 1, layout);
                      } else if (!firstChapter) {
                        _openChapter(sections[idx - 1].number, last: true);
                      }
                    },
                    onNext: () {
                      if (_page < pages.length) {
                        _goTo(_page + 1, layout);
                      } else if (!lastChapter) {
                        _openChapter(sections[idx + 1].number);
                      }
                    },
                  ),
                ],
              );
            },
          ),
        );
      },
    );
  }

  PopupMenuItem<String> _layoutItem(String v, IconData icon, String label, bool selected) => PopupMenuItem(
        value: v,
        child: ListTile(
          leading: Icon(icon),
          title: Text(label),
          trailing: selected ? const Icon(Icons.check) : null,
          contentPadding: EdgeInsets.zero,
        ),
      );

  void _goTo(int page, MushafLayout layout) {
    setState(() => _page = page);
    switch (layout) {
      case MushafLayout.flip:
        if (_flip?.hasClients ?? false) {
          _flip!.animateToPage(page - 1, duration: const Duration(milliseconds: 450), curve: Curves.easeInOutCubic);
        }
      case MushafLayout.book:
      case MushafLayout.auto:
        _closed = false;
        _book.animateTo(_spreadOf(page));
      case MushafLayout.scroll:
        break;
    }
  }

  Future<void> _showContents(HadithBook book) async {
    final picked = await showModalBottomSheet<int>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      useSafeArea: true,
      builder: (context) => DraggableScrollableSheet(
        expand: false,
        initialChildSize: 0.7,
        maxChildSize: 0.95,
        builder: (context, controller) => _ContentsSheet(book: book, current: _chapter, controller: controller),
      ),
    );
    if (picked != null) _openChapter(picked);
  }

}

class _ContentsSheet extends StatefulWidget {
  const _ContentsSheet({required this.book, required this.current, required this.controller});
  final HadithBook book;
  final int current;
  final ScrollController controller;

  @override
  State<_ContentsSheet> createState() => _ContentsSheetState();
}

class _ContentsSheetState extends State<_ContentsSheet> {
  String _query = '';

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final q = _query.trim().toLowerCase();
    final sections = q.isEmpty
        ? widget.book.sections
        : widget.book.sections.where((s) => s.name.toLowerCase().contains(q) || '${s.number}' == q).toList();
    final scheme = Theme.of(context).colorScheme;
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
          child: Row(
            children: [
              Expanded(
                child: Text(l.tableOfContents, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
              ),
              Text(widget.book.arabic, style: ArabicStyles.surahName(context, size: 18, color: scheme.primary)),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
          child: TextField(
            onChanged: (v) => setState(() => _query = v),
            decoration: InputDecoration(hintText: l.findAChapter, prefixIcon: const Icon(Icons.search), isDense: true),
          ),
        ),
        Expanded(
          child: ListView.builder(
            controller: widget.controller,
            itemCount: sections.length,
            itemBuilder: (context, i) {
              final s = sections[i];
              final selected = s.number == widget.current;
              return ListTile(
                selected: selected,
                leading: Text('${s.number}', style: TextStyle(fontWeight: FontWeight.w700, color: scheme.primary)),
                title: Text(s.name),
                subtitle: s.count > 0 ? Text(l.hadithsRange(s.first, s.last)) : null,
                onTap: () => Navigator.of(context).pop(s.number),
              );
            },
          ),
        ),
      ],
    );
  }
}

/// A printed page of a hadith book, with the same paper styling as the Mushaf.
class _HadithPaperPage extends StatelessWidget {
  const _HadithPaperPage({
    super.key,
    required this.book,
    required this.section,
    required this.blocks,
    required this.pageNumber,
    required this.totalPages,
    required this.lang,
    required this.fitToPage,
    this.exactFrame = false,
  });

  final HadithBook book;
  final HadithSection section;
  final List<HadithBlock> blocks;
  final int pageNumber;
  final int totalPages;
  final String lang;
  final bool fitToPage;
  final bool exactFrame;

  static const pageAspect = 0.68;
  static const layoutWidth = 420.0;

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    final paper = dark ? const Color(0xFF1C1A15) : const Color(0xFFFDF6E3);
    final ink = dark ? const Color(0xFFE8E2D0) : const Color(0xFF2B2416);
    final frame = AppColors.gold.withValues(alpha: dark ? 0.55 : 0.8);
    final rtl = hadithLanguageIsRtl(lang);

    final body = Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (pageNumber == 1)
          Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 12),
              decoration: BoxDecoration(
                border: Border.symmetric(horizontal: BorderSide(color: frame, width: 1.2)),
                color: frame.withValues(alpha: 0.08),
              ),
              child: Text(
                '${section.number}. ${section.name}',
                textAlign: TextAlign.center,
                style: TextStyle(fontFamily: ArabicStyles.nameFont, fontSize: 20, fontWeight: FontWeight.w700, color: ink),
              ),
            ),
          ),
        for (final b in blocks)
          Padding(
            padding: EdgeInsets.only(bottom: b.continues ? 4 : 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (!b.continued)
                  Row(
                    children: [
                      Text('${b.hadith.number}', style: const TextStyle(fontFamily: ArabicStyles.nameFont, fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.gold)),
                      if (b.hadith.grades.isNotEmpty) ...[
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(b.hadith.grades.take(2).join(', '),
                              maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(fontSize: 10, color: ink.withValues(alpha: 0.6))),
                        ),
                      ],
                    ],
                  )
                else
                  Text('${b.hadith.number} …', style: TextStyle(fontFamily: ArabicStyles.nameFont, fontSize: 11, color: AppColors.gold.withValues(alpha: 0.7))),
                if (b.arabic.isNotEmpty)
                  Text(
                    b.arabic + (b.continues && b.text.isEmpty ? ' …' : ''),
                    textDirection: TextDirection.rtl,
                    textAlign: TextAlign.justify,
                    style: TextStyle(fontFamily: ArabicStyles.nameFont, fontSize: 21, height: 1.85, color: ink),
                  ),
                if (b.text.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Text(
                      b.text + (b.continues ? ' …' : ''),
                      textDirection: rtl ? TextDirection.rtl : TextDirection.ltr,
                      textAlign: rtl ? TextAlign.right : TextAlign.left,
                      style: TextStyle(
                        fontSize: rtl ? 17 : 13.5,
                        height: rtl ? 1.8 : 1.5,
                        fontFamily: rtl ? ArabicStyles.nameFont : null,
                        color: ink.withValues(alpha: 0.9),
                      ),
                    ),
                  ),
              ],
            ),
          ),
      ],
    );

    final page = Container(
      decoration: BoxDecoration(
        color: paper,
        borderRadius: BorderRadius.circular(6),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: dark ? 0.5 : 0.18), blurRadius: 14, offset: const Offset(0, 6))],
      ),
      padding: const EdgeInsets.all(10),
      child: Container(
        decoration: BoxDecoration(border: Border.all(color: frame, width: 1.6), borderRadius: BorderRadius.circular(4)),
        padding: const EdgeInsets.all(4),
        child: Container(
          decoration: BoxDecoration(border: Border.all(color: frame.withValues(alpha: 0.5), width: 0.8)),
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 10),
          child: DefaultTextStyle(
            style: TextStyle(color: ink),
            child: Column(
              mainAxisSize: fitToPage ? MainAxisSize.max : MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(section.name, maxLines: 1, overflow: TextOverflow.ellipsis,
                          style: TextStyle(fontSize: 11, color: ink.withValues(alpha: 0.7))),
                    ),
                    const SizedBox(width: 12),
                    Text(book.arabic, style: TextStyle(fontFamily: ArabicStyles.nameFont, fontSize: 14, color: ink.withValues(alpha: 0.85))),
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
                  child: Text('$pageNumber / $totalPages', style: TextStyle(fontSize: 11, color: ink.withValues(alpha: 0.7))),
                ),
              ],
            ),
          ),
        ),
      ),
    );

    if (!fitToPage || exactFrame) return page;
    return Center(child: AspectRatio(aspectRatio: pageAspect, child: page));
  }
}

class _Flipping extends StatelessWidget {
  const _Flipping({required this.controller, required this.index, required this.child});
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
          delta = (controller.page ?? controller.initialPage.toDouble()) - index;
        }
        final t = delta.clamp(-1.0, 1.0);
        return Transform(
          alignment: t >= 0 ? Alignment.centerRight : Alignment.centerLeft,
          transform: Matrix4.identity()
            ..setEntry(3, 2, 0.0012)
            ..rotateY(-t * math.pi / 2 * 0.35),
          child: Opacity(opacity: 1 - t.abs() * 0.25, child: child),
        );
      },
    );
  }
}

class _ChapterNav extends StatelessWidget {
  const _ChapterNav({this.onPrev, this.onNext});
  final VoidCallback? onPrev;
  final VoidCallback? onNext;

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
      child: Row(
        children: [
          if (onPrev != null)
            TextButton.icon(onPressed: onPrev, icon: const Icon(Icons.chevron_left), label: Text(l.previousChapter)),
          const Spacer(),
          if (onNext != null)
            TextButton.icon(onPressed: onNext, icon: const Icon(Icons.chevron_right), label: Text(l.nextChapter)),
        ],
      ),
    );
  }
}

class _PageBar extends StatelessWidget {
  const _PageBar({
    required this.label,
    required this.canPrev,
    required this.canNext,
    required this.onPrev,
    required this.onNext,
    required this.onLabelTap,
  });

  final String label;
  final bool canPrev;
  final bool canNext;
  final VoidCallback onPrev;
  final VoidCallback onNext;
  final VoidCallback onLabelTap;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Material(
      color: scheme.surface,
      child: SafeArea(
        top: false,
        child: Container(
          height: 52,
          decoration: BoxDecoration(border: Border(top: BorderSide(color: scheme.outlineVariant.withValues(alpha: 0.5)))),
          child: Directionality(
            textDirection: TextDirection.ltr,
            child: Row(
              children: [
                IconButton(tooltip: context.l10n.previousPage, onPressed: canPrev ? onPrev : null, icon: const Icon(Icons.chevron_left)),
                Expanded(child: TextButton(onPressed: onLabelTap, child: Text(label, overflow: TextOverflow.ellipsis))),
                IconButton(tooltip: context.l10n.nextPage, onPressed: canNext ? onNext : null, icon: const Icon(Icons.chevron_right)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
