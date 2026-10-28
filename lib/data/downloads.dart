import 'dart:typed_data';

import 'downloads_stub.dart' if (dart.library.js_interop) 'downloads_web.dart' if (dart.library.io) 'downloads_io.dart' as impl;

/// Saving files for the user and keeping an offline audio cache.
///
/// Web: files are handed to the browser as downloads; there is no on-disk
/// cache. Native: files land in the app's documents folder (shared via the
/// system sheet on mobile) and recitation audio is cached per ayah so the
/// player can play it offline.
abstract class Downloads {
  /// Downloads [url] and offers it to the user as [fileName].
  static Future<void> saveUrl(String url, String fileName, {void Function(double)? onProgress}) =>
      impl.saveUrl(url, fileName, onProgress: onProgress);

  /// Offers already-available [bytes] to the user as [fileName].
  static Future<void> saveBytes(Uint8List bytes, String fileName, {String mimeType = 'application/octet-stream'}) =>
      impl.saveBytes(bytes, fileName, mimeType: mimeType);

  /// Opens [bytes] for viewing (new tab on the web, share sheet on mobile).
  static Future<void> openBytes(Uint8List bytes, String fileName, {String mimeType = 'application/octet-stream'}) =>
      impl.openBytes(bytes, fileName, mimeType: mimeType);

  /// Whether this platform keeps an offline audio cache.
  static bool get supportsCache => impl.supportsCache;

  /// Local path of a cached ayah recording, or null when not cached.
  static Future<String?> cachedAyahPath(String reciterId, int surah, int ayah) =>
      impl.cachedAyahPath(reciterId, surah, ayah);

  /// Downloads one ayah recording into the cache; returns its local path.
  static Future<String> cacheAyah(String reciterId, int surah, int ayah, String url) =>
      impl.cacheAyah(reciterId, surah, ayah, url);

  /// Number of cached ayah files for a reciter and surah.
  static Future<int> cachedCount(String reciterId, int surah) => impl.cachedCount(reciterId, surah);

  /// Local path of a cached file in [folder] (adhans, adhkar…), or null.
  static Future<String?> cachedFile(String folder, String name) => impl.cachedFile(folder, name);

  /// Downloads [url] into [folder]/[name] unless already there; returns the path.
  static Future<String> cacheFile(String folder, String name, String url) => impl.cacheFile(folder, name, url);

  /// Removes the whole audio cache; returns bytes freed.
  static Future<int> clearAudioCache() => impl.clearAudioCache();
}
