import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:timezone/data/latest_10y.dart' as tzdata;

import 'app.dart';
import 'data/device_form.dart';
import 'data/storage.dart';
import 'state/providers.dart';

Future<void> main() async {
  final binding = WidgetsFlutterBinding.ensureInitialized();
  // Remember the deep link the platform opened us with (web hash route, app
  // link) before any widget can replace it.
  initialRouteAtStartup = binding.platformDispatcher.defaultRouteName;
  tzdata.initializeTimeZones();
  await Storage.init();
  final form = await detectDeviceForm();
  runApp(ProviderScope(
    overrides: [deviceFormProvider.overrideWithValue(form)],
    child: const MushafPlusApp(),
  ));
}
