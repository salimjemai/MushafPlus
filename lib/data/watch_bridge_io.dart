import 'dart:io';

import 'package:flutter/services.dart';

const _channel = MethodChannel('mushafplus/watch');

bool get supported => Platform.isIOS;

Future<void> publish(String json) async {
  if (!supported) return;
  try {
    await _channel.invokeMethod<void>('publish', json);
  } on MissingPluginException {
    // Older native build without the bridge: nothing to do.
  } on PlatformException {
    // WatchConnectivity unavailable (iPad, no paired watch): ignore.
  }
}
