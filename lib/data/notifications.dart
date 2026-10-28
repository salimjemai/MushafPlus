import 'notifications_stub.dart'
    if (dart.library.js_interop) 'notifications_web.dart'
    if (dart.library.io) 'notifications_io.dart' as impl;

/// One scheduled reminder (prayer time, adhkar, daily ayah or dhikr).
class Reminder {
  const Reminder({
    required this.id,
    required this.at,
    required this.title,
    required this.body,
    required this.route,
    this.adhan = false,
  });

  final int id;
  final DateTime at;
  final String title;
  final String body;

  /// App route opened when the reminder is tapped.
  final String route;

  /// Play the chosen adhan when the reminder fires (web, while open) or when
  /// it is opened (native).
  final bool adhan;
}

/// Local reminders. Android, iOS and macOS schedule real system notifications
/// that fire with the app closed; in a browser reminders can only appear while
/// the page is open, so the web build keeps a timer and shows browser
/// notifications when it is.
class Notifications {
  Notifications._();

  /// Called when a reminder fires while the app is running (web only; native
  /// systems deliver the notification themselves).
  static void Function(Reminder reminder)? onFire;

  static Future<void> init(void Function(String route) onTap) => impl.init(onTap);
  static Future<bool> requestPermission() => impl.requestPermission();
  static Future<void> schedule(List<Reminder> items) => impl.schedule(items);
  static Future<void> cancelAll() => impl.cancelAll();

  /// Whether reminders fire with the app closed on this platform.
  static bool get backgroundCapable => impl.backgroundCapable;

  /// Route of the reminder that launched the app, if any.
  static Future<String?> launchRoute() => impl.launchRoute();
}
