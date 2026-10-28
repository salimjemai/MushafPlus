import 'dart:async';
import 'dart:io';
import 'dart:isolate';
import 'dart:math' as math;
import 'dart:typed_data';

import 'package:record/record.dart';
import 'package:sherpa_onnx/sherpa_onnx.dart' as sherpa;

import '../core/speech_segmenter.dart';
import 'downloads.dart';
import 'speech_engine.dart';
import 'voice_model.dart';

const _sampleRate = 16000;
const _frameSamples = 2048; // 128 ms, the chunk size the segmenter sees (as on the web)
const _partialEverySeconds = 3.0;

/// [SpeechEngine] backed by the Mushaf+ voice model running on the device
/// through sherpa-onnx (ONNX Runtime, CPU, int8): recognition that returns
/// fully vocalised Arabic, so the matcher can grade vowel marks. Used by the
/// Android and iOS apps; the web build has its own engine.
///
/// The model files are downloaded once from the GitHub release named in
/// [voiceModelPack] (the caller asks first and shows the progress). The
/// recogniser lives in a worker isolate so neither loading nor a
/// transcription pass blocks the screen. Capture: the `record` plugin
/// delivers 16 kHz mono PCM; [SpeechSegmenter] cuts it at pauses; finished
/// segments are transcribed in order and appended to the final text, and
/// while a segment is still growing it is re-transcribed every few seconds
/// as the partial text (not on devices whose warm-up pass was slow). Only
/// one transcription runs at a time; a newer partial request replaces an
/// older one still waiting.
class SherpaSpeechEngine implements DownloadableSpeechEngine {
  SherpaSpeechEngine({VoiceModelPack? pack}) : pack = pack ?? voiceModelPack;

  final VoiceModelPack pack;

  _Worker? _worker;
  bool _loaded = false;
  int _threads = 0;
  int _warmMs = 0; // duration of the warm-up pass at load
  int _lastMs = 0; // duration of the last recognition pass
  Future<void>? _loading;
  String? _loadError;
  _Session? _session;

  /// Where the native engine exists: the phone and tablet apps.
  static bool get supported => Platform.isAndroid || Platform.isIOS;

  /// A pass that takes longer than this on silence will not keep up with
  /// live partial transcriptions: only pauses are transcribed then.
  static const _slowPassMs = 1500;

  /// True once the warm-up showed this device cannot afford live partials.
  bool get slow => _loaded && _warmMs > _slowPassMs;

  /// Nothing is hardware accelerated here (CPU inference), but the int8
  /// model keeps up with a reciter on most phones: report "accelerated"
  /// unless the warm-up pass showed this device is too slow, so the
  /// "results may lag" note appears only where it is true.
  @override
  bool get accelerated => !slow;

  @override
  String get diagnostics {
    if (!_loaded) return '';
    final ms = _lastMs > 0 ? _lastMs : _warmMs;
    return 'CPU ×$_threads · ${(ms / 1000).toStringAsFixed(1)} s';
  }

  @override
  int get approximateDownloadBytes => pack.totalBytes;

  @override
  bool get isReady => _loaded;

  @override
  bool get shortSessions => false;

  @override
  bool get isListening => _session != null;

  @override
  String get description => 'Mushaf+ voice model (sherpa-onnx, ${pack.modelId})';

  @override
  Future<bool> init() async => supported;

  @override
  Future<String> arabicLocale() async => 'ar';

  /// Threads for ONNX Runtime: a few of the big cores, never the whole chip,
  /// so the UI and the audio capture keep running.
  static int get threads => (Platform.numberOfProcessors ~/ 2).clamp(2, 4);

  // ---- model files -----------------------------------------------------------

  @override
  Future<bool> isCached() async {
    if (_loaded) return true;
    for (final f in pack.files) {
      if (await Downloads.cachedModelPath(pack.folder, f.name) == null) return false;
    }
    return true;
  }

  /// Downloads whatever is missing, reporting bytes over the whole pack.
  Future<Map<String, String>> _ensureFiles(void Function(ModelLoadProgress p)? onProgress) async {
    final paths = <String, String>{};
    final sizes = {for (final f in pack.files) f.name: f.bytes};
    final done = <String, int>{};
    var reported = false;
    void report() {
      final loaded = done.values.fold(0, (a, b) => a + b);
      final total = sizes.values.fold(0, (a, b) => a + b);
      onProgress?.call(ModelLoadProgress(stage: 'download', loaded: loaded, total: total));
    }

    for (final f in pack.files) {
      final existing = await Downloads.cachedModelPath(pack.folder, f.name);
      if (existing != null) {
        paths[f.name] = existing;
        done[f.name] = sizes[f.name]!;
        continue;
      }
      if (!reported) {
        reported = true;
        report();
      }
      paths[f.name] = await Downloads.cacheModel(pack.folder, f.name, pack.urlFor(f), onProgress: (received, total) {
        if (total > 0) sizes[f.name] = total;
        done[f.name] = received;
        report();
      });
      done[f.name] = sizes[f.name]!;
      report();
    }
    return paths;
  }

  @override
  Future<void> prepare({void Function(ModelLoadProgress p)? onProgress}) {
    if (_loaded) return Future.value();
    final running = _loading;
    if (running != null) return running;
    _loadError = null;
    return _loading = _prepare(onProgress).whenComplete(() => _loading = null);
  }

  Future<void> _prepare(void Function(ModelLoadProgress p)? onProgress) async {
    try {
      final paths = await _ensureFiles(onProgress);
      onProgress?.call(const ModelLoadProgress(stage: 'init', loaded: 0, total: 0));
      final worker = _worker ??= await _Worker.spawn();
      _threads = threads;
      await worker.load(
        encoder: paths[pack.encoder.name]!,
        decoder: paths[pack.decoder.name]!,
        tokens: paths[pack.tokens.name]!,
        threads: _threads,
      );
      // Warm-up on a second of silence: the first pass is the slowest and
      // its duration tells whether live partials are affordable here.
      final clock = Stopwatch()..start();
      await worker.transcribe(Float32List(_sampleRate));
      _warmMs = clock.elapsedMilliseconds;
      _loaded = true;
      onProgress?.call(ModelLoadProgress(stage: 'ready', loaded: pack.totalBytes, total: pack.totalBytes));
    } catch (e) {
      _loadError = '$e';
      _worker?.close();
      _worker = null;
      rethrow;
    }
  }

  Future<String> _transcribe(Float32List audio) async {
    final worker = _worker;
    if (worker == null) throw StateError('voice model not loaded');
    final clock = Stopwatch()..start();
    final text = await worker.transcribe(audio);
    _lastMs = clock.elapsedMilliseconds;
    return text;
  }

  // ---- sessions ------------------------------------------------------------

  @override
  Future<void> start({
    required String locale,
    required SpeechTextCallback onText,
    required void Function() onEnd,
    required void Function(String message, bool permanent) onError,
    void Function(double level)? onLevel,
  }) async {
    if (!supported) {
      onError('speech_not_supported', true);
      return;
    }
    await stop();
    try {
      await prepare();
    } catch (e) {
      onError(_loadError ?? '$e', true);
      return;
    }
    final session = _Session(engine: this, onText: onText, onEnd: onEnd, onError: onError, onLevel: onLevel);
    _session = session;
    try {
      await session.open();
    } catch (e) {
      _session = null;
      final text = '$e';
      onError(text.contains('permission') || text.contains('denied') ? 'not-allowed' : text, true);
    }
  }

  @override
  Future<void> stop() async {
    final s = _session;
    _session = null;
    if (s != null) await s.close();
  }

  /// Frees the recogniser when the screen that used it goes away: the int8
  /// model keeps a few hundred megabytes resident, which phones cannot
  /// spare for the rest of the app. The next session reloads it from the
  /// files on the device (a second or two).
  @override
  void release() {
    if (_session != null || _loading != null) return;
    _worker?.close();
    _worker = null;
    _loaded = false;
  }
}

/// One listening session: microphone capture, segmentation and the queue of
/// transcriptions, with the text assembled so far.
class _Session {
  _Session({required this.engine, required this.onText, required this.onEnd, required this.onError, this.onLevel});
  final SherpaSpeechEngine engine;
  final SpeechTextCallback onText;
  final void Function() onEnd;
  final void Function(String message, bool permanent) onError;
  final void Function(double level)? onLevel;

  final _recorder = AudioRecorder();
  StreamSubscription<Uint8List>? _sub;
  bool _closed = false;

  late final SpeechSegmenter _segmenter = SpeechSegmenter(
    sampleRate: _sampleRate,
    partialGap: engine.slow ? double.infinity : _partialEverySeconds,
  );
  final _frame = Float32List(_frameSamples);
  int _frameFill = 0;
  int? _pendingByte; // odd trailing byte of a PCM chunk

  // Transcription queue: finals in order, at most one partial waiting.
  final _finals = <Float32List>[];
  SegmentEvent? _partialRequest;
  bool _busy = false;
  String _final = '';
  String _partial = '';

  Future<void> open() async {
    if (!await _recorder.hasPermission()) throw Exception('microphone permission denied');
    final stream = await _recorder.startStream(const RecordConfig(
      encoder: AudioEncoder.pcm16bits,
      sampleRate: _sampleRate,
      numChannels: 1,
      autoGain: true,
      echoCancel: true,
      noiseSuppress: true,
    ));
    if (_closed) {
      await _recorder.stop();
      return;
    }
    _sub = stream.listen(_onBytes, onError: (Object e) {
      if (!_closed) onError('$e', false);
    }, onDone: () {
      if (!_closed) {
        _closed = true;
        onEnd();
      }
    });
  }

  Future<void> close() async {
    if (_closed) return;
    _closed = true;
    await _sub?.cancel();
    _sub = null;
    try {
      await _recorder.stop();
    } catch (_) {}
    await _recorder.dispose();
    _finals.clear();
    _partialRequest = null;
  }

  /// 16-bit little-endian PCM to floats, regrouped into fixed frames.
  void _onBytes(Uint8List bytes) {
    if (_closed) return;
    var data = bytes;
    final pending = _pendingByte;
    if (pending != null) {
      data = Uint8List(bytes.length + 1)
        ..[0] = pending
        ..setRange(1, bytes.length + 1, bytes);
      _pendingByte = null;
    }
    final even = data.length & ~1;
    if (even != data.length) _pendingByte = data[even];
    final view = ByteData.sublistView(data, 0, even);
    for (var i = 0; i < even; i += 2) {
      _frame[_frameFill++] = view.getInt16(i, Endian.little) / 32768.0;
      if (_frameFill == _frameSamples) {
        _frameFill = 0;
        _onFrame(Float32List.fromList(_frame));
      }
    }
  }

  void _onFrame(Float32List samples) {
    final events = _segmenter.add(samples);
    onLevel?.call(_segmenter.level);
    for (final e in events) {
      if (e.isFinal) {
        _finals.add(e.audio);
        _partialRequest = null; // a final covers whatever the partial was for
      } else {
        _partialRequest = e;
      }
    }
    if (events.isNotEmpty) _pump();
  }

  void _pump() {
    if (_busy || _closed) return;
    if (_finals.isNotEmpty) {
      final audio = _finals.removeAt(0);
      _busy = true;
      engine._transcribe(audio).then((text) {
        _busy = false;
        if (_closed) return;
        if (text.isNotEmpty) _final = '$_final $text'.trim();
        _partial = '';
        onText(_final, _partial);
        _pump();
      }, onError: (Object e) {
        _busy = false;
        if (_closed) return;
        onError('$e', false);
        _pump();
      });
      return;
    }
    final req = _partialRequest;
    if (req != null) {
      _partialRequest = null;
      _busy = true;
      final clock = Stopwatch()..start();
      engine._transcribe(req.audio).then((text) {
        _busy = false;
        final secs = clock.elapsedMilliseconds / 1000;
        _segmenter.partialGap = secs * 1000 > SherpaSpeechEngine._slowPassMs ? double.infinity : math.max(_partialEverySeconds, secs * 1.5);
        if (_closed) return;
        if (req.segmentId == _segmenter.segmentId) {
          _partial = text;
          onText(_final, _partial);
        }
        _pump();
      }, onError: (Object e) {
        _busy = false;
        if (_closed) return;
        onError('$e', false);
        _pump();
      });
    }
  }
}

// ---- worker isolate ----------------------------------------------------------

/// The recogniser in its own isolate. Messages to it are lists whose first
/// element is the command; replies are lists starting with the request id
/// (or 'loaded' / 'error').
class _Worker {
  _Worker._(this._isolate, this._port, this._replies);

  final Isolate _isolate;
  final SendPort _port;
  final StreamSubscription<dynamic> _replies;
  final _pending = <int, Completer<Object?>>{};
  int _nextId = 1;

  static Future<_Worker> spawn() async {
    final receive = ReceivePort();
    final ready = Completer<SendPort>();
    late _Worker worker;
    final replies = receive.listen((Object? m) {
      if (m is SendPort) {
        ready.complete(m);
        return;
      }
      if (m is List && m.isNotEmpty) {
        final c = worker._pending.remove(m[0]);
        if (c == null) return;
        if (m.length > 2 && m[1] == 'error') {
          c.completeError(StateError('${m[2]}'));
        } else {
          c.complete(m.length > 1 ? m[1] : null);
        }
      }
    });
    final isolate = await Isolate.spawn(_workerMain, receive.sendPort, debugName: 'mushaf-voice-model');
    final port = await ready.future;
    return worker = _Worker._(isolate, port, replies);
  }

  Future<T> _call<T>(List<Object?> message) {
    final id = _nextId++;
    final c = Completer<Object?>();
    _pending[id] = c;
    _port.send([id, ...message]);
    return c.future.then((v) => v as T);
  }

  Future<void> load({required String encoder, required String decoder, required String tokens, required int threads}) =>
      _call<void>(['load', encoder, decoder, tokens, threads]);

  Future<String> transcribe(Float32List audio) =>
      _call<String>(['transcribe', TransferableTypedData.fromList([audio])]);

  void close() {
    for (final c in _pending.values) {
      c.completeError(StateError('voice model released'));
    }
    _pending.clear();
    _replies.cancel();
    _isolate.kill(priority: Isolate.immediate);
  }
}

void _workerMain(SendPort reply) {
  final inbox = ReceivePort();
  reply.send(inbox.sendPort);
  sherpa.OfflineRecognizer? recognizer;
  inbox.listen((Object? m) {
    if (m is! List || m.isEmpty) return;
    final id = m[0];
    try {
      switch (m[1]) {
        case 'load':
          sherpa.initBindings();
          recognizer?.free();
          recognizer = sherpa.OfflineRecognizer(sherpa.OfflineRecognizerConfig(
            model: sherpa.OfflineModelConfig(
              whisper: sherpa.OfflineWhisperModelConfig(
                encoder: m[2] as String,
                decoder: m[3] as String,
                language: 'ar',
                task: 'transcribe',
              ),
              tokens: m[4] as String,
              modelType: 'whisper',
              numThreads: m[5] as int,
              debug: false,
            ),
          ));
          reply.send([id, null]);
        case 'transcribe':
          final r = recognizer;
          if (r == null) throw StateError('voice model not loaded');
          final audio = (m[2] as TransferableTypedData).materialize().asFloat32List();
          final stream = r.createStream();
          try {
            stream.acceptWaveform(samples: audio, sampleRate: _sampleRate);
            r.decode(stream);
            reply.send([id, r.getResult(stream).text.trim()]);
          } finally {
            stream.free();
          }
        default:
          throw ArgumentError('unknown command ${m[1]}');
      }
    } catch (e) {
      reply.send([id, 'error', '$e']);
    }
  });
}
