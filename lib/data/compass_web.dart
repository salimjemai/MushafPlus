import 'dart:async';
import 'dart:js_interop';
import 'dart:js_interop_unsafe';

import 'package:web/web.dart' as web;

bool get compassSupported => globalContext.has('DeviceOrientationEvent');

@JS('DeviceOrientationEvent.requestPermission')
external JSPromise<JSString>? _requestPermission();

extension on web.DeviceOrientationEvent {
  /// Safari on iOS reports a true compass heading here.
  @JS('webkitCompassHeading')
  external JSNumber? get webkitCompassHeading;
}

/// Browser heading: iOS Safari gives `webkitCompassHeading`; Android Chrome
/// gives `alpha` on `deviceorientationabsolute` (0 = north, increasing
/// counter-clockwise, hence the 360 - alpha).
Stream<double?> headingStream() {
  final controller = StreamController<double?>.broadcast();
  JSFunction? handler;

  void onEvent(web.Event e) {
    final ev = e as web.DeviceOrientationEvent;
    final webkit = ev.webkitCompassHeading?.toDartDouble;
    if (webkit != null && !webkit.isNaN) {
      controller.add(webkit);
      return;
    }
    final alpha = ev.alpha;
    if (alpha == null) {
      controller.add(null);
      return;
    }
    controller.add((360 - alpha) % 360);
  }

  Future<void> start() async {
    // iOS 13+ requires an explicit permission request from a user gesture.
    try {
      final p = _requestPermission();
      if (p != null) {
        final r = await p.toDart;
        if (r.toDart != 'granted') {
          controller.add(null);
          return;
        }
      }
    } catch (_) {}
    handler = onEvent.toJS;
    web.window.addEventListener('deviceorientationabsolute', handler);
    web.window.addEventListener('deviceorientation', handler);
  }

  controller
    ..onListen = start
    ..onCancel = () {
      if (handler != null) {
        web.window.removeEventListener('deviceorientationabsolute', handler);
        web.window.removeEventListener('deviceorientation', handler);
      }
    };
  return controller.stream;
}
