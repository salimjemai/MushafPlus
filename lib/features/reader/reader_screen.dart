import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';

import '../../core/arabic_utils.dart';
import '../../core/l10n.dart';
import '../../core/theme.dart';
import '../../data/models.dart';
import '../../state/audio_controller.dart';
import '../../state/providers.dart';
import '../../widgets/mini_player.dart';
import '../../widgets/surah_number_badge.dart';
import '../home/surah_list_screen.dart';
import 'ayah_card.dart';
import 'reader_settings_sheet.dart';

class ReaderScreen extends ConsumerStatefulWidget {
  const ReaderScreen({super.key, required this.surahNumber, this.initialAyah});

  final int surahNumber;
  final int? initialAyah;

  @override
  ConsumerState<ReaderScreen> createState() => _ReaderScreenState();
}

class _ReaderScreenState extends ConsumerState<ReaderScreen> {
  final _itemScroll = ItemScrollController();
  final _positions = ItemPositionsListener.create();
  Timer? _throttle;
  int? _highlighted;

  @override
  void initState() {
    super.initState();
    _highlighted = widget.initialAyah;
    _positions.itemPositions.addListener(_onScroll);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final repo = ref.quran;
      final s = repo.surah(widget.surahNumber);
      final a = (widget.initialAyah ?? 1).clamp(1, s.numberOfAyahs);
      ref.read(lastReadProvider.notifier).set(s.startAyah + a - 1);
      if (_highlighted != null) {
        Future.delayed(const Duration(seconds: 3), () {
          if (mounted) setState(() => _highlighted = null);
        });
      }
    });
  }

  @override
  void dispose() {
    _positions.itemPositions.removeListener(_onScroll);
    _throttle?.cancel();
    super.dispose();
  }

  void _onScroll() {
    if (_throttle?.isActive ?? false) return;
    _throttle = Timer(const Duration(milliseconds: 800), () {
      if (!mounted) return;
      final positions = _positions.itemPositions.value;
      if (positions.isEmpty) return;
      // First item whose leading edge is on screen (index 0 is the header).
      final visible = positions.where((p) => p.itemTrailingEdge > 0.08).toList()
        ..sort((a, b) => a.index.compareTo(b.index));
      if (visible.isEmpty) return;
      final index = visible.first.index;
      if (index < 1) return;
      final s = ref.quran.surah(widget.surahNumber);
      ref.read(lastReadProvider.notifier).set(s.startAyah + index - 1);
    });
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final repo = ref.quran;
    final surah = repo.surah(widget.surahNumber);
    final ayahs = repo.ayahsOfSurah(surah.number);
    final settings = ref.watch(settingsProvider);

    // Follow the recitation: scroll to the ayah being played.
    ref.listen<int?>(audioProvider.select((a) => a.ayah), (prev, next) {
      if (next == null || next == prev) return;
      final a = repo.ayah(next);
      if (a.surah != surah.number || !_itemScroll.isAttached) return;
      _itemScroll.scrollTo(
        index: a.numberInSurah,
        alignment: 0.08,
        duration: const Duration(milliseconds: 450),
        curve: Curves.easeInOut,
      );
    });

    final translations = <TranslationSource>[
      for (final id in settings.translations)
        TranslationSource(
          id: id,
          edition: repo.edition(id),
          value: ref.watch(surahTranslationProvider((surah: surah.number, edition: id))),
        ),
    ];
    final words = settings.wordByWord
        ? ref.watch(surahWordsProvider((surah: surah.number, lang: settings.wordLanguage)))
        : null;

    final initialIndex = (widget.initialAyah ?? 0).clamp(0, surah.numberOfAyahs);

    final reader = Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          tooltip: l.back,
          onPressed: () => context.canPop() ? context.pop() : context.go('/'),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(surah.englishName),
            Text(
              l.surahSubtitle(surah.englishNameTranslation, surah.numberOfAyahs, revelationLabel(context, surah)),
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            tooltip: l.openMushafHere,
            icon: const Icon(Icons.auto_stories_outlined),
            onPressed: () => context.go('/mushaf?page=${surah.startPage}'),
          ),
          IconButton(
            tooltip: l.translations,
            icon: const Icon(Icons.translate),
            onPressed: () => context.push('/settings/translations'),
          ),
          IconButton(
            tooltip: l.readingSettings,
            icon: const Icon(Icons.text_fields),
            onPressed: () => showReaderSettings(context),
          ),
          PopupMenuButton<String>(
            tooltip: l.more,
            onSelected: (v) {
              switch (v) {
                case 'memorize':
                  context.go('/memorize/${surah.number}');
                case 'page':
                  context.go('/mushaf?page=${surah.startPage}');
                case 'play':
                  ref.read(audioProvider.notifier).playSurah(surah.number);
              }
            },
            itemBuilder: (context) => [
              PopupMenuItem(value: 'play', child: ListTile(leading: const Icon(Icons.play_arrow), title: Text(l.playSurah))),
              PopupMenuItem(value: 'memorize', child: ListTile(leading: const Icon(Icons.psychology_outlined), title: Text(l.memorizeThisSurah))),
              PopupMenuItem(value: 'page', child: ListTile(leading: const Icon(Icons.auto_stories), title: Text(l.openInMushaf))),
            ],
          ),
        ],
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 860),
          child: ScrollablePositionedList.builder(
                  key: ValueKey('list-${surah.number}'),
                  itemScrollController: _itemScroll,
                  itemPositionsListener: _positions,
                  initialScrollIndex: initialIndex,
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
                  itemCount: ayahs.length + 1,
                  itemBuilder: (context, i) {
                    if (i == 0) return SurahHeader(surah: surah);
                    final ayah = ayahs[i - 1];
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: AyahCard(
                        ayah: ayah,
                        transliteration: repo.transliterationOf(ayah.number),
                        translations: translations,
                        words: words,
                        highlighted: _highlighted == ayah.numberInSurah,
                      ),
                    );
                  },
                ),
        ),
      ),
      bottomNavigationBar: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const MiniPlayer(showLocation: false),
          _SurahNavBar(surah: surah),
        ],
      ),
    );

    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth < 1000) return reader;
        return Scaffold(
          body: Row(
            children: [
              SizedBox(width: 320, child: SurahSidebar(selected: surah.number)),
              const VerticalDivider(width: 1),
              Expanded(child: reader),
            ],
          ),
        );
      },
    );
  }
}

class SurahHeader extends ConsumerWidget {
  const SurahHeader({super.key, required this.surah});
  final Surah surah;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final playingThis = ref.watch(audioProvider.select((a) {
      final n = a.ayah;
      return a.playing && n != null && n >= surah.startAyah && n < surah.startAyah + surah.numberOfAyahs;
    }));
    return Padding(
      padding: const EdgeInsets.only(top: 4, bottom: 16),
      child: PatternPanel(
        padding: const EdgeInsets.symmetric(vertical: 22, horizontal: 20),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SurahNumberBadge(
                  number: surah.number,
                  size: 40,
                  color: AppColors.goldLight,
                  textColor: Colors.white,
                ),
                const SizedBox(width: 14),
                Text(
                  surah.name,
                  style: ArabicStyles.surahName(context, size: 34, color: Colors.white),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              '${surah.englishName} · ${surah.englishNameTranslation}',
              style: TextStyle(color: Colors.white.withValues(alpha: 0.85), fontSize: 13),
            ),
            if (surah.hasBismillahHeader) ...[
              const SizedBox(height: 14),
              Text(
                bismillah,
                textDirection: TextDirection.rtl,
                style: const TextStyle(
                  fontFamily: ArabicStyles.quranFont,
                  fontSize: 28,
                  color: AppColors.goldLight,
                  height: 1.8,
                ),
              ),
            ],
            const SizedBox(height: 12),
            FilledButton.tonalIcon(
              style: FilledButton.styleFrom(
                backgroundColor: Colors.white.withValues(alpha: 0.14),
                foregroundColor: Colors.white,
              ),
              onPressed: () {
                final ctrl = ref.read(audioProvider.notifier);
                playingThis ? ctrl.pause() : ctrl.playSurah(surah.number);
              },
              icon: Icon(playingThis ? Icons.pause : Icons.play_arrow),
              label: Text(playingThis ? context.l10n.pauseRecitation : context.l10n.playSurah),
            ),
          ],
        ),
      ),
    );
  }
}

class _SurahNavBar extends ConsumerWidget {
  const _SurahNavBar({required this.surah});
  final Surah surah;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final repo = ref.quran;
    final prev = surah.number > 1 ? repo.surah(surah.number - 1) : null;
    final next = surah.number < 114 ? repo.surah(surah.number + 1) : null;
    final scheme = Theme.of(context).colorScheme;
    return Material(
      color: scheme.surface,
      child: SafeArea(
        top: false,
        child: Container(
          height: 56,
          decoration: BoxDecoration(
            border: Border(top: BorderSide(color: scheme.outlineVariant.withValues(alpha: 0.5))),
          ),
          child: Row(
            children: [
              Expanded(
                child: prev == null
                    ? const SizedBox.shrink()
                    : TextButton.icon(
                        onPressed: () => context.go('/surah/${prev.number}'),
                        icon: const Icon(Icons.chevron_left),
                        label: Text(prev.englishName, overflow: TextOverflow.ellipsis),
                      ),
              ),
              TextButton(
                onPressed: () => context.go('/mushaf?page=${surah.startPage}'),
                child: Text(
                  context.l10n.juzPage(surah.startJuz, surah.startPage),
                  style: TextStyle(fontSize: 12, color: scheme.onSurfaceVariant),
                ),
              ),
              Expanded(
                child: next == null
                    ? const SizedBox.shrink()
                    : Directionality(
                        textDirection: TextDirection.rtl,
                        child: TextButton.icon(
                          onPressed: () => context.go('/surah/${next.number}'),
                          icon: const Icon(Icons.chevron_left),
                          label: Text(next.englishName, overflow: TextOverflow.ellipsis),
                        ),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
