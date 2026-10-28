import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../core/l10n.dart';
import '../../data/adhans.dart';

/// Every third-party source the app uses, with its terms. Kept in English
/// on purpose: these are the legal notices the licences ask for.
class LicensesScreen extends StatelessWidget {
  const LicensesScreen({super.key});

  static const _sources = <(String, String, String)>[
    ('Quran text', 'Tanzil Project — Uthmani text, reproduced verbatim as the Tanzil terms require, with this link back to tanzil.net.', 'https://tanzil.net'),
    ('Tajweed markup, translations, transliteration', 'Al Quran Cloud (Islamic Network). Free, key-less API; non-commercial reproduction permitted; translators are credited by name in the app.', 'https://alquran.cloud/terms-and-conditions'),
    ('Word-by-word, tafsir, word audio', 'Quran.com / Quran Foundation content API.', 'https://api-docs.quran.foundation'),
    ('Recitation audio', 'EveryAyah.com, streamed verse by verse. Copyright in each recitation remains with the reciter.', 'https://everyayah.com'),
    ('Hadith collections', 'fawazahmed0/hadith-api (The Unlicense). Arabic chapter titles compiled with AhmedBaset/hadith-json from the classical texts.', 'https://github.com/fawazahmed0/hadith-api'),
    ('Hisn al-Muslim', 'hisnmuslim.com public API (text and audio).', 'https://www.hisnmuslim.com'),
    ('Address and place lookup', '© OpenStreetMap contributors, data under the ODbL via Nominatim; Open-Meteo geocoding (CC BY 4.0); Zippopotam; timeapi.io for time zones; GeoJS for the country guess.', 'https://www.openstreetmap.org/copyright'),
    ('Voice model', 'tarteel-ai/whisper-base-ar-quran (Apache-2.0, fine-tuned from OpenAI Whisper), run on-device with transformers.js (Apache-2.0) and ONNX Runtime (MIT). Downloaded only when you choose it.', 'https://huggingface.co/tarteel-ai/whisper-base-ar-quran'),
    ('Fonts', 'Amiri and Amiri Quran by Khaled Hosny, SIL Open Font License 1.1. Material Icons, Apache-2.0.', 'https://github.com/aliftype/amiri'),
  ];

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final scheme = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.canPop() ? context.pop() : context.go('/settings'),
        ),
        title: Text(l.dataSourcesLicences),
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 720),
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              for (final (title, body, url) in _sources)
                Card(
                  child: ListTile(
                    title: Text(title, style: const TextStyle(fontWeight: FontWeight.w700)),
                    subtitle: Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Text(body, style: TextStyle(height: 1.4, color: scheme.onSurfaceVariant)),
                    ),
                    trailing: const Icon(Icons.open_in_new, size: 18),
                    onTap: () => launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication, webOnlyWindowName: '_blank'),
                  ),
                ),
              Card(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Adhan recordings', style: TextStyle(fontWeight: FontWeight.w700)),
                      const SizedBox(height: 4),
                      Text('Live and field recordings released by their recorders under CC0, the Public Domain Mark or CC BY-SA on the Internet Archive and Wikimedia Commons. Copies are hosted on the app\x27s own site (Ogg and WAV originals converted to mono MP3); each recording keeps its original licence and author:',
                          style: TextStyle(height: 1.4, color: scheme.onSurfaceVariant)),
                      for (final a in adhans)
                        ListTile(
                          contentPadding: EdgeInsets.zero,
                          dense: true,
                          title: Text(a.name),
                          subtitle: Text('${a.author} · ${a.license}'),
                          trailing: const Icon(Icons.open_in_new, size: 16),
                          onTap: () => launchUrl(Uri.parse(a.sourceUrl), mode: LaunchMode.externalApplication, webOnlyWindowName: '_blank'),
                        ),
                    ],
                  ),
                ),
              ),
              Card(
                child: ListTile(
                  leading: const Icon(Icons.code),
                  title: Text(l.openSourceLicences),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => showLicensePage(context: context, applicationName: 'Mushaf+'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
