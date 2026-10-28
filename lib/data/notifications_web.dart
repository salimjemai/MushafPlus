import 'dart:async';
import 'dart:js_interop';
import 'dart:js_interop_unsafe';

import 'package:web/web.dart' as web;

import 'notifications.dart';

List<Reminder> _items = const [];
final _fired = <int>{};
Timer? _timer;
void Function(String route)? _onTap;

bool get _supported => globalContext.has('Notification');

Future<void> init(void Function(String route) onTap) async {
  _onTap = onTap;
  _timer ??= Timer.periodic(const Duration(seconds: 20), (_) => _tick());
}

Future<bool> requestPermission() async {
  if (!_supported) return false;
  if (web.Notification.permission == 'granted') return true;
  try {
    final r = await web.Notification.requestPermission().toDart;
    return r.toDart == 'granted';
  } catch (_) {
    return false;
  }
}

Future<void> schedule(List<Reminder> items) async {
  _items = List.of(items)..sort((a, b) => a.at.compareTo(b.at));
  _fired.clear();
}

Future<void> cancelAll() async {
  _items = const [];
  _fired.clear();
}

bool get backgroundCapable => false;

Future<String?> launchRoute() async => null;

void _tick() {
  final now = DateTime.now();
  for (final r in _items) {
    if (_fired.contains(r.id)) continue;
    if (r.at.isAfter(now)) break;
    if (now.difference(r.at) > const Duration(minutes: 3)) {
      _fired.add(r.id); // too old, skip silently
      continue;
    }
    _fired.add(r.id);
    if (_supported && web.Notification.permission == 'granted') {
      try {
        final n = web.Notification(r.title, web.NotificationOptions(body: r.body, tag: 'mushaf-${r.id}', icon: 'icons/Icon-192.png'));
        n.onclick = ((web.Event _) {
          web.window.focus();
          _onTap?.call(r.route);
        }).toJS;
      } catch (_) {}
    }
    Notifications.onFire?.call(r);
  }
}
