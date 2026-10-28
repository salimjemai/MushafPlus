import 'dart:typed_data';

Future<void> saveUrl(String url, String fileName, {void Function(double)? onProgress}) =>
    throw UnsupportedError('downloads not supported');
Future<void> saveBytes(Uint8List bytes, String fileName, {String mimeType = 'application/octet-stream'}) =>
    throw UnsupportedError('downloads not supported');
Future<void> openBytes(Uint8List bytes, String fileName, {String mimeType = 'application/octet-stream'}) =>
    throw UnsupportedError('downloads not supported');
bool get supportsCache => false;
Future<String?> cachedAyahPath(String reciterId, int surah, int ayah) async => null;
Future<String> cacheAyah(String reciterId, int surah, int ayah, String url) => throw UnsupportedError('no cache');
Future<int> cachedCount(String reciterId, int surah) async => 0;
Future<int> clearAudioCache() async => 0;
Future<String?> cachedFile(String folder, String name) async => null;
Future<String> cacheFile(String folder, String name, String url) => throw UnsupportedError('no cache');
Future<String?> cachedModelPath(String folder, String name) async => null;
Future<String> cacheModel(String folder, String name, String url, {void Function(int received, int total)? onProgress}) =>
    throw UnsupportedError('no model store');
