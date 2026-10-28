import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/arabic_utils.dart';
import '../../core/l10n.dart';
import '../../core/recitation_matcher.dart';
import '../../core/theme.dart';
import '../../data/feedback_tone.dart';
import '../../data/models.dart';
import '../../data/speech_engine.dart';
import '../../state/audio_controller.dart';
import '../../state/providers.dart';
import '../../widgets/mini_player.dart';
import '../plan/plan_screen.dart';
import '../settings/settings_screen.dart' show showRecognitionEngineDialog;

/// Listens to the user reciting a passage from memory and checks it word by
/// word against the Uthmani text: matched words turn green, wrong words red
/// (with what was heard, a buzz and a vibration), skipped words orange.
class ReciteScreen extends ConsumerStatefulWidget {
  const ReciteScreen({super.key, required this.surah, this.from, this.to, this.autoStart = false});
  final int surah;
  final int? from;
  final int? to;

  /// Start listening as soon as the screen opens (where the platform allows
  /// starting without a tap on this screen).
  final bool autoStart;

  @override
  ConsumerState<ReciteScreen> createState() => _ReciteScreenState();
}

class _ReciteScreenState extends ConsumerState<ReciteScreen> {
  late SpeechEngine _engine;
  bool _voiceModel = false; // which engine _engine is
  bool _available = false;
  bool _initialised = false;
  bool _active = false; // user wants to be listening
  bool _engineListening = false;
  String _sessionBase = ''; // committed text from earlier sessions
  String _committed = '';
  String _partial = '';
  double _level = 0;
  String? _error; // permanent problem
  String? _notice; // transient engine message (no speech, network…)
  String _localeId = 'ar-SA';
  Timer? _restart;
  DateTime? _lastResultAt;
  final _flaggedWrong = <int>{};
  bool _celebrated = false;

  late int _from;
  late int _to;
  late List<Ayah> _ayahs;
  late List<int> _wordAyah; // expected word index -> ayah index within range
  late RecitationMatcher _matcher;
  MatchResult? _result;
  bool _hideText = true;
  bool _strict = true;
  int _hintUntil = -1; // reveal words up to this index when hidden

  @override
  void initState() {
    super.initState();
    if (kIsWeb && voiceModelCrashedLastTime()) {
      // The tab was killed last time while the voice model was loading or
      // listening (iPhone Safari does this when memory runs out). Do not
      // do it again on open: switch the setting back to the browser engine
      // and explain; the user can opt in again from Settings.
      ref.read(settingsProvider.notifier).setRecognitionEngine('browser');
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(context.l10n.voiceModelCrashed), duration: const Duration(seconds: 10)));
      });
    }
    _voiceModel = ref.read(settingsProvider).useVoiceModel;
    _engine = createSpeechEngine(voiceModel: _voiceModel);
    final s = ref.read(repositoryProvider).requireValue.surah(widget.surah);
    _from = (widget.from ?? 1).clamp(1, s.numberOfAyahs);
    // Default to the rest of the surah: reciters rarely stop after a few ayahs.
    _to = (widget.to ?? s.numberOfAyahs).clamp(_from, s.numberOfAyahs);
    _buildPassage();
    if (widget.autoStart) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        // WebKit (Safari, iPhone, iPad) only lets a tap on this page start
        // the microphone; elsewhere start right away.
        if (mounted && !(kIsWeb && _engine.shortSessions)) _toggle();
      });
    }
  }

  /// Replaces the engine when the recognition setting changes (the setting
  /// is edited from the app bar or the settings screen).
  Future<void> _useEngine(bool voiceModel) async {
    if (voiceModel == _voiceModel) return;
    final wasActive = _active;
    _active = false;
    _restart?.cancel();
    await _engine.stop();
    if (!mounted) return;
    setState(() {
      _voiceModel = voiceModel;
      _engine = createSpeechEngine(voiceModel: voiceModel);
      _initialised = false;
      _available = false;
      _engineListening = false;
      _error = null;
      _notice = null;
      _lastResultAt = null;
    });
    if (wasActive) await _toggle();
  }

  void _setStrict(bool v) {
    setState(() {
      _strict = v;
      _matcher = RecitationMatcher(_matcher.originalWords, strict: v, stops: _matcher.stops);
      _flaggedWrong.clear();
      _result = _matcher.match('$_committed $_partial');
    });
  }

  void _buildPassage({bool keepTranscript = false}) {
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
    _matcher = RecitationMatcher(words, strict: _strict, stops: RecitationMatcher.stopsOf(_ayahs.map((a) => a.text)));
    if (!keepTranscript) {
      _sessionBase = '';
      _committed = '';
      _partial = '';
      _flaggedWrong.clear();
    }
    _result = _matcher.match(keepTranscript ? '$_committed $_partial' : '');
    _hintUntil = -1;
    _celebrated = false;
  }

  @override
  void dispose() {
    _restart?.cancel();
    _active = false;
    _engine.stop();
    super.dispose();
  }

  // ---- speech ------------------------------------------------------------

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
    _restart = Timer(Duration(milliseconds: _engine.shortSessions ? 120 : 400), () {
      if (mounted && _active && !_engine.isListening) _listen();
    });
  }

  Future<void> _listen() async {
    _sessionBase = _committed;
    try {
      await _engine.start(
        locale: _localeId,
        onText: _onText,
        onLevel: (level) {
          if (mounted) setState(() => _level = level);
        },
        onEnd: () {
          if (!mounted) return;
          setState(() {
            _engineListening = false;
            // Whatever was still partial when the session closed is kept.
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
          setState(() {
            if (permanent) {
              _error = message;
              _active = false;
              _engineListening = false;
            } else if (message != 'no-speech' && message != 'aborted') {
              _notice = message;
            }
          });
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
      _notice = null;
      _lastResultAt = DateTime.now();
      _committed = '$_sessionBase $finalText'.trim();
      _partial = partialText;
      _result = _matcher.match('$_committed $_partial');
      // Keep following a reciter who carries on past the chosen range.
      final surah = ref.read(repositoryProvider).requireValue.surah(widget.surah);
      if (_result!.complete && _to < surah.numberOfAyahs) {
        _to = surah.numberOfAyahs;
        _buildPassage(keepTranscript: true);
      }
    });
    _giveFeedback(_result!, finalText.isNotEmpty && partialText.isEmpty);
  }

  /// Buzz once for each word confirmed wrong (the recitation has moved past
  /// it, or the text is final), and chime when the passage is complete.
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
    FeedbackTone.unlock(); // inside the tap, so browsers allow the tones later
    final ok = await _init();
    if (!ok) return;
    if (!await _prepareEngine()) return;
    setState(() {
      _active = true;
      _error = null;
      _notice = null;
    });
    await _listen();
  }

  /// For the Mushaf+ voice model: asks before the one-time download, then
  /// shows the download / load progress. Returns false when listening should
  /// not start. Declining the download falls back to the browser engine for
  /// this screen without changing the setting.
  Future<bool> _prepareEngine() async {
    final engine = _engine;
    if (engine is! DownloadableSpeechEngine || engine.isReady) return true;
    final l = context.l10n;
    final cached = await engine.isCached();
    if (!mounted) return false;
    if (!cached) {
      final mb = (engine.approximateDownloadBytes / 1e6).round();
      final go = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: Text(l.voiceModelDownloadTitle),
          content: Text(l.voiceModelDownloadBody(mb)),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context, false), child: Text(l.cancel)),
            FilledButton(onPressed: () => Navigator.pop(context, true), child: Text(l.download)),
          ],
        ),
      );
      if (!mounted) return false;
      if (go != true) {
        // Use the browser recogniser for now; the setting stays as chosen.
        setState(() {
          _voiceModel = false;
          _engine = createSpeechEngine(voiceModel: false);
          _initialised = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(l.usingBrowserEngine)));
        return _init();
      }
    }
    final progress = ValueNotifier<ModelLoadProgress>(const ModelLoadProgress(stage: 'init', loaded: 0, total: 0));
    String? failure;
    var finished = false;
    BuildContext? dialogContext;
    void closeDialog() {
      final c = dialogContext;
      if (c != null && c.mounted) Navigator.of(c).pop();
    }

    engine.prepare(onProgress: (p) => progress.value = p).then((_) {
      finished = true;
      closeDialog();
    }, onError: (Object e) {
      failure = '$e';
      finished = true;
      closeDialog();
    });
    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        dialogContext = context;
        if (finished) WidgetsBinding.instance.addPostFrameCallback((_) => closeDialog());
        return PopScope(
          canPop: false,
          child: AlertDialog(
            title: Text(l.engineVoiceModel),
            content: ValueListenableBuilder<ModelLoadProgress>(
              valueListenable: progress,
              builder: (context, p, _) {
                final downloading = p.stage == 'download' && p.total > 0;
                return Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(downloading ? l.voiceModelDownloading((p.loaded / 1e6).round(), (p.total / 1e6).round()) : l.voiceModelPreparing),
                    const SizedBox(height: 12),
                    LinearProgressIndicator(value: downloading ? (p.loaded / p.total).clamp(0, 1).toDouble() : null),
                    if (!engine.accelerated) ...[
                      const SizedBox(height: 12),
                      Text(l.voiceModelSlow, style: TextStyle(fontSize: 12, color: Theme.of(context).colorScheme.onSurfaceVariant)),
                    ],
                  ],
                );
              },
            ),
          ),
        );
      },
    );
    progress.dispose();
    if (!mounted) return false;
    if (failure != null) {
      setState(() => _error = '${l.voiceModelFailed} $failure');
      return false;
    }
    return engine.isReady;
  }

  void _reset() {
    setState(() {
      _sessionBase = '';
      _committed = '';
      _partial = '';
      _hintUntil = -1;
      _flaggedWrong.clear();
      _celebrated = false;
      _result = _matcher.match('');
    });
    if (_active) {
      // Start a fresh session so the engine's buffer is cleared too.
      _engine.stop().then((_) => _scheduleRestart());
    }
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
    if (kIsWeb && settings.useVoiceModel != _voiceModel) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _useEngine(settings.useVoiceModel);
      });
    }
    final voice = _voiceModel;

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
          if (kIsWeb)
            IconButton(
              tooltip: l.recognitionEngine,
              icon: Icon(voice ? Icons.graphic_eq : Icons.record_voice_over_outlined),
              onPressed: () => showRecognitionEngineDialog(context, ref),
            ),
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
                                if (voice || r.vowel > 0) _Stat(color: Colors.amber.shade700, label: l.vowelSlips, value: r.vowel),
                                _Stat(color: Colors.red, label: l.wrongWords, value: r.wrong),
                                _Stat(color: Colors.orange, label: l.missedWords, value: r.missed),
                              ],
                            ),
                            const SizedBox(height: 8),
                            if (voice || r.vowel > 0)
                              Text(l.reciteSummary(r.matched, r.vowel, r.wrong),
                                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: scheme.onSurface)),
                            Text(l.wordsReached(r.reached, r.words.length), style: TextStyle(fontSize: 13, color: scheme.onSurfaceVariant)),
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
                          child: Text(
                              '${_error == 'not-allowed' || _error == 'service-not-allowed' ? l.micDenied : l.speechUnavailable}\n$_error · ${_engine.description}',
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
                          onTap: (index, match) => _showWordSheet(index, match, settings),
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
              if (_active || _committed.isNotEmpty || _partial.isNotEmpty)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: scheme.surfaceContainerHighest.withValues(alpha: 0.5),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        _committed.isEmpty && _partial.isEmpty ? '${l.heard}: …' : '${l.heard}: $_committed $_partial',
                        textDirection: TextDirection.rtl,
                        style: TextStyle(fontSize: 14, fontStyle: FontStyle.italic, color: scheme.onSurfaceVariant),
                      ),
                      if (_active && _committed.isEmpty && _partial.isEmpty && _lastResultAt == null)
                        Padding(
                          padding: const EdgeInsets.only(top: 4),
                          child: Text(l.noSpeechYet, style: TextStyle(fontSize: 12, color: scheme.onSurfaceVariant)),
                        ),
                      if (_notice != null)
                        Padding(
                          padding: const EdgeInsets.only(top: 4),
                          child: Text('${l.speechNotice}: $_notice', style: TextStyle(fontSize: 12, color: scheme.error)),
                        ),
                    ],
                  ),
                ),
              const SizedBox(height: 16),

              const SizedBox(height: 8),
              Text(
                l.reciteHelp,
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 12, color: scheme.outline, height: 1.4),
              ),
              Text(
                voice ? l.voiceModelHelp : l.strictHelp,
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 12, color: scheme.outline, height: 1.4),
              ),
              if (voice) ...[
                const SizedBox(height: 4),
                Text(
                  l.feedbackDisclaimer,
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 12, color: scheme.outline, height: 1.4),
                ),
                if (_engine is DownloadableSpeechEngine && !(_engine as DownloadableSpeechEngine).accelerated)
                  Text(
                    l.voiceModelSlow,
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 12, color: scheme.outline, height: 1.4),
                  ),
              ],
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
      bottomNavigationBar: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const MiniPlayer(showLocation: false),
          _ControlsBar(
            active: _active,
            listening: _engineListening,
            level: _level,
            strict: _strict,
            canHint: !r.complete,
            onMic: _toggle,
            onReset: _reset,
            onHint: () => setState(() => _hintUntil = r.nextIndex),
            onStrict: _setStrict,
            onPlay: () => ref.read(audioProvider.notifier).playAyah(_ayahs[cursorAyah].number, until: _ayahs[cursorAyah].number),
          ),
        ],
      ),
    );
  }

  /// Details for a tapped word: its status, the vowel slips with the mark
  /// names (or what was heard for a wrong word), and the reminder that
  /// automatic feedback is not a teacher.
  Future<void> _showWordSheet(int index, WordMatch m, AppSettings settings) async {
    final l = context.l10n;
    final scheme = Theme.of(context).colorScheme;
    final (label, color) = switch (m.status) {
      WordStatus.matched => (l.wordCorrect, Colors.green),
      WordStatus.vowel => (l.wordVowelSlip, Colors.amber.shade800),
      WordStatus.wrong => (l.wordWrong, Colors.red),
      WordStatus.missed => (l.wordMissed, Colors.orange),
      WordStatus.pending => (l.wordPending, scheme.onSurfaceVariant),
    };
    await showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (context) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(m.original,
                  textAlign: TextAlign.center,
                  textDirection: TextDirection.rtl,
                  style: ArabicStyles.ayah(context, scale: settings.arabicScale * 1.1, font: settings.arabicFont)),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(width: 10, height: 10, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
                  const SizedBox(width: 6),
                  Text(label, style: TextStyle(fontWeight: FontWeight.w600, color: color)),
                ],
              ),
              if (m.status == WordStatus.vowel) ...[
                const SizedBox(height: 12),
                for (final v in m.vowelErrors)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 3),
                    child: Text(
                      l.vowelSlipLine(_markLabel(l, v.heardName), v.letter, _markLabel(l, v.expectedName)),
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontSize: 15),
                    ),
                  ),
              ],
              if (m.heard != null && (m.status == WordStatus.wrong || m.status == WordStatus.vowel)) ...[
                const SizedBox(height: 8),
                Text('${l.heard}: ${m.heard}',
                    textAlign: TextAlign.center,
                    textDirection: TextDirection.rtl,
                    style: TextStyle(fontSize: 16, color: scheme.onSurfaceVariant)),
              ],
              const SizedBox(height: 14),
              Text(l.feedbackDisclaimer, textAlign: TextAlign.center, style: TextStyle(fontSize: 12, color: scheme.onSurfaceVariant)),
            ],
          ),
        ),
      ),
    );
  }

  static String _markLabel(AppLocalizations l, String name) => switch (name) {
        'fatha' => l.markFatha,
        'damma' => l.markDamma,
        'kasra' => l.markKasra,
        'sukun' => l.markSukun,
        'shadda' => l.markShadda,
        'fathatan' => l.markFathatan,
        'dammatan' => l.markDammatan,
        'kasratan' => l.markKasratan,
        'no shadda' => l.markNoShadda,
        _ => l.markNone,
      };

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
    required this.onTap,
  });

  final Ayah ayah;
  final List<({int index, WordMatch match})> words;
  final int cursor;
  final bool hide;
  final int hintUntil;
  final bool isCurrent;
  final TextStyle style;
  final void Function(int index, WordMatch match) onTap;

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
        Text(ayahEndMarker(ayah.numberInSurah), style: style.copyWith(fontFamily: ArabicStyles.nameFont, color: scheme.secondary)),
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
        bg = Colors.red.withValues(alpha: 0.2);
        fg = Colors.red.shade800;
      case WordStatus.vowel:
        bg = Colors.amber.withValues(alpha: 0.28);
        fg = Colors.amber.shade900;
      case WordStatus.missed:
        bg = Colors.orange.withValues(alpha: 0.2);
        fg = Colors.orange.shade900;
        deco = TextDecoration.lineThrough;
      case WordStatus.pending:
        bg = index == cursor ? scheme.primary.withValues(alpha: 0.12) : null;
    }
    final dark = Theme.of(context).brightness == Brightness.dark;
    if (dark && m.status == WordStatus.matched) fg = Colors.greenAccent.shade200;
    if (dark && m.status == WordStatus.wrong) fg = Colors.redAccent.shade100;
    if (dark && m.status == WordStatus.vowel) fg = Colors.amberAccent.shade200;
    if (dark && m.status == WordStatus.missed) fg = Colors.orangeAccent.shade200;

    return InkWell(
      onTap: revealed ? () => onTap(index, m) : null,
      borderRadius: BorderRadius.circular(8),
      child: Container(
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
            if ((m.status == WordStatus.wrong || m.status == WordStatus.vowel) && m.heard != null)
              Text(m.heard!, textDirection: TextDirection.rtl, style: TextStyle(fontSize: 11, color: fg)),
          ],
        ),
      ),
    );
  }
}

/// Pinned bottom bar: the microphone is always one tap away, with reset,
/// hint, play-this-ayah and the strict / lenient switch beside it.
class _ControlsBar extends StatelessWidget {
  const _ControlsBar({
    required this.active,
    required this.listening,
    required this.level,
    required this.strict,
    required this.canHint,
    required this.onMic,
    required this.onReset,
    required this.onHint,
    required this.onStrict,
    required this.onPlay,
  });
  final bool active;
  final bool listening;
  final double level;
  final bool strict;
  final bool canHint;
  final VoidCallback onMic;
  final VoidCallback onReset;
  final VoidCallback onHint;
  final ValueChanged<bool> onStrict;
  final VoidCallback onPlay;

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final scheme = Theme.of(context).colorScheme;
    return Material(
      color: scheme.surfaceContainerHigh,
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(12, 6, 12, 8),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _BarAction(icon: Icons.refresh, label: l.reset, onTap: onReset),
                  _BarAction(icon: Icons.play_circle_outline, label: l.playThisAyah, onTap: onPlay),
                  _MicButton(active: active, listening: listening, level: level, onTap: onMic),
                  _BarAction(icon: Icons.lightbulb_outline, label: l.hint, onTap: canHint ? onHint : null),
                  _BarAction(
                    icon: strict ? Icons.gpp_good_outlined : Icons.gpp_maybe_outlined,
                    label: strict ? l.strictMode : l.lenientMode,
                    onTap: () => onStrict(!strict),
                    color: strict ? scheme.primary : scheme.tertiary,
                  ),
                ],
              ),
              if (!active)
                Padding(
                  padding: const EdgeInsets.only(top: 2),
                  child: Text(l.tapMicToStart, style: TextStyle(fontSize: 12, color: scheme.onSurfaceVariant)),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _BarAction extends StatelessWidget {
  const _BarAction({required this.icon, required this.label, required this.onTap, this.color});
  final IconData icon;
  final String label;
  final VoidCallback? onTap;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final c = onTap == null ? scheme.onSurfaceVariant.withValues(alpha: 0.4) : (color ?? scheme.onSurfaceVariant);
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: c, size: 24),
            const SizedBox(height: 2),
            Text(label, style: TextStyle(fontSize: 11, color: c), maxLines: 1, overflow: TextOverflow.ellipsis),
          ],
        ),
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
      width: 84,
      height: 84,
      child: Stack(
        alignment: Alignment.center,
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 120),
            width: 60 + 24 * pulse,
            height: 60 + 24 * pulse,
            decoration: BoxDecoration(shape: BoxShape.circle, color: scheme.primary.withValues(alpha: 0.18 * (listening ? 1 : 0))),
          ),
          FloatingActionButton(
            heroTag: 'recite-mic',
            onPressed: onTap,
            backgroundColor: active ? scheme.error : scheme.primary,
            foregroundColor: Colors.white,
            shape: const CircleBorder(),
            child: Icon(active ? Icons.stop : Icons.mic, size: 32),
          ),
        ],
      ),
    );
  }
}
