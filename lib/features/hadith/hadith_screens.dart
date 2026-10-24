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

class HadithBooksScreen extends ConsumerWidget {
  const HadithBooksScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = context.l10n;
    final books = ref.watch(hadithBooksProvider);
    final scheme = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(
        title: Text(l.hadith),
        actions: const [Padding(padding: EdgeInsets.only(right: 8), child: HadithLanguageDropdown())],
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 820),
          child: books.when(
            data: (list) => ListView(
              padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
              children: [
                Text(
                  l.hadithIntro,
                  style: TextStyle(color: scheme.onSurfaceVariant, height: 1.5, fontSize: 13.5),
                ),
                const SizedBox(height: 12),
                for (final b in list) ...[
                  Card(
                    child: ListTile(
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                      leading: SurahNumberBadge(number: list.indexOf(b) + 1, size: 42, color: scheme.secondary),
                      title: Text(b.name, style: const TextStyle(fontWeight: FontWeight.w700)),
                      subtitle: Text(l.hadithsChapters(b.hadithCount, b.sections.length)),
                      trailing: Text(b.arabic, style: ArabicStyles.surahName(context, size: 18, color: scheme.primary)),
                      onTap: () => context.go('/hadith/${b.id}'),
                    ),
                  ),
                  const SizedBox(height: 8),
                ],
              ],
            ),
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (e, _) => Center(child: Text(l.couldNotLoadHadithBooks('$e'))),
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
