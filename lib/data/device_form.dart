import 'device_form_stub.dart' if (dart.library.io) 'device_form_io.dart' as impl;

/// Set with `--dart-define=MUSHAF_WATCH=true` to force the watch interface on
/// any platform (useful to preview the Wear OS layout in a browser).
const forcedWatchForm = bool.fromEnvironment('MUSHAF_WATCH');

/// What kind of device the app is running on.
class DeviceForm {
  const DeviceForm({this.watch = false, this.round = false});

  /// A Wear OS watch (tiny screen, no system navigation bar).
  final bool watch;

  /// The display is a circle, so content must stay inside the inscribed square.
  final bool round;

  /// The form [detectDeviceForm] found at startup; a phone until then.
  static DeviceForm current = const DeviceForm();
}

/// Asks the platform once at startup.
Future<DeviceForm> detectDeviceForm() async {
  final form = forcedWatchForm ? const DeviceForm(watch: true, round: true) : await impl.detect();
  DeviceForm.current = form;
  return form;
}
