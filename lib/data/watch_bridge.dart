import 'watch_bridge_stub.dart' if (dart.library.io) 'watch_bridge_io.dart' as impl;

/// Whether this platform has a paired-watch bridge (iOS → Apple Watch).
/// Wear OS runs the Flutter app itself, so Android needs none.
bool get watchBridgeSupported => impl.supported;

/// Hands the JSON payload built by `watch_sync.dart` to the native side,
/// which stores it in the App Group and sends it to the watch.
Future<void> publishToWatch(String json) => impl.publish(json);
