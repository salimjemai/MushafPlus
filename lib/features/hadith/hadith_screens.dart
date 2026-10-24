import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:share_plus/share_plus.dart';

import '../../core/l10n.dart';
import '../../core/theme.dart';
import '../../data/hadith_service.dart';
import '../../state/providers.dart';
import '../../widgets/surah_number_badge.dart';

// ---------------------------------------------------------------------------
// Books
// ---------------------------------------------------------------------------

/// The hadith library: a shelf of book covers; tap one to open it as a book.
class HadithBooksScreen extends ConsumerWidget {
  const HadithBooksScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = context.l10n;
    final books = ref.watch(hadithBooksProvider);
    final scheme = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Text(l.hadith),
            const SizedBox(width: 10),
            Text('المكتبة', style: ArabicStyles.surahName(context, size: 18, color: scheme.primary)),
          ],
        ),
        actions: const [Padding(padding: EdgeInsets.only(right: 8), child: HadithLanguageDropdown())],
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 980),
          child: books.when(
            data: (list) => LayoutBuilder(
              builder: (context, constraints) {
                final columns = (constraints.maxWidth / 190).floor().clamp(2, 5);
                return CustomScrollView(
                  slivers: [
                    SliverPadding(
                      padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
                      sliver: SliverToBoxAdapter(
                        child: Text(
                          l.hadithIntro,
                          style: TextStyle(color: scheme.onSurfaceVariant, height: 1.5, fontSize: 13.5),
                        ),
                      ),
                    ),
                    SliverPadding(
                      padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
                      sliver: SliverGrid(
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: columns,
                          mainAxisSpacing: 20,
                          crossAxisSpacing: 18,
                          childAspectRatio: 0.58,
                        ),
                        delegate: SliverChildBuilderDelegate(
                          (context, i) => BookCover(book: list[i], index: i, onTap: () => context.go('/hadith/${list[i].id}')),
                          childCount: list.length,
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (e, _) => Center(child: Text(l.couldNotLoadHadithBooks('$e'))),
          ),
        ),
      ),
    );
  }
}

const _authors = <String, String>{
  'bukhari': 'Imam al-Bukhari (d. 256 AH)',
  'muslim': 'Imam Muslim (d. 261 AH)',
  'nasai': "Imam an-Nasa'i (d. 303 AH)",
  'abudawud': 'Imam Abu Dawud (d. 275 AH)',
  'tirmidhi': 'Imam at-Tirmidhi (d. 279 AH)',
  'ibnmajah': 'Imam Ibn Majah (d. 273 AH)',
  'malik': 'Imam Malik (d. 179 AH)',
  'nawawi': 'Imam an-Nawawi (d. 676 AH)',
  'qudsi': 'Hadith Qudsi',
  'dehlawi': 'Shah Waliullah Dehlawi (d. 1176 AH)',
};

const _coverColors = <List<Color>>[
  [Color(0xFF5A1F1F), Color(0xFF3A1010)], // maroon leather
  [Color(0xFF14432F), Color(0xFF0B2A1D)], // deep green
  [Color(0xFF1C2E5A), Color(0xFF101C3A)], // navy
  [Color(0xFF4A2F14), Color(0xFF2E1C0A)], // brown
  [Color(0xFF3D1B4F), Color(0xFF26102F)], // plum
  [Color(0xFF0F3F4A), Color(0xFF082730)], // teal
  [Color(0xFF5A3A1F), Color(0xFF3A2410)], // tan
  [Color(0xFF2B2B2B), Color(0xFF151515)], // black
  [Color(0xFF6B2A15), Color(0xFF43190B)], // rust
  [Color(0xFF1F3F5A), Color(0xFF10273A)], // steel blue
];

/// A leather-bound book cover with gold tooling, spine and the title in Arabic.
class BookCover extends StatelessWidget {
  const BookCover({super.key, required this.book, required this.index, this.onTap, this.showCaption = true});
  final HadithBook book;
  final int index;
  final VoidCallback? onTap;

  /// Show the title, author and count under the cover (library shelf).
  final bool showCaption;

  /// Index of [book] in the library, used to pick its cover colour.
  static int indexOf(List<HadithBook> books, HadithBook book) {
    final i = books.indexWhere((b) => b.id == book.id);
    return i < 0 ? 0 : i;
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final colors = _coverColors[index % _coverColors.length];
    const gold = AppColors.goldLight;
    if (!showCaption) return _cover(context, colors, gold);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(child: _cover(context, colors, gold)),
        const SizedBox(height: 8),
        Text(book.name, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13.5)),
        Text(
          _authors[book.id] ?? '',
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(fontSize: 11.5, color: Theme.of(context).colorScheme.onSurfaceVariant),
        ),
        Text(
          l.hadithsCount(book.hadithCount),
          style: TextStyle(fontSize: 11.5, color: Theme.of(context).colorScheme.onSurfaceVariant),
        ),
      ],
    );
  }

  Widget _cover(BuildContext context, List<Color> colors, Color gold) {
    final l = context.l10n;
    return Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: onTap,
              borderRadius: BorderRadius.circular(6),
              child: Tooltip(
                message: l.openBook,
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: const BorderRadius.horizontal(left: Radius.circular(3), right: Radius.circular(7)),
                    gradient: LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: colors),
                    boxShadow: [
                      BoxShadow(color: Colors.black.withValues(alpha: 0.45), blurRadius: 14, offset: const Offset(4, 8)),
                    ],
                  ),
                  child: Row(
                    children: [
                      // Spine
                      Container(
                        width: 14,
                        decoration: BoxDecoration(
                          borderRadius: const BorderRadius.horizontal(left: Radius.circular(3)),
                          gradient: LinearGradient(
                            begin: Alignment.centerLeft,
                            end: Alignment.centerRight,
                            colors: [Colors.black.withValues(alpha: 0.45), Colors.transparent, Colors.black.withValues(alpha: 0.25)],
                          ),
                        ),
                      ),
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.all(8),
                          child: Container(
                            decoration: BoxDecoration(
                              border: Border.all(color: gold.withValues(alpha: 0.85), width: 1.4),
                              borderRadius: BorderRadius.circular(3),
                            ),
                            padding: const EdgeInsets.all(3),
                            child: Container(
                              decoration: BoxDecoration(
                                border: Border.all(color: gold.withValues(alpha: 0.45), width: 0.7),
                              ),
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text('۞', style: TextStyle(fontFamily: ArabicStyles.nameFont, color: gold.withValues(alpha: 0.9), fontSize: 16)),
                                  FittedBox(
                                    fit: BoxFit.scaleDown,
                                    child: Column(
                                      children: [
                                        Text(
                                          book.arabic,
                                          textAlign: TextAlign.center,
                                          style: TextStyle(
                                            fontFamily: ArabicStyles.nameFont,
                                            fontSize: 26,
                                            fontWeight: FontWeight.w700,
                                            color: gold,
                                            height: 1.4,
                                          ),
                                        ),
                                        const SizedBox(height: 6),
                                        Text(
                                          book.name,
                                          textAlign: TextAlign.center,
                                          style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: gold.withValues(alpha: 0.95), letterSpacing: 0.4),
                                        ),
                                      ],
                                    ),
                                  ),
                                  SurahNumberBadge(number: index + 1, size: 30, color: gold, textColor: gold),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
  }
}

class HadithLanguageDropdown extends ConsumerWidget {
  const HadithLanguageDropdown({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final lang = ref.watch(settingsProvider.select((s) => s.hadithLanguage));
    return DropdownButton<String>(
      value: hadithLanguages.containsKey(lang) ? lang : 'eng',
      underline: const SizedBox.shrink(),
      items: [for (final e in hadithLanguages.entries) DropdownMenuItem(value: e.key, child: Text(e.value))],
      onChanged: (v) {
        if (v != null) ref.read(settingsProvider.notifier).setHadithLanguage(v);
      },
    );
  }
}

// ---------------------------------------------------------------------------
// Chapters of a book
// ---------------------------------------------------------------------------

class HadithBookScreen extends ConsumerStatefulWidget {
  const HadithBookScreen({super.key, required this.bookId});
  final String bookId;

  @override
  ConsumerState<HadithBookScreen> createState() => _HadithBookScreenState();
}

class _HadithBookScreenState extends ConsumerState<HadithBookScreen> {
  String _query = '';

  @override
  Widget build(BuildContext context) {
    final books = ref.watch(hadithBooksProvider);
    final scheme = Theme.of(context).colorScheme;
    return books.when(
      loading: () => const Scaffold(body: Center(child: CircularProgressIndicator())),
      error: (e, _) => Scaffold(body: Center(child: Text('$e'))),
      data: (list) {
        final book = list.firstWhere((b) => b.id == widget.bookId, orElse: () => list.first);
        final q = _query.trim().toLowerCase();
        final sections = q.isEmpty
            ? book.sections
            : book.sections.where((s) => s.name.toLowerCase().contains(q) || '${s.number}' == q).toList();
        return Scaffold(
          appBar: AppBar(
            leading: IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () => context.canPop() ? context.pop() : context.go('/hadith'),
            ),
            title: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(book.name),
                Text(context.l10n.hadithsChapters(book.hadithCount, book.sections.length),
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: scheme.onSurfaceVariant)),
              ],
            ),
          ),
          body: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 820),
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
                    child: TextField(
                      onChanged: (v) => setState(() => _query = v),
                      decoration: InputDecoration(hintText: context.l10n.findAChapter, prefixIcon: const Icon(Icons.search)),
                    ),
                  ),
                  Expanded(
                    child: ListView.builder(
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                      itemCount: sections.length,
                      itemBuilder: (context, i) {
                        final s = sections[i];
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: Card(
                            child: ListTile(
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                              leading: SurahNumberBadge(number: s.number, size: 40),
                              title: Text(s.name, style: const TextStyle(fontWeight: FontWeight.w600)),
                              subtitle: Text(s.count > 0 ? context.l10n.hadithsRange(s.first, s.last) : context.l10n.chapterN(s.number)),
                              trailing: const Icon(Icons.chevron_right),
                              onTap: () => context.go('/hadith/${book.id}/${s.number}'),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

// ---------------------------------------------------------------------------
// Hadiths of a chapter
// ---------------------------------------------------------------------------

class HadithSectionScreen extends ConsumerStatefulWidget {
  const HadithSectionScreen({super.key, required this.bookId, required this.section});
  final String bookId;
  final int section;

  @override
  ConsumerState<HadithSectionScreen> createState() => _HadithSectionScreenState();
}

class _HadithSectionScreenState extends ConsumerState<HadithSectionScreen> {
  String _query = '';

  @override
  Widget build(BuildContext context) {
    final books = ref.watch(hadithBooksProvider);
    final settings = ref.watch(settingsProvider);
    final lang = settings.hadithLanguage;
    final hadiths = ref.watch(hadithSectionProvider((book: widget.bookId, section: widget.section, lang: lang)));
    final scheme = Theme.of(context).colorScheme;
    final book = books.asData?.value.where((b) => b.id == widget.bookId).firstOrNull;
    final section = book?.sections.where((s) => s.number == widget.section).firstOrNull;
    final rtl = hadithLanguageIsRtl(lang);
    final sections = book?.sections ?? const [];
    final idx = sections.indexWhere((s) => s.number == widget.section);

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.canPop() ? context.pop() : context.go('/hadith/${widget.bookId}'),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(section?.name ?? context.l10n.chapterN(widget.section), maxLines: 1, overflow: TextOverflow.ellipsis),
            Text(book?.name ?? '', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: scheme.onSurfaceVariant)),
          ],
        ),
        actions: const [Padding(padding: EdgeInsets.only(right: 8), child: HadithLanguageDropdown())],
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 820),
          child: hadiths.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (e, _) => Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.cloud_off, size: 40, color: scheme.error),
                    const SizedBox(height: 8),
                    Text('${context.l10n.chapterNeedsInternet}\n$e', textAlign: TextAlign.center),
                    const SizedBox(height: 12),
                    FilledButton.tonal(
                      onPressed: () => ref.invalidate(
                          hadithSectionProvider((book: widget.bookId, section: widget.section, lang: lang))),
                      child: Text(context.l10n.retry),
                    ),
                  ],
                ),
              ),
            ),
            data: (list) {
              final q = _query.trim().toLowerCase();
              final shown = q.isEmpty
                  ? list
                  : list.where((h) => h.text.toLowerCase().contains(q) || h.arabic.contains(q) || '${h.number}' == q).toList();
              return Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
                    child: TextField(
                      onChanged: (v) => setState(() => _query = v),
                      decoration: InputDecoration(
                        hintText: context.l10n.searchHadithsInChapter(list.length),
                        prefixIcon: const Icon(Icons.search),
                      ),
                    ),
                  ),
                  Expanded(
                    child: ListView.builder(
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                      itemCount: shown.length + 1,
                      itemBuilder: (context, i) {
                        if (i == shown.length) {
                          return Padding(
                            padding: const EdgeInsets.only(top: 8),
                            child: Row(
                              children: [
                                if (idx > 0)
                                  TextButton.icon(
                                    onPressed: () => context.go('/hadith/${widget.bookId}/${sections[idx - 1].number}'),
                                    icon: const Icon(Icons.chevron_left),
                                    label: Text(context.l10n.previousChapter),
                                  ),
                                const Spacer(),
                                if (idx >= 0 && idx < sections.length - 1)
                                  TextButton.icon(
                                    onPressed: () => context.go('/hadith/${widget.bookId}/${sections[idx + 1].number}'),
                                    icon: const Icon(Icons.chevron_right),
                                    label: Text(context.l10n.nextChapter),
                                  ),
                              ],
                            ),
                          );
                        }
                        final h = shown[i];
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 10),
                          child: _HadithCard(hadith: h, rtl: rtl, scale: settings.translationScale, bookName: book?.name ?? widget.bookId),
                        );
                      },
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}

class _HadithCard extends StatelessWidget {
  const _HadithCard({required this.hadith, required this.rtl, required this.scale, required this.bookName});
  final Hadith hadith;
  final bool rtl;
  final double scale;
  final String bookName;

  String get _shareText =>
      '${hadith.arabic}\n\n${hadith.text}\n\n— $bookName, Hadith ${hadith.number}'
      '${hadith.grades.isNotEmpty ? ' · ${hadith.grades.join(', ')}' : ''}';

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Card(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 10, 16, 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: scheme.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text('#${hadith.number}',
                      style: TextStyle(fontWeight: FontWeight.w700, color: scheme.primary, fontSize: 13)),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Wrap(
                    spacing: 6,
                    children: [
                      for (final g in hadith.grades.take(2))
                        Chip(
                          label: Text(g, style: const TextStyle(fontSize: 11)),
                          visualDensity: VisualDensity.compact,
                          padding: EdgeInsets.zero,
                        ),
                    ],
                  ),
                ),
                IconButton(
                  tooltip: context.l10n.copy,
                  visualDensity: VisualDensity.compact,
                  icon: const Icon(Icons.copy_outlined, size: 18),
                  onPressed: () {
                    Clipboard.setData(ClipboardData(text: _shareText));
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(context.l10n.hadithCopied)));
                  },
                ),
                IconButton(
                  tooltip: context.l10n.share,
                  visualDensity: VisualDensity.compact,
                  icon: const Icon(Icons.ios_share, size: 18),
                  onPressed: () => Share.share(_shareText),
                ),
              ],
            ),
            const SizedBox(height: 8),
            if (hadith.arabic.isNotEmpty)
              Text(
                hadith.arabic,
                textDirection: TextDirection.rtl,
                textAlign: TextAlign.right,
                style: TextStyle(fontFamily: ArabicStyles.nameFont, fontSize: 21 * scale, height: 1.9, color: scheme.onSurface),
              ),
            if (hadith.text.isNotEmpty) ...[
              const SizedBox(height: 10),
              Text(
                hadith.text,
                textDirection: rtl ? TextDirection.rtl : TextDirection.ltr,
                textAlign: rtl ? TextAlign.right : TextAlign.left,
                style: TextStyle(
                  fontSize: (rtl ? 18 : 15) * scale,
                  height: rtl ? 1.9 : 1.55,
                  fontFamily: rtl ? ArabicStyles.nameFont : null,
                  color: scheme.onSurface,
                ),
              ),
            ],
            if (hadith.reference.isNotEmpty) ...[
              const SizedBox(height: 6),
              Text(hadith.reference, style: TextStyle(fontSize: 11.5, color: scheme.outline)),
            ],
          ],
        ),
      ),
    );
  }
}
