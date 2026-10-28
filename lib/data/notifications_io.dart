import 'dart:io';

import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;

import 'notifications.dart';

final _plugin = FlutterLocalNotificationsPlugin();
bool _ready = false;

bool get backgroundCapable => Platform.isAndroid || Platform.isIOS || Platform.isMacOS;

Future<void> init(void Function(String route) onTap) async {
  if (!backgroundCapable || _ready) return;
  try {
    const android = AndroidInitializationSettings('@mipmap/ic_launcher');
    const darwin = DarwinInitializationSettings(
      requestAlertPermission: false,
      requestBadgePermission: false,
      requestSoundPermission: false,
    );
    await _plugin.initialize(
      const InitializationSettings(android: android, iOS: darwin, macOS: darwin),
      onDidReceiveNotificationResponse: (r) {
        final p = r.payload;
        if (p != null && p.isNotEmpty) onTap(p);
      },
    );
    _ready = true;
  } catch (_) {
    _ready = false;
  }
}

Future<bool> requestPermission() async {
  if (!backgroundCapable) return false;
  try {
    final android = _plugin.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();
    if (android != null) return await android.requestNotificationsPermission() ?? true;
    final ios = _plugin.resolvePlatformSpecificImplementation<IOSFlutterLocalNotificationsPlugin>();
    if (ios != null) return await ios.requestPermissions(alert: true, badge: true, sound: true) ?? false;
    final mac = _plugin.resolvePlatformSpecificImplementation<MacOSFlutterLocalNotificationsPlugin>();
    if (mac != null) return await mac.requestPermissions(alert: true, badge: true, sound: true) ?? false;
  } catch (_) {}
  return false;
}

const _channel = AndroidNotificationDetails(
  'mushaf_reminders',
  'Mushaf+ reminders',
  channelDescription: 'Prayer times, adhkar and the daily ayah',
  importance: Importance.high,
  priority: Priority.high,
  category: AndroidNotificationCategory.reminder,
);

Future<void> schedule(List<Reminder> items) async {
  if (!_ready) return;
  await _plugin.cancelAll();
  final now = DateTime.now();
  // iOS keeps at most 64 pending notifications per app.
  for (final r in items.where((r) => r.at.isAfter(now)).take(60)) {
    try {
      await _plugin.zonedSchedule(
        r.id,
        r.title,
        r.body,
        tz.TZDateTime.from(r.at, tz.local),
        const NotificationDetails(
          android: _channel,
          iOS: DarwinNotificationDetails(presentAlert: true, presentSound: true, presentBadge: false),
          macOS: DarwinNotificationDetails(presentAlert: true, presentSound: true, presentBadge: false),
        ),
        androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
        uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
        payload: r.route,
      );
    } catch (_) {
      // one bad item must not stop the rest
    }
  }
}

Future<void> cancelAll() async {
  if (!_ready) return;
  try {
    await _plugin.cancelAll();
  } catch (_) {}
}

Future<String?> launchRoute() async {
  if (!_ready) return null;
  try {
    final d = await _plugin.getNotificationAppLaunchDetails();
    if (d?.didNotificationLaunchApp ?? false) return d?.notificationResponse?.payload;
  } catch (_) {}
  return null;
}
