import 'compass_stub.dart' if (dart.library.js_interop) 'compass_web.dart' if (dart.library.io) 'compass_io.dart' as impl;

/// Device heading in degrees from true/magnetic north (0..360), or null
/// while unknown. Emits nothing on platforms without a compass.
Stream<double?> headingStream() => impl.headingStream();

/// Whether this platform can provide a live heading at all.
bool get compassSupported => impl.compassSupported;
