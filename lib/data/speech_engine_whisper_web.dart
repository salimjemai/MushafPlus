import 'dart:async';
import 'dart:js_interop';
import 'dart:js_interop_unsafe';
import 'dart:math' as math;
import 'dart:typed_data';

import 'package:web/web.dart' as web;

import 'speech_engine.dart';

/// Where the voice model files are fetched from. The browser keeps them in its
/// Cache API after the first download, so this is a one-time cost per device.
/// Behind a constant so the files can move from the Hugging Face mirror to the
/// Mushaf+ Pages site (host `https://salimjemai.github.io/MushafPlus/models/`,
/// template `{model}/`, model `mushaf_quran_base`) without touching the engine.
class VoiceModelSource {
  const VoiceModelSource({required this.remoteHost, required this.remotePathTemplate, required this.model});
  final String remoteHost;
  final String remotePathTemplate;
  final String model;
}

const voiceModelSource = VoiceModelSource(
  remoteHost: 'https://huggingface.co/',
  remotePathTemplate: '{model}/resolve/{revision}/',
  model: 'eventhorizon0/tarteel-ai-onnx-whisper-base-ar-quran',
);

/// Approximate one-time download: encoder fp16 (41 MB) + decoder q4 (123 MB)
/// on WebGPU, encoder q8 (23 MB) + decoder q4 on wasm, plus the tokenizer.
const voiceModelBytesWebGpu = 168 * 1000 * 1000;
const voiceModelBytesWasm = 150 * 1000 * 1000;

const _sampleRate = 16000;
const _maxSegmentSeconds = 12.0; // longest audio sent in one call (Whisper takes up to 30 s)
const _splitSearchSeconds = 4.0; // where to look for the quietest point when a segment must be cut
const _partialEverySeconds = 3.0; // refresh the partial transcript while the reciter keeps going
const _silenceSeconds = 0.6; // pause that ends a segment
const _preRollSeconds = 0.4; // silence kept before the first voiced chunk
const _minSpeechSeconds = 0.3; // shorter bursts are noise

/// [SpeechEngine] backed by the Mushaf+ voice model running in a module Web
/// Worker (`web/asr/asr-worker.js`): on-device recognition that returns fully
/// vocalised Arabic, so the matcher can grade vowel marks.
///
/// Capture: an AudioWorklet delivers 16 kHz mono chunks. Speech is cut into
/// segments at pauses of [_silenceSeconds] (or at the quietest point of the
/// last four seconds once a segment reaches [_maxSegmentSeconds]); a finished
/// segment is transcribed and appended to the final text, and while a segment
/// is still growing it is re-transcribed every [_partialEverySeconds] as the
/// partial text. Only one transcription runs at a time; a newer partial
/// request replaces an older one still waiting.
class WhisperWebSpeechEngine implements DownloadableSpeechEngine {
  web.Worker? _worker;
  bool _loaded = false;
  Future<void>? _loading;
  int _nextId = 1;
  final _pending = <int, Completer<String>>{};
  Completer<bool>? _probe;
  Completer<void>? _load;
  void Function(ModelLoadProgress p)? _onProgress;
  String? _loadError;

  _Session? _session;

  static bool get _hasWebGpu => (web.window.navigator as JSObject).has('gpu');

  @override
  bool get accelerated => _hasWebGpu;

  String get _device => _hasWebGpu ? 'webgpu' : 'wasm';

  Map<String, String> get _dtype => _hasWebGpu
      ? const {'encoder_model': 'fp16', 'decoder_model_merged': 'q4'}
      : const {'encoder_model': 'q8', 'decoder_model_merged': 'q4'};

  @override
  int get approximateDownloadBytes => _hasWebGpu ? voiceModelBytesWebGpu : voiceModelBytesWasm;

  @override
  bool get isReady => _loaded;

  @override
  bool get shortSessions => false;

  @override
  bool get isListening => _session != null;

  @override
  String get description => 'Mushaf+ voice model ($_device)';

  /// True when the browser can run module workers, WebAssembly and worklets.
  static bool get supported => globalContext.has('Worker') && globalContext.has('WebAssembly') && globalContext.has('AudioWorkletNode');

  @override
  Future<bool> init() async => supported;

  @override
  Future<String> arabicLocale() async => 'ar';

  // ---- worker --------------------------------------------------------------

  static String _assetUrl(String relative) => Uri.parse(web.document.baseURI).resolve('asr/$relative').toString();

  web.Worker _ensureWorker() {
    final existing = _worker;
    if (existing != null) return existing;
    final worker = web.Worker(_assetUrl('asr-worker.js').toJS, web.WorkerOptions(type: 'module'));
    worker.onmessage = ((web.MessageEvent e) => _onWorkerMessage(e.data as JSObject)).toJS;
    worker.onerror = ((web.Event e) {
      final message = e.has('message') ? (e.getProperty<JSString?>('message'.toJS)?.toDart ?? 'worker error') : 'worker error';
      _failAll(message);
    }).toJS;
    _worker = worker;
    return worker;
  }

  void _failAll(String message) {
    _loadError = message;
    _load?.completeError(StateError(message));
    _load = null;
    _probe?.complete(false);
    _probe = null;
    for (final c in _pending.values) {
      c.completeError(StateError(message));
    }
    _pending.clear();
    _session?.onError(message, true);
  }

  void _onWorkerMessage(JSObject m) {
    final type = _str(m, 'type');
    switch (type) {
      case 'progress':
        _onProgress?.call(ModelLoadProgress(stage: _str(m, 'stage'), loaded: _int(m, 'loaded'), total: _int(m, 'total')));
      case 'loaded':
        _loaded = true;
        _onProgress?.call(ModelLoadProgress(stage: 'ready', loaded: _int(m, 'bytes'), total: _int(m, 'bytes')));
        _load?.complete();
        _load = null;
      case 'probe':
        _probe?.complete(_bool(m, 'cached'));
        _probe = null;
      case 'result':
        _pending.remove(_int(m, 'id'))?.complete(_str(m, 'text'));
      case 'error':
        final message = _str(m, 'message');
        final id = m.has('id') && !m.getProperty<JSAny?>('id'.toJS).isUndefinedOrNull ? _int(m, 'id') : null;
        if (id != null) {
          _pending.remove(id)?.completeError(StateError(message));
        } else {
          _failAll(message);
        }
    }
  }

  JSObject _baseMessage(String type) => {
        'type': type,
        'model': voiceModelSource.model,
        'remoteHost': voiceModelSource.remoteHost,
        'remotePathTemplate': voiceModelSource.remotePathTemplate,
        'device': _device,
        'dtype': _dtype,
      }.jsify() as JSObject;

  @override
  Future<bool> isCached() async {
    if (_loaded) return true;
    if (!supported) return false;
    final pending = _probe;
    if (pending != null) return pending.future;
    final c = _probe = Completer<bool>();
    _ensureWorker().postMessage(_baseMessage('probe'));
    return c.future.timeout(const Duration(seconds: 10), onTimeout: () {
      _probe = null;
      return false;
    });
  }

  @override
  Future<void> prepare({void Function(ModelLoadProgress p)? onProgress}) {
    if (_loaded) return Future.value();
    _onProgress = onProgress ?? _onProgress;
    final running = _loading;
    if (running != null) return running;
    final c = _load = Completer<void>();
    _loadError = null;
    _ensureWorker().postMessage(_baseMessage('load'));
    return _loading = c.future.whenComplete(() {
      _loading = null;
      _onProgress = null;
    });
  }

  Future<String> _transcribe(Float32List audio) {
    final id = _nextId++;
    final c = Completer<String>();
    _pending[id] = c;
    final jsAudio = audio.toJS;
    final msg = {'type': 'transcribe', 'id': id}.jsify() as JSObject;
    msg.setProperty('audio'.toJS, jsAudio);
    final buffer = jsAudio.getProperty<JSArrayBuffer>('buffer'.toJS);
    _ensureWorker().postMessage(msg, [buffer].toJS);
    return c.future;
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
      // A DOMException from getUserMedia prints as "NotAllowedError: …".
      final name = '$e';
      final code = name.startsWith('NotAllowedError') || name.startsWith('SecurityError')
          ? 'not-allowed'
          : name.startsWith('NotFoundError') || name.startsWith('NotReadableError')
              ? 'audio-capture'
              : name;
      onError(code, true);
    }
  }

  @override
  Future<void> stop() async {
    final s = _session;
    _session = null;
    if (s != null) await s.close();
  }
}

/// One listening session: microphone capture, segmentation and the queue of
/// transcriptions, with the text assembled so far.
class _Session {
  _Session({required this.engine, required this.onText, required this.onEnd, required this.onError, this.onLevel});
  final WhisperWebSpeechEngine engine;
  final SpeechTextCallback onText;
  final void Function() onEnd;
  final void Function(String message, bool permanent) onError;
  final void Function(double level)? onLevel;

  web.MediaStream? _stream;
  web.AudioContext? _ctx;
  web.AudioWorkletNode? _node;
  bool _closed = false;

  // Active segment.
  final _chunks = <Float32List>[];
  final _chunkRms = <double>[];
  int _segLen = 0;
  bool _segHasSpeech = false;
  int _total = 0; // samples seen in this session
  int _lastVoice = 0; // _total at the last voiced chunk
  int _lastSent = 0; // _total when the active segment was last transcribed
  int _segmentId = 0;
  double _noise = 0.002;

  // Transcription queue: finals in order, at most one partial waiting.
  final _finals = <Float32List>[];
  (int, Float32List)? _partialRequest;
  bool _busy = false;
  String _final = '';
  String _partial = '';

  Future<void> open() async {
    final constraints = web.MediaStreamConstraints(
      audio: web.MediaTrackConstraints(
        channelCount: 1.toJS,
        echoCancellation: true.toJS,
        noiseSuppression: true.toJS,
        autoGainControl: true.toJS,
      ),
    );
    final stream = await web.window.navigator.mediaDevices.getUserMedia(constraints).toDart;
    _stream = stream;
    web.AudioContext ctx;
    try {
      ctx = web.AudioContext(web.AudioContextOptions(sampleRate: _sampleRate));
    } catch (_) {
      ctx = web.AudioContext();
    }
    _ctx = ctx;
    await ctx.audioWorklet.addModule(WhisperWebSpeechEngine._assetUrl('capture-worklet.js')).toDart;
    if (_closed) return;
    final node = web.AudioWorkletNode(ctx, 'mushaf-capture');
    _node = node;
    final inputRate = ctx.sampleRate.toDouble();
    node.port.onmessage = ((web.MessageEvent e) {
      if (_closed) return;
      var samples = (e.data as JSFloat32Array).toDart;
      if (inputRate != _sampleRate) samples = _resample(samples, inputRate);
      _onChunk(samples);
    }).toJS;
    final source = ctx.createMediaStreamSource(stream);
    // Keep the worklet in the rendered graph without producing sound.
    final mute = ctx.createGain();
    mute.gain.value = 0;
    source.connect(node);
    node.connect(mute);
    mute.connect(ctx.destination);
    if (ctx.state == 'suspended') await ctx.resume().toDart;
  }

  Future<void> close() async {
    if (_closed) return;
    _closed = true;
    _node?.port.onmessage = null;
    try {
      _node?.disconnect();
    } catch (_) {}
    final tracks = _stream?.getTracks().toDart ?? const [];
    for (final t in tracks) {
      t.stop();
    }
    final ctx = _ctx;
    _ctx = null;
    if (ctx != null) {
      try {
        await ctx.close().toDart;
      } catch (_) {}
    }
    _chunks.clear();
    _finals.clear();
    _partialRequest = null;
  }

  static Float32List _resample(Float32List input, double fromRate) {
    final ratio = fromRate / _sampleRate;
    final n = (input.length / ratio).floor();
    final out = Float32List(n);
    for (var i = 0; i < n; i++) {
      final pos = i * ratio;
      final j = pos.floor();
      final frac = pos - j;
      final a = input[j];
      final b = j + 1 < input.length ? input[j + 1] : a;
      out[i] = a + (b - a) * frac;
    }
    return out;
  }

  void _onChunk(Float32List samples) {
    var sum = 0.0;
    for (final v in samples) {
      sum += v * v;
    }
    final rms = math.sqrt(sum / math.max(1, samples.length));
    onLevel?.call((20 * _log10(rms + 1e-6) + 50).clamp(-2, 10).toDouble());

    // Adaptive noise floor: snaps down to quiet chunks, creeps up slowly.
    _noise = rms < _noise ? rms : math.min(_noise * 1.01 + 1e-5, 0.02);
    final voiced = rms > math.max(0.004, _noise * 3);

    _total += samples.length;
    _chunks.add(samples);
    _chunkRms.add(rms);
    _segLen += samples.length;
    if (voiced) {
      _segHasSpeech = true;
      _lastVoice = _total;
    }

    if (!_segHasSpeech) {
      // Keep only a short pre-roll of silence before speech starts.
      final keep = (_preRollSeconds * _sampleRate).round();
      while (_chunks.length > 1 && _segLen - _chunks.first.length >= keep) {
        _segLen -= _chunks.removeAt(0).length;
        _chunkRms.removeAt(0);
      }
      _lastSent = _total;
      return;
    }

    final sinceVoice = (_total - _lastVoice) / _sampleRate;
    if (sinceVoice >= _silenceSeconds) {
      _finishSegment();
      return;
    }
    if (_segLen >= _maxSegmentSeconds * _sampleRate) {
      _splitSegment();
      return;
    }
    if ((_total - _lastSent) / _sampleRate >= _partialEverySeconds) {
      _lastSent = _total;
      _partialRequest = (_segmentId, _concat(_chunks, 0, _chunks.length));
      _pump();
    }
  }

  /// The pause ended the segment: transcribe it as final text.
  void _finishSegment() {
    final speech = _segLen - (_total - _lastVoice);
    if (speech >= _minSpeechSeconds * _sampleRate) {
      // Trim the trailing silence to a short tail.
      final tail = (0.25 * _sampleRate).round();
      var end = _chunks.length;
      var trailing = _total - _lastVoice;
      while (end > 1 && trailing - _chunks[end - 1].length >= tail) {
        trailing -= _chunks[end - 1].length;
        end--;
      }
      _finals.add(_concat(_chunks, 0, end));
    }
    _resetSegment();
    _pump();
  }

  /// No pause for [_maxSegmentSeconds]: cut at the quietest chunk of the
  /// last [_splitSearchSeconds], preferring a real dip (well below the
  /// segment's average level) so the cut lands between words rather than in
  /// the middle of a long vowel; finalise what came before and keep the rest
  /// as the new segment.
  void _splitSegment() {
    final window = (_splitSearchSeconds * _sampleRate).round();
    final mean = _chunkRms.fold(0.0, (a, b) => a + b) / _chunkRms.length;
    var cut = _chunks.length - 1;
    var seen = 0;
    var best = double.infinity;
    for (var k = _chunks.length - 1; k > 0 && seen < window; k--) {
      seen += _chunks[k].length;
      // A chunk and its predecessor both quiet: a pause, not a zero crossing.
      final level = math.max(_chunkRms[k], _chunkRms[k - 1]);
      if (level < best) {
        best = level;
        cut = k;
      }
      if (level < mean * 0.25) break; // good enough; stay as late as possible
    }
    _finals.add(_concat(_chunks, 0, cut));
    final rest = _chunks.sublist(cut);
    final restRms = _chunkRms.sublist(cut);
    _resetSegment();
    _chunks.addAll(rest);
    _chunkRms.addAll(restRms);
    _segLen = rest.fold(0, (a, c) => a + c.length);
    _segHasSpeech = true;
    _pump();
  }

  void _resetSegment() {
    _chunks.clear();
    _chunkRms.clear();
    _segLen = 0;
    _segHasSpeech = false;
    _segmentId++;
    _lastSent = _total;
    _partialRequest = null; // a final covers whatever the partial was for
  }

  static Float32List _concat(List<Float32List> chunks, int from, int to) {
    var n = 0;
    for (var i = from; i < to; i++) {
      n += chunks[i].length;
    }
    final out = Float32List(n);
    var o = 0;
    for (var i = from; i < to; i++) {
      out.setAll(o, chunks[i]);
      o += chunks[i].length;
    }
    return out;
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
      engine._transcribe(req.$2).then((text) {
        _busy = false;
        if (_closed) return;
        if (req.$1 == _segmentId) {
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

double _log10(double x) => math.log(x) / math.ln10;

String _str(JSObject o, String key) => o.getProperty<JSString?>(key.toJS)?.toDart ?? '';
int _int(JSObject o, String key) => o.getProperty<JSNumber?>(key.toJS)?.toDartDouble.round() ?? 0;
bool _bool(JSObject o, String key) => o.getProperty<JSBoolean?>(key.toJS)?.toDart ?? false;
