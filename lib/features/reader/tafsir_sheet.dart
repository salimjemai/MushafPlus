import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/arabic_utils.dart';
import '../../core/theme.dart';
import '../../data/models.dart';
import '../../data/tafsir_service.dart';
import '../../state/providers.dart';

Future<void> showTafsirSheet(BuildContext context, Ayah ayah) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    showDragHandle: true,
    useSafeArea: true,
    builder: (context) => DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.8,
      maxChildSize: 0.95,
      builder: (context, controller) => TafsirSheet(ayah: ayah, controller: controller),
    ),
  );
}

class TafsirSheet extends ConsumerWidget {
  const TafsirSheet({super.key, required this.ayah, required this.controller});
  final Ayah ayah;
  final ScrollController controller;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider);
    final repo = ref.quran;
    final surah = repo.surah(ayah.surah);
    final source = tafsirById(settings.tafsirId);
    final text = ref.watch(tafsirProvider((id: source.id, key: ayah.key)));
    final scheme = Theme.of(context).colorScheme;

    return ListView(
      controller: controller,
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
      children: [
        Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Tafsir', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
                  Text(
                    '${surah.englishName} · Ayah ${ayah.numberInSurah}',
                    style: TextStyle(color: scheme.onSurfaceVariant, fontSize: 13),
                  ),
                ],
              ),
            ),
            const TafsirDropdown(),
          ],
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: scheme.primary.withValues(alpha: 0.06),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Text(
            ayah.text,
            textDirection: TextDirection.rtl,
            textAlign: TextAlign.right,
            style: ArabicStyles.ayah(context, scale: 0.8 * settings.arabicScale, font: settings.arabicFont),
          ),
        ),
        const SizedBox(height: 16),
        text.when(
          data: (t) => TafsirText(text: t, rtl: source.isRtl, scale: settings.translationScale),
          loading: () => const Padding(
            padding: EdgeInsets.all(32),
            child: Center(child: CircularProgressIndicator()),
          ),
          error: (e, _) => Column(
            children: [
              Icon(Icons.cloud_off, color: scheme.error, size: 36),
              const SizedBox(height: 8),
              Text('Tafsir needs an internet connection the first time.\n$e',
                  textAlign: TextAlign.center),
              const SizedBox(height: 12),
              FilledButton.tonal(
                onPressed: () => ref.invalidate(tafsirProvider((id: source.id, key: ayah.key))),
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        Text(
          '${source.name} · ${source.author} · ${languageName(source.language)} · via Quran.com',
          style: TextStyle(fontSize: 11.5, color: scheme.outline),
        ),
      ],
    );
  }
}

/// Renders the plain-text tafsir: "## " lines as headings, blank lines as
/// paragraph breaks. Arabic runs fall back to the Amiri font.
class TafsirText extends StatelessWidget {
  const TafsirText({super.key, required this.text, required this.rtl, this.scale = 1});
  final String text;
  final bool rtl;
  final double scale;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final paragraphs = text.split(RegExp(r'\n\s*\n'));
    final body = TextStyle(
      fontSize: (rtl ? 18 : 15.5) * scale,
      height: rtl ? 1.9 : 1.6,
      color: scheme.onSurface,
      fontFamily: rtl ? ArabicStyles.nameFont : null,
      fontFamilyFallback: const [ArabicStyles.nameFont],
    );
    final heading = body.copyWith(
      fontWeight: FontWeight.w700,
      color: scheme.primary,
      fontSize: (rtl ? 19 : 16.5) * scale,
    );
    return Column(
      crossAxisAlignment: rtl ? CrossAxisAlignment.end : CrossAxisAlignment.start,
      children: [
        for (final p in paragraphs)
          if (p.trim().isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Text(
                p.startsWith('## ') ? p.substring(3).trim() : p.trim(),
                textDirection: rtl ? TextDirection.rtl : TextDirection.ltr,
                textAlign: rtl ? TextAlign.right : TextAlign.left,
                style: p.startsWith('## ') ? heading : body,
              ),
            ),
      ],
    );
  }
}

class TafsirDropdown extends ConsumerWidget {
  const TafsirDropdown({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final id = ref.watch(settingsProvider.select((s) => s.tafsirId));
    return DropdownButton<int>(
      value: tafsirSources.any((t) => t.id == id) ? id : defaultTafsirId,
      underline: const SizedBox.shrink(),
      items: [
        for (final t in tafsirSources)
          DropdownMenuItem(
            value: t.id,
            child: Text('${t.name} (${languageName(t.language)})', overflow: TextOverflow.ellipsis),
          ),
      ],
      onChanged: (v) {
        if (v != null) ref.read(settingsProvider.notifier).setTafsirId(v);
      },
    );
  }
}
