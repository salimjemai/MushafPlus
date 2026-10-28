import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/l10n.dart';
import '../../core/recitation_matcher.dart';
import '../../core/theme.dart';
import '../../data/feedback_tone.dart';
import '../../data/models.dart';
import '../../data/speech_engine.dart';
import '../../data/storage.dart';
import '../../state/providers.dart';
import 'watch_app.dart';

/// "Recite & check" on the wrist: pick a surah, tap the microphone and recite
/// from memory. The watch listens with the same engine and matcher as the
/// phone's recite screen, shows the current ayah with each word coloured as
/// it is heard, and buzzes the moment a word is wrong, so an imam leading
/// the prayer gets a silent correction without looking at a phone.
class WatchRecitePage extends ConsumerStatefulWidget {
  const WatchRecitePage({super.key});

  @override
  ConsumerState<WatchRecitePage> createState() => _WatchRecitePageState();
}

class _WatchRecitePageState extends ConsumerState<WatchRecitePage> {
  static const _surahKey = 'watchReciteSurah';

  final _engine = createSpeechEngine();
  bool _available = false;
  bool _initialised = false;
  bool _active = false;
  bool _engineListening = false;
  String _sessionBase = '';
  String _committed = '';
  String _partial = '';
  String? _error;
  String _localeId = 'ar-SA';
  Timer? _restart;
  final _flaggedWrong = <int>{};
  bool _celebrated = false;

  late int _surah;
  late List<Ayah> _ayahs;
  late List<int> _wordAyah;
  late RecitationMatcher _matcher;
  MatchResult? _result;

  @override
  void initState() {
    super.initState();
    final repo = ref.read(repositoryProvider).requireValue;
    final lastRead = ref.read(lastReadProvider);
    final stored = Storage.settings.get(_surahKey) as int?;
    _surah = (stored ?? (lastRead != null ? repo.ayah(lastRead.ayahNumber).surah : 1)).clamp(1, 114);
    _buildPassage();
  }

  void _buildPassage() {
    final repo = ref.read(repositoryProvider).requireValue;
    _ayahs = repo.ayahsOfSurah(_surah);
    final words = <String>[];
    _wordAyah = [];
    for (var i = 0; i < _ayahs.length; i++) {
      for (final w in _ayahs[i].text.split(' ')) {
        if (tokenize(w).isEmpty) continue;
        words.add(w);
        _wordAyah.add(i);
      }
    }
    _matcher = RecitationMatcher(words, strict: true);
    _sessionBase = '';
    _committed = '';
    _partial = '';
    _flaggedWrong.clear();
    _celebrated = false;
    _result = _matcher.match('');
  }

  @override
  void dispose() {
    _restart?.cancel();
    _active = false;
    _engine.stop();
    super.dispose();
  }

  // ---- speech (same loop as the phone's recite screen) ----------------------

  Future<bool> _init() async {
    if (_initialised) return _available;
    _initialised = true;
    try {
      _available = await _engine.init();
      if (_available) _localeId = await _engine.arabicLocale();
      if (!_available) _error = 'speech_not_supported';
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
      if (mounted && _active && !_engine.isListening) _listen();
    });
  }

  Future<void> _listen() async {
    _sessionBase = _committed;
    try {
      await _engine.start(
        locale: _localeId,
        onText: _onText,
        onEnd: () {
          if (!mounted) return;
          setState(() {
            _engineListening = false;
            if (_partial.isNotEmpty) {
              _committed = '$_committed $_partial'.trim();
              _partial = '';
            }
            _sessionBase = _committed;
          });
          if (_active) _scheduleRestart();
        },
        onError: (message, permanent) {
          if (!mounted) return;
          if (permanent) {
            setState(() {
              _error = message;
              _active = false;
              _engineListening = false;
            });
          }
        },
      );
      if (mounted) setState(() => _engineListening = true);
    } catch (e) {
      if (mounted) setState(() => _error = '$e');
    }
  }

  void _onText(String finalText, String partialText) {
    if (!mounted) return;
    setState(() {
      _engineListening = true;
      _committed = '$_sessionBase $finalText'.trim();
      _partial = partialText;
      _result = _matcher.match('$_committed $_partial');
    });
    _giveFeedback(_result!, finalText.isNotEmpty && partialText.isEmpty);
  }

  void _giveFeedback(MatchResult r, bool isFinal) {
    for (var i = 0; i < r.words.length; i++) {
      final w = r.words[i];
      if (w.status != WordStatus.wrong || _flaggedWrong.contains(i)) continue;
      if (isFinal || i < r.nextIndex - 1) {
        _flaggedWrong.add(i);
        FeedbackTone.wrong();
      }
    }
    if (r.complete && !_celebrated) {
      _celebrated = true;
      FeedbackTone.success();
    }
  }

  Future<void> _toggle() async {
    if (_active) {
      _active = false;
      _restart?.cancel();
      await _engine.stop();
      if (mounted) setState(() => _engineListening = false);
      return;
    }
    FeedbackTone.unlock();
    final ok = await _init();
    if (!ok) return;
    setState(() {
      _active = true;
      _error = null;
      _buildPassage();
    });
    await _listen();
  }

  Future<void> _pickSurah() async {
    if (_active) await _toggle();
    if (!mounted) return;
    final repo = ref.read(repositoryProvider).requireValue;
    final picked = await Navigator.of(context).push<int>(
      MaterialPageRoute(builder: (_) => _SurahPicker(surahs: repo.surahs, current: _surah)),
    );
    if (picked == null || !mounted) return;
    setState(() {
      _surah = picked;
      _buildPassage();
    });
    Storage.settings.put(_surahKey, picked);
  }

  // ---- UI ----------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final scheme = Theme.of(context).colorScheme;
    final repo = ref.quran;
    final surah = repo.surah(_surah);
    final insets = watchInsets(context, ref);
    final r = _result!;
    final cursorAyah = r.nextIndex < _wordAyah.length ? _wordAyah[r.nextIndex] : _ayahs.length - 1;

    if (!_active) {
      return Padding(
        padding: insets,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(l.reciteAndCheck, style: TextStyle(fontSize: 10, color: scheme.onSurfaceVariant)),
            InkWell(
              onTap: _pickSurah,
              borderRadius: BorderRadius.circular(8),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Flexible(
                      child: Text(
                        surah.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: ArabicStyles.surahName(context, size: 15, color: scheme.primary),
                      ),
                    ),
                    Icon(Icons.unfold_more, size: 14, color: scheme.onSurfaceVariant),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 4),
            SizedBox(
              width: 56,
              height: 56,
              child: FilledButton(
                style: FilledButton.styleFrom(shape: const CircleBorder(), padding: EdgeInsets.zero),
                onPressed: _toggle,
                child: const Icon(Icons.mic, size: 28),
              ),
            ),
            const SizedBox(height: 4),
            if (_error != null)
              Text(
                _error == 'speech_not_supported' ? l.speechUnavailable : l.micDenied,
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 8, color: scheme.error),
              )
            else if (r.reached > 0)
              Text('${r.matched}/${r.reached} · ${r.wrong} ✗', style: TextStyle(fontSize: 10, color: scheme.onSurfaceVariant))
            else
              Text(l.tapMicToStart, maxLines: 2, textAlign: TextAlign.center, style: TextStyle(fontSize: 8, color: scheme.outline)),
          ],
        ),
      );
    }

    final ayah = _ayahs[cursorAyah];
    final firstWord = _wordAyah.indexOf(cursorAyah);
    final spans = <InlineSpan>[];
    for (var i = firstWord; i < r.words.length && _wordAyah[i] == cursorAyah; i++) {
      final w = r.words[i];
      final color = switch (w.status) {
        WordStatus.matched => Colors.greenAccent,
        WordStatus.wrong => Colors.redAccent,
        WordStatus.missed => Colors.orangeAccent,
        WordStatus.pending => i == r.nextIndex ? AppColors.gold : scheme.onSurface,
      };
      spans.add(TextSpan(
        text: '${w.original} ',
        style: TextStyle(color: color, fontWeight: i == r.nextIndex ? FontWeight.w700 : FontWeight.w400),
      ));
    }

    return Padding(
      padding: insets,
      child: Column(
        children: [
          Row(
            children: [
              Icon(_engineListening ? Icons.mic : Icons.hourglass_top, size: 12, color: _engineListening ? scheme.primary : scheme.onSurfaceVariant),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  '${surah.englishName} ${ayah.key}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(fontSize: 10, color: scheme.onSurfaceVariant),
                ),
              ),
              Text('${r.wrong} ✗', style: TextStyle(fontSize: 10, color: r.wrong > 0 ? Colors.redAccent : scheme.onSurfaceVariant)),
            ],
          ),
          Expanded(
            child: SingleChildScrollView(
              child: RichText(
                textDirection: TextDirection.rtl,
                textAlign: TextAlign.center,
                text: TextSpan(
                  style: ArabicStyles.ayah(context, scale: 0.5).copyWith(height: 1.8),
                  children: spans,
                ),
              ),
            ),
          ),
          SizedBox(
            height: 30,
            child: FilledButton.tonalIcon(
              style: FilledButton.styleFrom(padding: const EdgeInsets.symmetric(horizontal: 10), textStyle: const TextStyle(fontSize: 10)),
              onPressed: _toggle,
              icon: const Icon(Icons.stop, size: 14),
              label: Text(l.stop),
            ),
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }
}

class _SurahPicker extends StatelessWidget {
  const _SurahPicker({required this.surahs, required this.current});
  final List<Surah> surahs;
  final int current;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Scaffold(
      body: ListView.builder(
        padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 12),
        itemCount: surahs.length,
        itemExtent: 34,
        itemBuilder: (context, i) {
          final s = surahs[i];
          final selected = s.number == current;
          return InkWell(
            onTap: () => Navigator.of(context).pop(s.number),
            child: Row(
              children: [
                SizedBox(width: 22, child: Text('${s.number}', style: TextStyle(fontSize: 10, color: scheme.onSurfaceVariant))),
                Expanded(
                  child: Text(
                    s.name,
                    textDirection: TextDirection.rtl,
                    textAlign: TextAlign.left,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: ArabicStyles.surahName(context, size: 13, color: selected ? scheme.primary : null),
                  ),
                ),
                if (selected) Icon(Icons.check, size: 14, color: scheme.primary),
              ],
            ),
          );
        },
      ),
    );
  }
}
