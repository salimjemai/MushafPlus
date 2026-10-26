import 'dart:js_interop';

import 'package:web/web.dart' as web;

Future<void> enter() async {
  try {
    final el = web.document.documentElement;
    if (el != null && web.document.fullscreenElement == null) {
      await el.requestFullscreen().toDart;
    }
  } catch (_) {}
}

Future<void> exit() async {
  try {
    if (web.document.fullscreenElement != null) {
      await web.document.exitFullscreen().toDart;
    }
  } catch (_) {}
}
