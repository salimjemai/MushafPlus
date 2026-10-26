import 'package:hive_ce_flutter/hive_flutter.dart';

/// Thin wrapper around Hive boxes. Works on every platform (IndexedDB on web).
class Storage {
  Storage._();

  static late final Box settings;
  static late final Box bookmarks;
  static late final Box cache;
  static late final Box masjids;

  static Future<void> init() async {
    await Hive.initFlutter('mushaf_plus');
    settings = await Hive.openBox('settings');
    bookmarks = await Hive.openBox('bookmarks');
    cache = await Hive.openBox('cache');
    masjids = await Hive.openBox('masjids');
  }
}
