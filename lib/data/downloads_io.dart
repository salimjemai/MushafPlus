import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

Future<Directory> _root() async {
  final base = await getApplicationDocumentsDirectory();
  final dir = Directory('${base.path}${Platform.pathSeparator}MushafPlus');
  if (!dir.existsSync()) dir.createSync(recursive: true);
  return dir;
}

bool get _isMobile => Platform.isAndroid || Platform.isIOS;

Future<void> _offer(File file) async {
  if (_isMobile) {
    await Share.shareXFiles([XFile(file.path)]);
  }
  // On desktop the file is simply saved; callers show the path.
}

Future<Directory> _downloadsDir() async {
  if (!_isMobile) {
    final d = await getDownloadsDirectory();
    if (d != null) return d;
  }
  return _root();
}

/// Path where a saved (non-cache) file lands.
Future<String> savedPathFor(String fileName) async =>
    '${(await _downloadsDir()).path}${Platform.pathSeparator}$fileName';

Future<void> saveUrl(String url, String fileName, {void Function(double)? onProgress}) async {
  final res = await http.get(Uri.parse(url));
  if (res.statusCode != 200) throw Exception('Download failed (${res.statusCode})');
  onProgress?.call(1);
  final file = File(await savedPathFor(fileName));
  await file.writeAsBytes(res.bodyBytes, flush: true);
  await _offer(file);
}

Future<void> saveBytes(Uint8List bytes, String fileName, {String mimeType = 'application/octet-stream'}) async {
  final file = File(await savedPathFor(fileName));
  await file.writeAsBytes(bytes, flush: true);
  await _offer(file);
}

/// Same as [saveBytes]: the file is written and offered through the share sheet.
Future<void> openBytes(Uint8List bytes, String fileName, {String mimeType = 'application/octet-stream'}) =>
    saveBytes(bytes, fileName, mimeType: mimeType);

bool get supportsCache => !kIsWeb;

String _safe(String s) => s.replaceAll(RegExp(r'[^A-Za-z0-9_.-]'), '_');

Future<File> _cacheFile(String reciterId, int surah, int ayah) async {
  final root = await _root();
  final dir = Directory('${root.path}${Platform.pathSeparator}audio${Platform.pathSeparator}${_safe(reciterId)}');
  if (!dir.existsSync()) dir.createSync(recursive: true);
  final name = '${surah.toString().padLeft(3, '0')}${ayah.toString().padLeft(3, '0')}.mp3';
  return File('${dir.path}${Platform.pathSeparator}$name');
}

Future<String?> cachedAyahPath(String reciterId, int surah, int ayah) async {
  final f = await _cacheFile(reciterId, surah, ayah);
  return f.existsSync() && f.lengthSync() > 1000 ? f.path : null;
}

Future<String> cacheAyah(String reciterId, int surah, int ayah, String url) async {
  final f = await _cacheFile(reciterId, surah, ayah);
  if (f.existsSync() && f.lengthSync() > 1000) return f.path;
  final res = await http.get(Uri.parse(url));
  if (res.statusCode != 200) throw Exception('Download failed (${res.statusCode})');
  await f.writeAsBytes(res.bodyBytes, flush: true);
  return f.path;
}

Future<int> cachedCount(String reciterId, int surah) async {
  final root = await _root();
  final dir = Directory('${root.path}${Platform.pathSeparator}audio${Platform.pathSeparator}${_safe(reciterId)}');
  if (!dir.existsSync()) return 0;
  final prefix = surah.toString().padLeft(3, '0');
  return dir.listSync().whereType<File>().where((f) => f.uri.pathSegments.last.startsWith(prefix)).length;
}

Future<File> _file(String folder, String name) async {
  final root = await _root();
  final dir = Directory('${root.path}${Platform.pathSeparator}audio${Platform.pathSeparator}${_safe(folder)}');
  if (!dir.existsSync()) dir.createSync(recursive: true);
  return File('${dir.path}${Platform.pathSeparator}${_safe(name)}');
}

Future<String?> cachedFile(String folder, String name) async {
  final f = await _file(folder, name);
  return f.existsSync() && f.lengthSync() > 1000 ? f.path : null;
}

Future<String> cacheFile(String folder, String name, String url) async {
  final f = await _file(folder, name);
  if (f.existsSync() && f.lengthSync() > 1000) return f.path;
  final res = await http.get(Uri.parse(url));
  if (res.statusCode != 200) throw Exception('Download failed (${res.statusCode})');
  await f.writeAsBytes(res.bodyBytes, flush: true);
  return f.path;
}

Future<int> clearAudioCache() async {
  final root = await _root();
  final dir = Directory('${root.path}${Platform.pathSeparator}audio');
  if (!dir.existsSync()) return 0;
  var bytes = 0;
  for (final f in dir.listSync(recursive: true).whereType<File>()) {
    bytes += f.lengthSync();
  }
  dir.deleteSync(recursive: true);
  return bytes;
}
