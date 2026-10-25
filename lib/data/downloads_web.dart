import 'dart:js_interop';
import 'dart:typed_data';

import 'package:http/http.dart' as http;
import 'package:web/web.dart' as web;

Future<void> saveUrl(String url, String fileName, {void Function(double)? onProgress}) async {
  // Fetch (the sources send CORS headers) so the browser saves it under our
  // name instead of opening the media player.
  final res = await http.get(Uri.parse(url));
  if (res.statusCode != 200) throw Exception('Download failed (${res.statusCode})');
  onProgress?.call(1);
  await saveBytes(res.bodyBytes, fileName, mimeType: res.headers['content-type'] ?? 'application/octet-stream');
}

Future<void> saveBytes(Uint8List bytes, String fileName, {String mimeType = 'application/octet-stream'}) async {
  final blob = web.Blob([bytes.toJS].toJS, web.BlobPropertyBag(type: mimeType));
  final href = web.URL.createObjectURL(blob);
  final a = web.HTMLAnchorElement()
    ..href = href
    ..download = fileName
    ..style.display = 'none';
  web.document.body?.append(a);
  a.click();
  a.remove();
  web.URL.revokeObjectURL(href);
}

bool get supportsCache => false;
Future<String?> cachedAyahPath(String reciterId, int surah, int ayah) async => null;
Future<String> cacheAyah(String reciterId, int surah, int ayah, String url) => throw UnsupportedError('no cache on web');
Future<int> cachedCount(String reciterId, int surah) async => 0;
Future<int> clearAudioCache() async => 0;
