import 'notifications.dart';

Future<void> init(void Function(String route) onTap) async {}
Future<bool> requestPermission() async => false;
Future<void> schedule(List<Reminder> items) async {}
Future<void> cancelAll() async {}
bool get backgroundCapable => false;
Future<String?> launchRoute() async => null;
