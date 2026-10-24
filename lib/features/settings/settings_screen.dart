import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/arabic_utils.dart';
import '../../core/theme.dart';
import '../../data/storage.dart';
import '../../state/providers.dart';
import '../../widgets/mini_player.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final s = ref.watch(settingsProvider);
    final n = ref.read(settingsProvider.notifier);
    final repo = ref.quran;
    final scheme = Theme.of(context).colorScheme;

    final selectedNames = s.translations
        .map((id) => repo.edition(id)?.englishName ?? id)
        .join(', ');

    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 820),
          child: ListView(
            padding: const EdgeInsets.fromLTRB(16, 4, 16, 32),
            children: [
              _Section(
                title: 'Appearance',
                children: [
                  ListTile(
                    title: const Text('Theme'),
                    trailing: SegmentedButton<ThemeMode>(
                      showSelectedIcon: false,
                      segments: const [
                        ButtonSegment(value: ThemeMode.system, icon: Icon(Icons.brightness_auto)),
                        ButtonSegment(value: ThemeMode.light, icon: Icon(Icons.light_mode)),
                        ButtonSegment(value: ThemeMode.dark, icon: Icon(Icons.dark_mode)),
                      ],
                      selected: {s.themeMode},
                      onSelectionChanged: (v) => n.setThemeMode(v.first),
                    ),
                  ),
                  ListTile(
                    title: const Text('Arabic font'),
                    trailing: SegmentedButton<String>(
                      showSelectedIcon: false,
                      segments: const [
                        ButtonSegment(value: ArabicStyles.quranFont, label: Text('Amiri Quran')),
                        ButtonSegment(value: ArabicStyles.nameFont, label: Text('Amiri')),
                      ],
                      selected: {s.arabicFont},
                      onSelectionChanged: (v) => n.setArabicFont(v.first),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: scheme.surfaceContainerHighest.withValues(alpha: 0.4),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Column(
                        children: [
                          Text(
                            bismillah,
                            textDirection: TextDirection.rtl,
                            textAlign: TextAlign.center,
                            style: ArabicStyles.ayah(context, scale: s.arabicScale, font: s.arabicFont),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            'In the name of Allah, the Entirely Merciful, the Especially Merciful.',
                            textAlign: TextAlign.center,
                            style: TextStyle(fontSize: 15.5 * s.translationScale, height: 1.5),
                          ),
                        ],
                      ),
                    ),
                  ),
                  ListTile(
                    title: const Text('Arabic size'),
                    subtitle: Slider(
                      value: s.arabicScale.clamp(0.7, 1.8),
                      min: 0.7,
                      max: 1.8,
                      divisions: 11,
                      label: '${(s.arabicScale * 100).round()}%',
                      onChanged: n.setArabicScale,
                    ),
                  ),
                  ListTile(
                    title: const Text('Translation size'),
                    subtitle: Slider(
                      value: s.translationScale.clamp(0.8, 1.5),
                      min: 0.8,
                      max: 1.5,
                      divisions: 7,
                      label: '${(s.translationScale * 100).round()}%',
                      onChanged: n.setTranslationScale,
                    ),
                  ),
                ],
              ),
              _Section(
                title: 'Recitation',
                children: [
                  const ListTile(
                    leading: Icon(Icons.record_voice_over_outlined),
                    title: Text('Reciter'),
                    trailing: ReciterDropdown(),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                    child: Text(
                      'Audio streams verse by verse from the islamic.network CDN. Tap play on any ayah, or "Play surah" in the surah header.',
                      style: TextStyle(fontSize: 12.5, color: scheme.onSurfaceVariant, height: 1.4),
                    ),
                  ),
                ],
              ),
              _Section(
                title: 'Reading',
                children: [
                  SwitchListTile(
                    title: const Text('Show transliteration'),
                    subtitle: const Text('Latin-script pronunciation under each ayah'),
                    value: s.showTransliteration,
                    onChanged: n.setShowTransliteration,
                  ),
                  SwitchListTile(
                    title: const Text('Word-by-word mode'),
                    subtitle: const Text(
                        'Show each word with its transliteration and meaning (downloads once per surah)'),
                    value: s.wordByWord,
                    onChanged: n.setWordByWord,
                  ),
                  ListTile(
                    title: const Text('Word meanings language'),
                    trailing: DropdownButton<String>(
                      value: wordByWordLanguages.containsKey(s.wordLanguage) ? s.wordLanguage : 'en',
                      underline: const SizedBox.shrink(),
                      items: [
                        for (final e in wordByWordLanguages.entries)
                          DropdownMenuItem(value: e.key, child: Text(e.value)),
                      ],
                      onChanged: (v) {
                        if (v != null) n.setWordLanguage(v);
                      },
                    ),
                  ),
                  ListTile(
                    title: const Text('Default view'),
                    trailing: SegmentedButton<ReaderMode>(
                      showSelectedIcon: false,
                      segments: const [
                        ButtonSegment(value: ReaderMode.translation, label: Text('Translation')),
                        ButtonSegment(value: ReaderMode.mushaf, label: Text('Mushaf')),
                      ],
                      selected: {s.readerMode},
                      onSelectionChanged: (v) => n.setReaderMode(v.first),
                    ),
                  ),
                ],
              ),
              _Section(
                title: 'Languages',
                children: [
                  ListTile(
                    leading: const Icon(Icons.translate),
                    title: const Text('Translations'),
                    subtitle: Text(
                      s.translations.isEmpty
                          ? 'Arabic only — tap to add translations'
                          : selectedNames,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () => context.go('/settings/translations'),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                    child: Text(
                      '${repo.editions.where((e) => e.type == 'translation').length} translations in '
                      '${repo.translationLanguages.length} languages are available. '
                      'Each one is downloaded the first time you open a surah and kept offline.',
                      style: TextStyle(fontSize: 12.5, color: scheme.onSurfaceVariant, height: 1.4),
                    ),
                  ),
                ],
              ),
              _Section(
                title: 'Storage',
                children: [
                  ListTile(
                    leading: const Icon(Icons.cleaning_services_outlined),
                    title: const Text('Clear downloaded data'),
                    subtitle: Text('${Storage.cache.length} cached surah downloads'),
                    onTap: () async {
                      final ok = await showDialog<bool>(
                        context: context,
                        builder: (c) => AlertDialog(
                          title: const Text('Clear downloaded data?'),
                          content: const Text(
                              'Translations and word-by-word data will be downloaded again when needed. Bookmarks and settings are kept.'),
                          actions: [
                            TextButton(onPressed: () => Navigator.pop(c, false), child: const Text('Cancel')),
                            FilledButton(onPressed: () => Navigator.pop(c, true), child: const Text('Clear')),
                          ],
                        ),
                      );
                      if (ok == true) {
                        await Storage.cache.clear();
                        ref.invalidate(surahTranslationProvider);
                        ref.invalidate(surahWordsProvider);
                        if (context.mounted) {
                          ScaffoldMessenger.of(context)
                              .showSnackBar(const SnackBar(content: Text('Downloaded data cleared')));
                        }
                      }
                    },
                  ),
                ],
              ),
              _Section(
                title: 'About',
                children: [
                  const ListTile(
                    leading: Icon(Icons.menu_book_outlined),
                    title: Text('Quran+'),
                    subtitle: Text('Version 1.0.0 · Built with Flutter'),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                    child: Text(
                      'Arabic text: Tanzil Uthmani edition. Translations and transliteration: '
                      'Al Quran Cloud (alquran.cloud). Word-by-word data: Quran.com. '
                      'Fonts: Amiri & Amiri Quran (SIL Open Font License).',
                      style: TextStyle(fontSize: 12.5, color: scheme.onSurfaceVariant, height: 1.4),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Section extends StatelessWidget {
  const _Section({required this.title, required this.children});
  final String title;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(4, 8, 4, 8),
            child: Text(
              title.toUpperCase(),
              style: TextStyle(
                fontSize: 11.5,
                letterSpacing: 1.4,
                fontWeight: FontWeight.w700,
                color: scheme.primary,
              ),
            ),
          ),
          Card(child: Column(children: children)),
        ],
      ),
    );
  }
}
