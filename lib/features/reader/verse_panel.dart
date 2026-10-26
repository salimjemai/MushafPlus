import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:share_plus/share_plus.dart';

import '../../core/arabic_utils.dart';
import '../../core/l10n.dart';
import '../../core/theme.dart';
import '../../data/models.dart';
import '../../data/tafsir_service.dart';
import '../../state/audio_controller.dart';
import '../../state/providers.dart';
import 'audio_downloads.dart';
import 'ayah_actions.dart';
import 'tafsir_sheet.dart';
import 'word_by_word_view.dart';

enum VerseTab { translation, tafsir, words, note }

/// The per-ayah panel: a toolbar (play, bookmark, highlight, note, memorize,
/// recite, copy, share, download) and tabs for translation, tafsir,
/// word-by-word and a personal note, with previous/next ayah arrows.
Future<void> showVersePanel(BuildContext context, Ayah ayah, {VerseTab tab = VerseTab.translation}) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    showDragHandle: true,
    useSafeArea: true,
    builder: (context) => DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.78,
      maxChildSize: 0.96,
      minChildSize: 0.4,
      builder: (context, controller) => VersePanel(ayah: ayah, initialTab: tab, scrollController: controller),
    ),
  );
}

class VersePanel extends ConsumerStatefulWidget {
  const VersePanel({super.key, required this.ayah, this.initialTab = VerseTab.translation, this.scrollController});
  final Ayah ayah;
  final VerseTab initialTab;
  final ScrollController? scrollController;

  @override
  ConsumerState<VersePanel> createState() => _VersePanelState();
}

class _VersePanelState extends ConsumerState<VersePanel> with SingleTickerProviderStateMixin {
  late Ayah _ayah = widget.ayah;
  late final TabController _tabs = TabController(length: VerseTab.values.length, vsync: this, initialIndex: widget.initialTab.index);
  late final TextEditingController _note = TextEditingController(text: ref.read(notesProvider)[widget.ayah.number] ?? '');

  @override
  void dispose() {
    _tabs.dispose();
    _note.dispose();
    super.dispose();
  }

  void _go(int delta) {
    final repo = ref.read(repositoryProvider).requireValue;
    final n = (_ayah.number + delta).clamp(1, repo.ayahs.length);
    setState(() {
      _ayah = repo.ayah(n);
      _note.text = ref.read(notesProvider)[n] ?? '';
    });
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final repo = ref.quran;
    final settings = ref.watch(settingsProvider);
    final scheme = Theme.of(context).colorScheme;
    final surah = repo.surah(_ayah.surah);
    final bookmarked = ref.watch(bookmarksProvider.select((b) => b.any((x) => x.ayahNumber == _ayah.number)));
    final highlight = ref.watch(highlightsProvider)[_ayah.number];
    final hasNote = ref.watch(notesProvider).containsKey(_ayah.number);
    final audio = ref.watch(audioProvider.select((a) => (current: a.ayah == _ayah.number, playing: a.ayah == _ayah.number && a.playing)));

    return Column(
      children: [
        // ---- header --------------------------------------------------------
        Padding(
          padding: const EdgeInsets.fromLTRB(8, 0, 8, 0),
          child: Row(
            children: [
              IconButton(tooltip: l.previousAyah, icon: const Icon(Icons.chevron_left), onPressed: _ayah.number > 1 ? () => _go(-1) : null),
              Expanded(
                child: Column(
                  children: [
                    Text('${surah.englishName} · ${l.ayahN(_ayah.numberInSurah)}',
                        style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15)),
                    Text('${surah.name} · ${l.juzPage(_ayah.juz, _ayah.page)}',
                        style: TextStyle(fontSize: 11.5, color: scheme.onSurfaceVariant, fontFamily: ArabicStyles.nameFont)),
                  ],
                ),
              ),
              IconButton(tooltip: l.nextAyah, icon: const Icon(Icons.chevron_right), onPressed: _ayah.number < repo.ayahs.length ? () => _go(1) : null),
            ],
          ),
        ),
        // ---- Arabic ---------------------------------------------------------
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 4, 20, 0),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: highlight != null ? highlightColors[highlight].withValues(alpha: 0.28) : scheme.primary.withValues(alpha: 0.06),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Text(
              _ayah.text,
              textDirection: TextDirection.rtl,
              textAlign: TextAlign.right,
              style: ArabicStyles.ayah(context, scale: 0.85 * settings.arabicScale, font: settings.arabicFont),
            ),
          ),
        ),
        // ---- toolbar --------------------------------------------------------
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.fromLTRB(12, 6, 12, 0),
          child: Row(
            children: [
              IconButton(
                tooltip: audio.playing ? l.pause : l.playFromThisAyah,
                icon: Icon(audio.playing ? Icons.pause_circle : Icons.play_circle_outline, color: audio.current ? scheme.primary : null),
                onPressed: () => audio.current ? ref.read(audioProvider.notifier).toggle() : ref.read(audioProvider.notifier).playAyah(_ayah.number),
              ),
              IconButton(
                tooltip: bookmarked ? l.removeBookmark : l.bookmark,
                icon: Icon(bookmarked ? Icons.bookmark : Icons.bookmark_border, color: bookmarked ? scheme.secondary : null),
                onPressed: () => ref.read(bookmarksProvider.notifier).toggle(_ayah.number),
              ),
              PopupMenuButton<int>(
                tooltip: l.highlight,
                icon: Icon(Icons.format_color_fill, color: highlight != null ? highlightColors[highlight] : null),
                onSelected: (v) => ref.read(highlightsProvider.notifier).set(_ayah.number, v < 0 ? null : v),
                itemBuilder: (_) => [
                  for (var i = 0; i < highlightColors.length; i++)
                    PopupMenuItem(
                      value: i,
                      child: Row(children: [
                        Container(width: 18, height: 18, decoration: BoxDecoration(color: highlightColors[i], shape: BoxShape.circle)),
                        const SizedBox(width: 10),
                        Text(l.highlight),
                        if (highlight == i) ...[const Spacer(), const Icon(Icons.check, size: 18)],
                      ]),
                    ),
                  PopupMenuItem(value: -1, child: Row(children: [const Icon(Icons.format_color_reset, size: 18), const SizedBox(width: 10), Text(l.removeHighlight)])),
                ],
              ),
              IconButton(
                tooltip: l.note,
                icon: Icon(hasNote ? Icons.sticky_note_2 : Icons.sticky_note_2_outlined, color: hasNote ? scheme.secondary : null),
                onPressed: () => _tabs.animateTo(VerseTab.note.index),
              ),
              IconButton(tooltip: l.memorizeFromHere, icon: const Icon(Icons.psychology_outlined), onPressed: () {
                Navigator.of(context).maybePop();
                context.push('/memorize/${_ayah.surah}?from=${_ayah.numberInSurah}');
              }),
              IconButton(tooltip: l.reciteFromHere, icon: const Icon(Icons.mic_none), onPressed: () {
                Navigator.of(context).maybePop();
                context.push('/recite/${_ayah.surah}?from=${_ayah.numberInSurah}&auto=1');
              }),
              IconButton(tooltip: l.downloadAyahAudio, icon: const Icon(Icons.download_outlined), onPressed: () => downloadAyahAudio(context, ref, _ayah)),
              IconButton(tooltip: l.copy, icon: const Icon(Icons.copy_outlined), onPressed: () async {
                await Clipboard.setData(ClipboardData(text: composeAyahText(ref, _ayah)));
                if (context.mounted) ScaffoldMessenger.maybeOf(context)?.showSnackBar(SnackBar(content: Text(l.ayahCopied)));
              }),
              IconButton(tooltip: l.share, icon: const Icon(Icons.ios_share), onPressed: () => Share.share(composeAyahText(ref, _ayah), subject: 'Quran ${_ayah.key}')),
            ],
          ),
        ),
        TabBar(
          controller: _tabs,
          tabs: [
            Tab(text: l.translation),
            Tab(text: l.tafsir),
            Tab(text: l.wordByWord),
            Tab(text: l.note),
          ],
        ),
        Expanded(
          child: TabBarView(
            controller: _tabs,
            children: [
              _TranslationTab(ayah: _ayah, controller: widget.scrollController),
              _TafsirTab(ayah: _ayah, controller: widget.scrollController),
              _WordsTab(ayah: _ayah, controller: widget.scrollController),
              _NoteTab(ayah: _ayah, note: _note, controller: widget.scrollController),
            ],
          ),
        ),
      ],
    );
  }
}

class _TranslationTab extends ConsumerWidget {
  const _TranslationTab({required this.ayah, this.controller});
  final Ayah ayah;
  final ScrollController? controller;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = context.l10n;
    final repo = ref.quran;
    final settings = ref.watch(settingsProvider);
    final scheme = Theme.of(context).colorScheme;
    return ListView(
      controller: controller,
      padding: const EdgeInsets.all(20),
      children: [
        if (settings.showTransliteration) ...[
          Text(repo.transliterationOf(ayah.number), style: TextStyle(fontStyle: FontStyle.italic, color: scheme.primary, height: 1.5)),
          const SizedBox(height: 12),
        ],
        if (settings.translations.isEmpty)
          TextButton.icon(onPressed: () => context.push('/settings/translations'), icon: const Icon(Icons.translate), label: Text(l.translations)),
        for (final id in settings.translations) ...[
          Builder(builder: (context) {
            final ed = repo.edition(id);
            final rtl = ed?.isRtl ?? false;
            final v = ref.watch(surahTranslationProvider((surah: ayah.surah, edition: id)));
            return Padding(
              padding: const EdgeInsets.only(bottom: 14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text((ed?.englishName ?? id).toUpperCase(),
                      style: TextStyle(fontSize: 10.5, letterSpacing: 1.2, fontWeight: FontWeight.w700, color: scheme.onSurfaceVariant)),
                  const SizedBox(height: 4),
                  v.when(
                    data: (list) => Text(
                      list[ayah.numberInSurah - 1],
                      textDirection: rtl ? TextDirection.rtl : TextDirection.ltr,
                      textAlign: rtl ? TextAlign.right : TextAlign.left,
                      style: TextStyle(fontSize: (rtl ? 18 : 15.5) * settings.translationScale, height: rtl ? 1.9 : 1.55, fontFamily: rtl ? ArabicStyles.nameFont : null),
                    ),
                    loading: () => const LinearProgressIndicator(minHeight: 2),
                    error: (e, _) => Text(l.couldNotLoad(ed?.englishName ?? id), style: TextStyle(color: scheme.error)),
                  ),
                ],
              ),
            );
          }),
        ],
        TextButton.icon(
          onPressed: () => context.push('/settings/translations'),
          icon: const Icon(Icons.add),
          label: Text(l.translations),
        ),
      ],
    );
  }
}

class _TafsirTab extends ConsumerWidget {
  const _TafsirTab({required this.ayah, this.controller});
  final Ayah ayah;
  final ScrollController? controller;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = context.l10n;
    final settings = ref.watch(settingsProvider);
    final source = tafsirById(settings.tafsirId);
    final text = ref.watch(tafsirProvider((id: source.id, key: ayah.key)));
    final scheme = Theme.of(context).colorScheme;
    return ListView(
      controller: controller,
      padding: const EdgeInsets.all(20),
      children: [
        const Align(alignment: AlignmentDirectional.centerEnd, child: TafsirDropdown()),
        const SizedBox(height: 8),
        text.when(
          data: (t) => TafsirText(text: t, rtl: source.isRtl, scale: settings.translationScale),
          loading: () => const Padding(padding: EdgeInsets.all(24), child: Center(child: CircularProgressIndicator())),
          error: (e, _) => Column(children: [
            Text('${l.tafsirNeedsInternet}\n$e', textAlign: TextAlign.center),
            const SizedBox(height: 8),
            FilledButton.tonal(onPressed: () => ref.invalidate(tafsirProvider((id: source.id, key: ayah.key))), child: Text(l.retry)),
          ]),
        ),
        const SizedBox(height: 10),
        Text('${source.name} · ${source.author} · ${languageName(source.language)} · ${l.viaQuranCom}',
            style: TextStyle(fontSize: 11.5, color: scheme.outline)),
      ],
    );
  }
}

class _WordsTab extends ConsumerWidget {
  const _WordsTab({required this.ayah, this.controller});
  final Ayah ayah;
  final ScrollController? controller;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = context.l10n;
    final settings = ref.watch(settingsProvider);
    final words = ref.watch(surahWordsProvider((surah: ayah.surah, lang: settings.wordLanguage)));
    final scheme = Theme.of(context).colorScheme;
    return ListView(
      controller: controller,
      padding: const EdgeInsets.all(20),
      children: [
        Align(
          alignment: AlignmentDirectional.centerEnd,
          child: DropdownButton<String>(
            value: wordByWordLanguages.containsKey(settings.wordLanguage) ? settings.wordLanguage : 'en',
            underline: const SizedBox.shrink(),
            items: [for (final e in wordByWordLanguages.entries) DropdownMenuItem(value: e.key, child: Text(e.value))],
            onChanged: (v) {
              if (v != null) ref.read(settingsProvider.notifier).setWordLanguage(v);
            },
          ),
        ),
        const SizedBox(height: 8),
        words.when(
          data: (all) => WordByWordView(words: all[ayah.numberInSurah - 1], scale: settings.arabicScale, font: settings.arabicFont),
          loading: () => const Padding(padding: EdgeInsets.all(24), child: Center(child: CircularProgressIndicator())),
          error: (e, _) => Column(children: [
            Text('${l.wordByWordNeedsInternet}\n$e', textAlign: TextAlign.center, style: TextStyle(color: scheme.error)),
            const SizedBox(height: 8),
            FilledButton.tonal(
              onPressed: () => ref.invalidate(surahWordsProvider((surah: ayah.surah, lang: settings.wordLanguage))),
              child: Text(l.retry),
            ),
          ]),
        ),
      ],
    );
  }
}

class _NoteTab extends ConsumerWidget {
  const _NoteTab({required this.ayah, required this.note, this.controller});
  final Ayah ayah;
  final TextEditingController note;
  final ScrollController? controller;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = context.l10n;
    final scheme = Theme.of(context).colorScheme;
    return ListView(
      controller: controller,
      padding: const EdgeInsets.all(20),
      children: [
        TextField(
          controller: note,
          minLines: 5,
          maxLines: 12,
          decoration: InputDecoration(hintText: l.noteHint, alignLabelWithHint: true),
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            FilledButton.icon(
              onPressed: () {
                ref.read(notesProvider.notifier).set(ayah.number, note.text);
                ScaffoldMessenger.maybeOf(context)?.showSnackBar(SnackBar(content: Text(l.noteSaved)));
              },
              icon: const Icon(Icons.save_outlined),
              label: Text(l.save),
            ),
            const SizedBox(width: 8),
            TextButton(
              onPressed: () {
                note.clear();
                ref.read(notesProvider.notifier).set(ayah.number, '');
              },
              child: Text(l.clear),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Text(l.noteHelp, style: TextStyle(fontSize: 12.5, color: scheme.onSurfaceVariant, height: 1.4)),
      ],
    );
  }
}
