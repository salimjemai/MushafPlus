import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/models.dart';
import '../../state/providers.dart';
import 'verse_panel.dart';

/// Builds a shareable plain-text version of the ayah using whatever
/// translations are already loaded.
String composeAyahText(WidgetRef ref, Ayah ayah) {
  final repo = ref.quran;
  final settings = ref.read(settingsProvider);
  final surah = repo.surah(ayah.surah);
  final buf = StringBuffer()
    ..writeln(ayah.text)
    ..writeln();
  if (settings.showTransliteration) {
    buf
      ..writeln(repo.transliterationOf(ayah.number))
      ..writeln();
  }
  for (final id in settings.translations) {
    final v = ref.read(surahTranslationProvider((surah: ayah.surah, edition: id)));
    final list = v.asData?.value;
    if (list != null && ayah.numberInSurah - 1 < list.length) {
      final name = repo.edition(id)?.englishName ?? id;
      buf
        ..writeln(list[ayah.numberInSurah - 1])
        ..writeln('— $name')
        ..writeln();
    }
  }
  buf.write('Quran ${ayah.key} · ${surah.englishName}');
  return buf.toString();
}

/// The ayah actions now live in the verse panel (toolbar + tabs).
Future<void> showAyahActions(BuildContext context, WidgetRef ref, Ayah ayah) =>
    showVersePanel(context, ayah);
