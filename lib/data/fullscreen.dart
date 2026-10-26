import 'fullscreen_stub.dart'
    if (dart.library.js_interop) 'fullscreen_web.dart'
    if (dart.library.io) 'fullscreen_io.dart' as impl;

/// Immersive reading: browser full screen on the web, hidden system bars on
/// phones. Best effort; failures are ignored.
class Fullscreen {
  Fullscreen._();
  static Future<void> enter() => impl.enter();
  static Future<void> exit() => impl.exit();
}
