import 'dart:io';

import 'package:flutter_compass/flutter_compass.dart';

bool get compassSupported => Platform.isAndroid || Platform.isIOS;

Stream<double?> headingStream() {
  if (!compassSupported) return const Stream.empty();
  final events = FlutterCompass.events;
  if (events == null) return const Stream.empty();
  return events.map((e) => e.heading);
}
