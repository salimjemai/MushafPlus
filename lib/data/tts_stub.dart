import 'package:flutter/foundation.dart';

Future<bool> speak(String id, List<(String, String)> parts, ValueNotifier<String?> speaking) async => false;
Future<void> stop(ValueNotifier<String?> speaking) async => speaking.value = null;
