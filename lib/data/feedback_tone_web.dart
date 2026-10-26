import 'dart:js_interop';

import 'package:web/web.dart' as web;

web.AudioContext? _ctx;

web.AudioContext? _context() {
  try {
    _ctx ??= web.AudioContext();
    if (_ctx!.state == 'suspended') _ctx!.resume();
    return _ctx;
  } catch (_) {
    return null;
  }
}

void unlock() => _context();

void _beep(double frequency, double seconds, String type, {double gain = 0.25}) {
  final ctx = _context();
  if (ctx == null) return;
  try {
    final osc = ctx.createOscillator();
    final g = ctx.createGain();
    osc.type = type;
    osc.frequency.value = frequency;
    g.gain.value = gain;
    g.gain.setValueAtTime(gain, ctx.currentTime);
    g.gain.exponentialRampToValueAtTime(0.001, ctx.currentTime + seconds);
    osc.connect(g);
    g.connect(ctx.destination);
    osc.start();
    osc.stop(ctx.currentTime + seconds);
  } catch (_) {}
}

void _vibrate(int ms) {
  try {
    web.window.navigator.vibrate(ms.toJS);
  } catch (_) {}
}

void wrong() {
  _beep(180, 0.25, 'square', gain: 0.18);
  _vibrate(200);
}

void success() {
  _beep(880, 0.12, 'sine');
  _vibrate(40);
}
