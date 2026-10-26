import 'dart:convert';

import 'package:flutter/foundation.dart';

import 'masjid.dart';

/// Where the web app is published; links made on phones and desktops point
/// here so that any browser can open them.
const publicSiteUrl = 'https://salimjemai.github.io/MushafPlus/';

/// Base URL of the running web app (origin + path), or the public site.
String publicSiteBase() {
  if (kIsWeb) {
    final u = Uri.base;
    if (u.scheme == 'http' || u.scheme == 'https') {
      final path = u.path.endsWith('/') ? u.path : u.path.substring(0, u.path.lastIndexOf('/') + 1);
      return '${u.origin}$path';
    }
  }
  return publicSiteUrl;
}

/// The masjid's whole configuration packed into a URL-safe token, so a
/// widget link works without any server.
String encodeMasjid(Masjid m) => base64Url.encode(utf8.encode(jsonEncode(m.toMap()))).replaceAll('=', '');

Masjid? decodeMasjid(String? token) {
  if (token == null || token.isEmpty) return null;
  try {
    var t = token.replaceAll('-', '-').trim();
    while (t.length % 4 != 0) {
      t += '=';
    }
    final map = jsonDecode(utf8.decode(base64Url.decode(t)));
    if (map is! Map) return null;
    return Masjid.fromMap(map);
  } catch (_) {
    return null;
  }
}

enum WidgetView { combined, daily, jumuah, compact }

String widgetUrl(Masjid m, {WidgetView view = WidgetView.combined, String? theme, int? scale}) {
  final q = StringBuffer('v=${view.name}&c=${encodeMasjid(m)}');
  if (theme != null) q.write('&theme=$theme');
  if (scale != null) q.write('&scale=$scale');
  return '${publicSiteBase()}#/w?$q';
}

String tvUrl(Masjid m) => '${publicSiteBase()}#/tv?c=${encodeMasjid(m)}';

String _htmlAttr(String s) => s.replaceAll('&', '&amp;').replaceAll('"', '&quot;').replaceAll('<', '&lt;').replaceAll('>', '&gt;');

/// Copy-and-paste iframe markup for a masjid website.
String iframeSnippet(String url, String title, {int width = 420, int height = 720}) =>
    '<iframe src="${_htmlAttr(url)}" title="${_htmlAttr(title)}" width="$width" height="$height" loading="lazy" '
    'style="display:block;max-width:100%;border:0;border-radius:12px;overflow:hidden"></iframe>';
