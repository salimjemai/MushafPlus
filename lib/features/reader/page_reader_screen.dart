import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/arabic_utils.dart';
import '../../core/theme.dart';
import '../../data/models.dart';
import '../../data/quran_repository.dart';
import '../../state/audio_controller.dart';
import '../../state/providers.dart';
import '../../widgets/mini_player.dart';
import '../../widgets/surah_number_badge.dart';
import 'ayah_actions.dart';
import 'mushaf_view.dart';
import 'reader_settings_sheet.dart';

/// Reads the Quran by its 604 printed Mushaf pages.
class PageReaderScreen extends ConsumerStatefulWidget {
  const PageReaderScreen({super.key, required this.page});
  final int page;

  @override
  ConsumerState<PageReaderScreen> createState() => _PageReaderScreenState();
}

class _PageReaderScreenState extends ConsumerState<PageReaderScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final first = ref.quran.ayahsOfPage(widget.page).first;
      ref.read(lastReadProvider.notifier).set(first.number);
    });
  }

  @override
  Widget build(BuildContext context) {
    final repo = ref.quran;
    final page = widget.page;
    final ayahs = repo.ayahsOfPage(page);
    final scheme = Theme.of(context).colorScheme;

    // Group the page's ayahs by surah so surah openings get a header.
    final groups = <List<Ayah>>[];
    for (final a in ayahs) {
      if (groups.isEmpty || groups.last.first.surah != a.surah) {
        groups.add([a]);
      } else {
        groups.last.add(a);
      }
    }
    final surahNames = groups.map((g) => repo.surah(g.first.surah).englishName).join(' · ');

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.canPop() ? context.pop() : context.go('/'),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Page $page'),
            Text(
              'Juz ${ayahs.first.juz} · $surahNames',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: scheme.onSurfaceVariant),
            ),
          ],
        ),
        actions: [
          IconButton(
            tooltip: 'Play this page',
            icon: const Icon(Icons.play_circle_outline),
            onPressed: () => ref
                .read(audioProvider.notifier)
                .playAyah(ayahs.first.number, until: ayahs.last.number),
          ),
          IconButton(
            tooltip: 'Go to page',
            icon: const Icon(Icons.numbers),
            onPressed: () => _goToPage(context),
          ),
          IconButton(
            tooltip: 'Reading settings',
            icon: const Icon(Icons.text_fields),
            onPressed: () => showReaderSettings(context),
          ),
        ],
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 860),
          child: SingleChildScrollView(
            key: ValueKey('page-$page'),
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
            child: Card(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    for (final g in groups) ...[
                      if (g.first.numberInSurah == 1)
                        _SurahBanner(surah: repo.surah(g.first.surah)),
                      MushafText(
                        key: ValueKey('p$page-s${g.first.surah}'),
                        ayahs: g,
                        onAyahTap: (a) => showAyahActions(context, ref, a),
                      ),
                      const SizedBox(height: 8),
                    ],
                    const SizedBox(height: 8),
                    Center(
                      child: Text(
                        toArabicDigits(page),
                        style: ArabicStyles.surahName(context, size: 18, color: scheme.secondary),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
      bottomNavigationBar: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const MiniPlayer(showLocation: false),
          Material(
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
                      child: page > 1
                          ? TextButton.icon(
                              onPressed: () => context.go('/page/${page - 1}'),
                              icon: const Icon(Icons.chevron_left),
                              label: Text('Page ${page - 1}'),
                            )
                          : const SizedBox.shrink(),
                    ),
                    TextButton(
                      onPressed: () => _goToPage(context),
                      child: Text('$page / ${QuranRepository.totalPages}'),
                    ),
                    Expanded(
                      child: page < QuranRepository.totalPages
                          ? Directionality(
                              textDirection: TextDirection.rtl,
                              child: TextButton.icon(
                                onPressed: () => context.go('/page/${page + 1}'),
                                icon: const Icon(Icons.chevron_left),
                                label: Text('Page ${page + 1}'),
                              ),
                            )
                          : const SizedBox.shrink(),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _goToPage(BuildContext context) async {
    final result = await showDialog<int>(
      context: context,
      builder: (context) => _GoToPageDialog(current: widget.page),
    );
    if (result != null && context.mounted) context.go('/page/$result');
  }
}

class _SurahBanner extends StatelessWidget {
  const _SurahBanner({required this.surah});
  final Surah surah;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12, top: 4),
      child: PatternPanel(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        borderRadius: const BorderRadius.all(Radius.circular(16)),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SurahNumberBadge(number: surah.number, size: 32, color: AppColors.goldLight, textColor: Colors.white),
                const SizedBox(width: 12),
                Text(surah.name, style: ArabicStyles.surahName(context, size: 26, color: Colors.white)),
              ],
            ),
            if (surah.hasBismillahHeader)
              Text(
                bismillah,
                textDirection: TextDirection.rtl,
                style: const TextStyle(
                  fontFamily: ArabicStyles.quranFont,
                  fontSize: 24,
                  color: AppColors.goldLight,
                  height: 1.8,
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _GoToPageDialog extends StatefulWidget {
  const _GoToPageDialog({required this.current});
  final int current;

  @override
  State<_GoToPageDialog> createState() => _GoToPageDialogState();
}

class _GoToPageDialogState extends State<_GoToPageDialog> {
  late double _value = widget.current.toDouble();
  late final _controller = TextEditingController(text: '${widget.current}');

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Go to page'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: _controller,
            keyboardType: TextInputType.number,
            autofocus: true,
            decoration: const InputDecoration(labelText: 'Page (1–604)'),
            onChanged: (v) {
              final n = int.tryParse(v);
              if (n != null && n >= 1 && n <= QuranRepository.totalPages) {
                setState(() => _value = n.toDouble());
              }
            },
            onSubmitted: (_) => _submit(),
          ),
          Slider(
            value: _value,
            min: 1,
            max: QuranRepository.totalPages.toDouble(),
            divisions: QuranRepository.totalPages - 1,
            label: '${_value.round()}',
            onChanged: (v) => setState(() {
              _value = v;
              _controller.text = '${v.round()}';
            }),
          ),
        ],
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
        FilledButton(onPressed: _submit, child: const Text('Open')),
      ],
    );
  }

  void _submit() {
    final n = int.tryParse(_controller.text) ?? _value.round();
    Navigator.pop(context, n.clamp(1, QuranRepository.totalPages));
  }
}
