import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:speech_to_text/speech_recognition_error.dart';
import 'package:speech_to_text/speech_recognition_result.dart';
import 'package:speech_to_text/speech_to_text.dart';

import '../../core/arabic_utils.dart';
import '../../core/l10n.dart';
import '../../core/recitation_matcher.dart';
import '../../core/theme.dart';
import '../../data/models.dart';
import '../../state/audio_controller.dart';
import '../../state/providers.dart';
import '../../widgets/mini_player.dart';
import '../plan/plan_screen.dart';

/// Listens to the user reciting a passage from memory and checks it word by
/// word against the Uthmani text: matched words turn green, wrong words
/// orange (with what was heard), skipped words red.
class ReciteScreen extends ConsumerStatefulWidget {
  const ReciteScreen({super.key, required this.surah, this.from, this.to});
  final int surah;
  final int? from;
  final int? to;

  @override
  ConsumerState<ReciteScreen> createState() => _ReciteScreenState();
}

class _ReciteScreenState extends ConsumerState<ReciteScreen> {
  final _speech = SpeechToText();
  bool _available = false;
  bool _initialised = false;
  bool _active = false; // user wants to be listening
  bool _engineListening = false;
  String _committed = '';
  String _partial = '';
  double _level = 0;
  String? _error;
  String? _localeId;
  Timer? _restart;

  late int _from;
  late int _to;
  late List<Ayah> _ayahs;
  late List<int> _wordAyah; // expected word index -> ayah index within range
  late RecitationMatcher _matcher;
  MatchResult? _result;
  bool _hideText = true;
  int _hintUntil = -1; // reveal words up to this index when hidden

  @override
  void initState() {
    super.initState();
    final s = ref.read(repositoryProvider).requireValue.surah(widget.surah);
    _from = (widget.from ?? 1).clamp(1, s.numberOfAyahs);
    _to = (widget.to ?? (_from + 4)).clamp(_from, s.numberOfAyahs);
    _buildPassage();
  }

  void _buildPassage() {
    final repo = ref.read(repositoryProvider).requireValue;
    _ayahs = [for (var n = _from; n <= _to; n++) repo.ayahAt(widget.surah, n)];
    final words = <String>[];
    _wordAyah = [];
    for (var i = 0; i < _ayahs.length; i++) {
      for (final w in _ayahs[i].text.split(' ')) {
        if (tokenize(w).isEmpty) continue;
        words.add(w);
        _wordAyah.add(i);
      }
    }
    _matcher = RecitationMatcher(words);
    _result = _matcher.match('');
    _committed = '';
    _partial = '';
    _hintUntil = -1;
  }

  @override
  void dispose() {
    _restart?.cancel();
    _active = false;
    _speech.stop();
    super.dispose();
  }

  // ---- speech ------------------------------------------------------------

  Future<bool> _init() async {
    if (_initialised) return _available;
    _initialised = true;
    try {
      _available = await _speech.initialize(
        onError: (SpeechRecognitionError e) {
          if (!mounted) return;
          setState(() {
            _engineListening = false;
            if (e.permanent) _error = e.errorMsg;
          });
          if (_active && !e.permanent) _scheduleRestart();
        },
        onStatus: (status) {
          if (!mounted) return;
          final listening = status == 'listening';
          setState(() => _engineListening = listening);
          if (!listening && _active) _scheduleRestart();
        },
      );
      if (_available) {
        final locales = await _speech.locales();
        final ar = locales.where((l) => l.localeId.toLowerCase().startsWith('ar'));
        _localeId = ar.where((l) => l.localeId.toLowerCase().contains('sa')).firstOrNull?.localeId ??
            ar.firstOrNull?.localeId ??
            'ar-SA';
      }
    } catch (e) {
      _available = false;
      _error = '$e';
    }
    if (mounted) setState(() {});
    return _available;
  }

  void _scheduleRestart() {
    _restart?.cancel();
    _restart = Timer(const Duration(milliseconds: 400), () {
      if (mounted && _active && !_speech.isListening) _listen();
    });
  }

  Future<void> _listen() async {
    try {
      await _speech.listen(
        onResult: _onResult,
        onSoundLevelChange: (level) {
          if (mounted) setState(() => _level = level);
        },
        listenOptions: SpeechListenOptions(
          localeId: _localeId,
          partialResults: true,
          listenMode: ListenMode.dictation,
          cancelOnError: false,
          pauseFor: const Duration(seconds: 6),
          listenFor: const Duration(minutes: 10),
        ),
      );
    } catch (e) {
      if (mounted) setState(() => _error = '$e');
    }
  }

  void _onResult(SpeechRecognitionResult r) {
    if (!mounted) return;
    setState(() {
      if (r.finalResult) {
        _committed = '$_committed ${r.recognizedWords}'.trim();
        _partial = '';
      } else {
        _partial = r.recognizedWords;
      }
      _result = _matcher.match('$_committed $_partial');
    });
  }

  Future<void> _toggle() async {
    if (_active) {
      _active = false;
      _restart?.cancel();
      await _speech.stop();
      if (mounted) setState(() => _engineListening = false);
      return;
    }
    final ok = await _init();
    if (!ok) return;
    setState(() {
      _active = true;
      _error = null;
    });
    await _listen();
  }

  void _reset() {
    setState(() {
      _committed = '';
      _partial = '';
      _hintUntil = -1;
      _result = _matcher.match('');
    });
  }

  // ---- UI ----------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final repo = ref.quran;
    final surah = repo.surah(widget.surah);
    final settings = ref.watch(settingsProvider);
    final scheme = Theme.of(context).colorScheme;
    final r = _result!;
    final cursorAyah = r.nextIndex < _wordAyah.length ? _wordAyah[r.nextIndex] : _ayahs.length - 1;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.canPop() ? context.pop() : context.go('/surah/${widget.surah}'),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(l.reciteAndCheck),
            Text('${surah.englishName} · ${l.ayahRangeLabel(_from, _to)}',
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: scheme.onSurfaceVariant)),
          ],
        ),
        actions: [
          IconButton(
            tooltip: _hideText ? l.showText : l.hideText,
            icon: Icon(_hideText ? Icons.visibility_outlined : Icons.visibility_off_outlined),
            onPressed: () => setState(() => _hideText = !_hideText),
          ),
          IconButton(tooltip: l.changeRange, icon: const Icon(Icons.tune), onPressed: () => _pickRange(surah)),
        ],
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 820),
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              // ---- score ------------------------------------------------------
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      GoalRing(
                        progress: r.reached == 0 ? 0 : r.accuracy,
                        label: r.reached == 0 ? '—' : '${(r.accuracy * 100).round()}%',
                        sublabel: l.accuracy,
                        size: 84,
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Wrap(
                              spacing: 8,
                              runSpacing: 6,
                              children: [
                                _Stat(color: Colors.green, label: l.matchedWords, value: r.matched),
                                _Stat(color: Colors.orange, label: l.wrongWords, value: r.wrong),
                                _Stat(color: scheme.error, label: l.missedWords, value: r.missed),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Text(l.wordsReached(r.reached, r.words.length),
                                style: TextStyle(fontSize: 13, color: scheme.onSurfaceVariant)),
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                Icon(
                                  _engineListening ? Icons.mic : (_active ? Icons.hourglass_top : Icons.mic_off),
                                  size: 16,
                                  color: _engineListening ? scheme.primary : scheme.onSurfaceVariant,
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  _engineListening ? l.listening : (_active ? l.waitingForSpeech : l.tapMicToStart),
                                  style: TextStyle(fontSize: 13, color: _engineListening ? scheme.primary : scheme.onSurfaceVariant),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              if (_error != null) ...[
                const SizedBox(height: 10),
                Card(
                  color: scheme.errorContainer,
                  child: Padding(
                    padding: const EdgeInsets.all(14),
                    child: Row(
                      children: [
                        Icon(Icons.mic_off, color: scheme.onErrorContainer),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text('${l.speechUnavailable}\n$_error',
                              style: TextStyle(color: scheme.onErrorContainer, fontSize: 13)),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
              const SizedBox(height: 12),

              // ---- passage ----------------------------------------------------
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(18),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      for (var a = 0; a < _ayahs.length; a++) ...[
                        _AyahWords(
                          ayah: _ayahs[a],
                          words: [
                            for (var i = 0; i < r.words.length; i++)
                              if (_wordAyah[i] == a) (index: i, match: r.words[i]),
                          ],
                          cursor: r.nextIndex,
                          hide: _hideText,
                          hintUntil: _hintUntil,
                          isCurrent: a == cursorAyah,
                          style: ArabicStyles.ayah(context, scale: settings.arabicScale * 0.9, font: settings.arabicFont),
                        ),
                        if (a < _ayahs.length - 1) Divider(color: scheme.outlineVariant.withValues(alpha: 0.4), height: 18),
                      ],
                      if (r.extras.isNotEmpty) ...[
                        const SizedBox(height: 10),
                        Text(l.notInPassage, style: TextStyle(fontSize: 11.5, color: scheme.onSurfaceVariant)),
                        const SizedBox(height: 4),
                        Wrap(
                          spacing: 6,
                          textDirection: TextDirection.rtl,
                          children: [
                            for (final e in r.extras.take(12))
                              Chip(label: Text(e), visualDensity: VisualDensity.compact, padding: EdgeInsets.zero),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 10),
              if (_committed.isNotEmpty || _partial.isNotEmpty)
                Text(
                  '${l.heard}: $_committed $_partial',
                  textDirection: TextDirection.rtl,
                  style: TextStyle(fontSize: 13, fontStyle: FontStyle.italic, color: scheme.onSurfaceVariant),
                ),
              const SizedBox(height: 16),

              // ---- controls ---------------------------------------------------
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  OutlinedButton.icon(onPressed: _reset, icon: const Icon(Icons.refresh), label: Text(l.reset)),
                  const SizedBox(width: 10),
                  _MicButton(active: _active, listening: _engineListening, level: _level, onTap: _toggle),
                  const SizedBox(width: 10),
                  OutlinedButton.icon(
                    onPressed: r.complete ? null : () => setState(() => _hintUntil = r.nextIndex),
                    icon: const Icon(Icons.lightbulb_outline),
                    label: Text(l.hint),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Center(
                child: TextButton.icon(
                  onPressed: () => ref.read(audioProvider.notifier).playAyah(
                        _ayahs[cursorAyah].number,
                        until: _ayahs[cursorAyah].number,
                      ),
                  icon: const Icon(Icons.play_circle_outline),
                  label: Text(l.playThisAyah),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                l.reciteHelp,
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 12, color: scheme.outline, height: 1.4),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: const MiniPlayer(showLocation: false),
    );
  }

  Future<void> _pickRange(Surah surah) async {
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
        _buildPassage();
      });
    }
  }
}

class _Stat extends StatelessWidget {
  const _Stat({required this.color, required this.label, required this.value});
  final Color color;
  final String label;
  final int value;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(width: 10, height: 10, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
        const SizedBox(width: 5),
        Text('$value $label', style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600)),
      ],
    );
  }
}

class _AyahWords extends StatelessWidget {
  const _AyahWords({
    required this.ayah,
    required this.words,
    required this.cursor,
    required this.hide,
    required this.hintUntil,
    required this.isCurrent,
    required this.style,
  });

  final Ayah ayah;
  final List<({int index, WordMatch match})> words;
  final int cursor;
  final bool hide;
  final int hintUntil;
  final bool isCurrent;
  final TextStyle style;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Wrap(
      textDirection: TextDirection.rtl,
      spacing: 6,
      runSpacing: 6,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        for (final w in words) _wordChip(context, w.index, w.match, scheme),
        Text(ayahEndMarker(ayah.numberInSurah),
            style: style.copyWith(fontFamily: ArabicStyles.nameFont, color: scheme.secondary)),
      ],
    );
  }

  Widget _wordChip(BuildContext context, int index, WordMatch m, ColorScheme scheme) {
    final revealed = !hide || m.status != WordStatus.pending || index <= hintUntil;
    Color? bg;
    Color fg = scheme.onSurface;
    TextDecoration? deco;
    switch (m.status) {
      case WordStatus.matched:
        bg = Colors.green.withValues(alpha: 0.18);
        fg = Colors.green.shade800;
      case WordStatus.wrong:
        bg = Colors.orange.withValues(alpha: 0.22);
        fg = Colors.orange.shade900;
      case WordStatus.missed:
        bg = scheme.error.withValues(alpha: 0.16);
        fg = scheme.error;
        deco = TextDecoration.lineThrough;
      case WordStatus.pending:
        bg = index == cursor ? scheme.primary.withValues(alpha: 0.12) : null;
    }
    final dark = Theme.of(context).brightness == Brightness.dark;
    if (dark && m.status == WordStatus.matched) fg = Colors.greenAccent.shade200;
    if (dark && m.status == WordStatus.wrong) fg = Colors.orangeAccent.shade200;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(8),
        border: index == cursor ? Border.all(color: scheme.primary, width: 1.2) : null,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            revealed ? m.original : '•••',
            textDirection: TextDirection.rtl,
            style: style.copyWith(color: revealed ? fg : scheme.onSurfaceVariant.withValues(alpha: 0.5), decoration: deco),
          ),
          if (m.status == WordStatus.wrong && m.heard != null)
            Text(m.heard!, textDirection: TextDirection.rtl, style: TextStyle(fontSize: 11, color: fg)),
        ],
      ),
    );
  }
}

class _MicButton extends StatelessWidget {
  const _MicButton({required this.active, required this.listening, required this.level, required this.onTap});
  final bool active;
  final bool listening;
  final double level; // roughly -2..10 (dB-ish) from the plugin
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final pulse = listening ? (0.15 + (level.clamp(-2, 10) + 2) / 12 * 0.5) : 0.0;
    return SizedBox(
      width: 96,
      height: 96,
      child: Stack(
        alignment: Alignment.center,
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 120),
            width: 64 + 32 * pulse,
            height: 64 + 32 * pulse,
            decoration: BoxDecoration(shape: BoxShape.circle, color: scheme.primary.withValues(alpha: 0.18 * (listening ? 1 : 0))),
          ),
          FloatingActionButton.large(
            heroTag: 'recite-mic',
            onPressed: onTap,
            backgroundColor: active ? scheme.error : scheme.primary,
            foregroundColor: Colors.white,
            child: Icon(active ? Icons.stop : Icons.mic, size: 36),
          ),
        ],
      ),
    );
  }
}
