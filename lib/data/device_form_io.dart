import 'dart:io';

import 'package:flutter/services.dart';

import 'device_form.dart';

const _channel = MethodChannel('mushafplus/device');

Future<DeviceForm> detect() async {
  if (!Platform.isAndroid) return const DeviceForm();
  try {
    final r = await _channel.invokeMapMethod<String, Object?>('formFactor');
    return DeviceForm(watch: r?['watch'] == true, round: r?['round'] == true);
  } on MissingPluginException {
    return const DeviceForm();
  } on PlatformException {
    return const DeviceForm();
  }
}
