import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/l10n.dart';
import '../../core/theme.dart';
import '../../data/models.dart';
import '../../data/translation_service.dart';
import '../../state/audio_controller.dart';
import '../../state/providers.dart';
import '../../widgets/mini_player.dart';
import '../../widgets/surah_number_badge.dart';

/// Memorisation trainer: hide the ayah and reveal it word by word, loop the
/// recitation of a range with each ayah repeated, and track what is memorised.
class MemorizeScreen extends ConsumerStatefulWidget {
  const MemorizeScreen({super.key, required this.surah, this.from, this.to});

  final int surah;
  final int? from;
  final int? to;

  @override
  ConsumerState<MemorizeScreen> createState() => _MemorizeScreenState();
}

class _MemorizeScreenState extends ConsumerState<MemorizeScreen> {
  late int _from;
  late int _to;
  late int _current; // numberInSurah
  int _revealed = 0; // words revealed of the current ayah
  bool _showTranslation = false;
  bool _showTransliteration = false;
  int _repeatEach = 3;
  bool _loop = true;

  @override
  void initState() {
    super.initState();
    final s = ref.quran.surah(widget.surah);
    _from = (widget.from ?? 1).clamp(1, s.numberOfAyahs);
    _to = (widget.to ?? s.numberOfAyahs).clamp(_from, s.numberOfAyahs);
    _current = _from;
  }

  List<String> _words(Ayah a) => a.text.split(' ').where((w) => w.isNotEmpty).toList();

  void _go(int n) => setState(() {
        _current = n.clamp(_from, _to);
        _revealed = 0;
      });

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final repo = ref.quran;
    final surah = repo.surah(widget.surah);
    final ayah = repo.ayahAt(surah.number, _current);
    final settings = ref.watch(settingsProvider);
    final memorized = ref.watch(memorizedProvider);
    final scheme = Theme.of(context).colorScheme;
    final words = _words(ayah);
    final isMemorized = memorized.contains(ayah.number);
    final rangeDone = [for (var n = _from; n <= _to; n++) repo.ayahAt(surah.number, n).number]
        .where(memorized.contains)
        .length;

    // Follow the audio while a range loops.
    ref.listen<int?>(audioProvider.select((a) => a.ayah), (prev, next) {
      if (next == null || next == prev) return;
      final a = repo.ayah(next);
      if (a.surah == surah.number && a.numberInSurah >= _from && a.numberInSurah <= _to) {
        _go(a.numberInSurah);
      }
    });

    final translation = ref.watch(surahTranslationProvider(
      (surah: surah.number, edition: settings.translations.firstOrNull ?? TranslationService.defaultEdition),
    ));

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.canPop() ? context.pop() : context.go('/surah/${surah.number}'),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(l.memorize),
            Text(
              l.memorizeHeader(surah.englishName, _from, _to, rangeDone, _to - _from + 1),
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: scheme.onSurfaceVariant),
            ),
          ],
        ),
        actions: [
          IconButton(
            tooltip: l.changeRange,
            icon: const Icon(Icons.tune),
            onPressed: () => _pickRange(context, surah),
          ),
        ],
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 760),
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              // ---- progress strip -----------------------------------------
              SizedBox(
                height: 40,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  children: [
                    for (var n = _from; n <= _to; n++)
                      Padding(
                        padding: const EdgeInsets.only(right: 6),
                        child: ChoiceChip(
                          label: Text('$n'),
                          selected: n == _current,
                          avatar: memorized.contains(repo.ayahAt(surah.number, n).number)
                              ? Icon(Icons.check, size: 14, color: scheme.primary)
                              : null,
                          onSelected: (_) => _go(n),
                        ),
                      ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // ---- the ayah with hidden words ----------------------------
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Row(
                        children: [
                          SurahNumberBadge(number: _current, size: 36),
                          const Spacer(),
                          Text(
                            l.wordsRevealed(_revealed, words.length),
                            style: TextStyle(fontSize: 12, color: scheme.onSurfaceVariant),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Wrap(
                        textDirection: TextDirection.rtl,
                        spacing: 8,
                        runSpacing: 10,
                        children: [
                          for (var i = 0; i < words.length; i++)
                            GestureDetector(
                              onTap: () => setState(() => _revealed = i + 1),
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 200),
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(
                                  color: i < _revealed
                                      ? Colors.transparent
                                      : scheme.primary.withValues(alpha: 0.12),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Text(
                                  words[i],
                                  textDirection: TextDirection.rtl,
                                  style: ArabicStyles.ayah(context,
                                          scale: settings.arabicScale, font: settings.arabicFont)
                                      .copyWith(
                                    color: i < _revealed ? scheme.onSurface : Colors.transparent,
                                  ),
                                ),
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 14),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          FilledButton.tonalIcon(
                            onPressed: _revealed < words.length
                                ? () => setState(() => _revealed++)
                                : null,
                            icon: const Icon(Icons.visibility_outlined, size: 18),
                            label: Text(l.nextWord),
                          ),
                          OutlinedButton(
                            onPressed: () => setState(() => _revealed = words.length),
                            child: Text(l.revealAll),
                          ),
                          OutlinedButton(
                            onPressed: () => setState(() => _revealed = 0),
                            child: Text(l.hideAll),
                          ),
                          FilterChip(
                            label: Text(l.transliteration),
                            selected: _showTransliteration,
                            onSelected: (v) => setState(() => _showTransliteration = v),
                          ),
                          FilterChip(
                            label: Text(l.translation),
                            selected: _showTranslation,
                            onSelected: (v) => setState(() => _showTranslation = v),
                          ),
                        ],
                      ),
                      if (_showTransliteration) ...[
                        const SizedBox(height: 12),
                        Text(
                          repo.transliterationOf(ayah.number),
                          style: TextStyle(fontStyle: FontStyle.italic, color: scheme.primary, height: 1.5),
                        ),
                      ],
                      if (_showTranslation) ...[
                        const SizedBox(height: 8),
                        translation.when(
                          data: (l) => Text(l[ayah.numberInSurah - 1], style: const TextStyle(height: 1.5)),
                          loading: () => const SizedBox(height: 16),
                          error: (_, __) => const SizedBox.shrink(),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 12),

              // ---- navigation + memorised toggle --------------------------
              Row(
                children: [
                  IconButton.outlined(
                    tooltip: l.previousAyah,
                    onPressed: _current > _from ? () => _go(_current - 1) : null,
                    icon: const Icon(Icons.chevron_left),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: FilledButton.icon(
                      style: FilledButton.styleFrom(
                        backgroundColor: isMemorized ? scheme.primary : scheme.surfaceContainerHighest,
                        foregroundColor: isMemorized ? scheme.onPrimary : scheme.onSurface,
                      ),
                      onPressed: () => ref.read(memorizedProvider.notifier).toggle(ayah.number),
                      icon: Icon(isMemorized ? Icons.check_circle : Icons.circle_outlined),
                      label: Text(isMemorized ? l.memorized : l.markAsMemorized),
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton.outlined(
                    tooltip: l.nextAyah,
                    onPressed: _current < _to ? () => _go(_current + 1) : null,
                    icon: const Icon(Icons.chevron_right),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // ---- audio drill --------------------------------------------
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.repeat, color: scheme.primary),
                          const SizedBox(width: 10),
                          Text(l.listenAndRepeat, style: const TextStyle(fontWeight: FontWeight.w700)),
                          const Spacer(),
                          const ReciterDropdown(),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          Text(l.repeatEachAyah),
                          const SizedBox(width: 12),
                          SegmentedButton<int>(
                            showSelectedIcon: false,
                            segments: const [
                              ButtonSegment(value: 1, label: Text('1×')),
                              ButtonSegment(value: 3, label: Text('3×')),
                              ButtonSegment(value: 5, label: Text('5×')),
                              ButtonSegment(value: 10, label: Text('10×')),
                            ],
                            selected: {_repeatEach},
                            onSelectionChanged: (v) => setState(() => _repeatEach = v.first),
                          ),
                        ],
                      ),
                      SwitchListTile(
                        contentPadding: EdgeInsets.zero,
                        title: Text(l.loopTheRange),
                        value: _loop,
                        onChanged: (v) => setState(() => _loop = v),
                      ),
                      Row(
                        children: [
                          FilledButton.icon(
                            onPressed: () => ref.read(audioProvider.notifier).playRange(
                                  repo.ayahAt(surah.number, _from).number,
                                  repo.ayahAt(surah.number, _to).number,
                                  repeatEach: _repeatEach,
                                  loop: _loop,
                                ),
                            icon: const Icon(Icons.play_arrow),
                            label: Text(l.playRange(_from, _to)),
                          ),
                          const SizedBox(width: 8),
                          OutlinedButton.icon(
                            onPressed: () => ref.read(audioProvider.notifier).playRange(
                                  ayah.number,
                                  ayah.number,
                                  repeatEach: _repeatEach,
                                  loop: _loop,
                                ),
                            icon: const Icon(Icons.replay),
                            label: Text(l.thisAyah),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: const MiniPlayer(showLocation: false),
    );
  }

  Future<void> _pickRange(BuildContext context, Surah surah) async {
    var from = _from;
    var to = _to;
    final ok = await showDialog<bool>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialog) => AlertDialog(
          title: Text(context.l10n.ayahRange),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(context.l10n.fromToOf(from, to, surah.numberOfAyahs)),
              RangeSlider(
                values: RangeValues(from.toDouble(), to.toDouble()),
                min: 1,
                max: surah.numberOfAyahs.toDouble(),
                divisions: surah.numberOfAyahs > 1 ? surah.numberOfAyahs - 1 : null,
                labels: RangeLabels('$from', '$to'),
                onChanged: (v) => setDialog(() {
                  from = v.start.round();
                  to = v.end.round();
                }),
              ),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context, false), child: Text(context.l10n.cancel)),
            FilledButton(onPressed: () => Navigator.pop(context, true), child: Text(context.l10n.apply)),
          ],
        ),
      ),
    );
    if (ok == true && mounted) {
      setState(() {
        _from = from;
        _to = to;
        _current = from;
        _revealed = 0;
      });
    }
  }
}
