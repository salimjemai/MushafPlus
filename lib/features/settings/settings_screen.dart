import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/arabic_utils.dart';
import '../../core/l10n.dart';
import '../../core/theme.dart';
import '../../data/storage.dart';
import '../../state/providers.dart';
import '../../widgets/mini_player.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = context.l10n;
    final s = ref.watch(settingsProvider);
    final n = ref.read(settingsProvider.notifier);
    final repo = ref.quran;
    final scheme = Theme.of(context).colorScheme;

    final selectedNames = s.translations.map((id) => repo.edition(id)?.englishName ?? id).join(', ');

    return Scaffold(
      appBar: AppBar(title: Text(l.settings)),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 820),
          child: ListView(
            padding: const EdgeInsets.fromLTRB(16, 4, 16, 32),
            children: [
              _Section(
                title: l.appearance,
                children: [
                  ListTile(
                    title: Text(l.theme),
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
                    leading: const Icon(Icons.language),
                    title: Text(l.language),
                    trailing: DropdownButton<String>(
                      value: appLanguages.containsKey(s.locale) ? s.locale : 'system',
                      underline: const SizedBox.shrink(),
                      items: [
                        DropdownMenuItem(value: 'system', child: Text(l.systemDefault)),
                        for (final e in appLanguages.entries) DropdownMenuItem(value: e.key, child: Text(e.value)),
                      ],
                      onChanged: (v) => n.setLocale(v == 'system' ? null : v),
                    ),
                  ),
                  ListTile(
                    title: Text(l.arabicFont),
                    trailing: SegmentedButton<String>(
                      showSelectedIcon: false,
                      segments: [
                        ButtonSegment(value: ArabicStyles.quranFont, label: Text(l.amiriQuran)),
                        ButtonSegment(value: ArabicStyles.nameFont, label: Text(l.amiriNaskh)),
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
                    title: Text(l.arabicSize),
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
                    title: Text(l.translationSize),
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
                title: l.recitation,
                children: [
                  ListTile(
                    leading: const Icon(Icons.record_voice_over_outlined),
                    title: Text(l.reciter),
                    trailing: const ReciterDropdown(),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                    child: Text(
                      l.recitationHelp,
                      style: TextStyle(fontSize: 12.5, color: scheme.onSurfaceVariant, height: 1.4),
                    ),
                  ),
                ],
              ),
              _Section(
                title: l.reading,
                children: [
                  SwitchListTile(
                    title: Text(l.showTransliteration),
                    subtitle: Text(l.showTransliterationSubtitle),
                    value: s.showTransliteration,
                    onChanged: n.setShowTransliteration,
                  ),
                  SwitchListTile(
                    title: Text(l.wordByWordMode),
                    subtitle: Text(l.wordByWordSettingSubtitle),
                    value: s.wordByWord,
                    onChanged: n.setWordByWord,
                  ),
                  ListTile(
                    title: Text(l.wordMeaningsLanguage),
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
                    title: Text(l.pageAnimation),
                    trailing: DropdownButton<PageAnimation>(
                      value: s.pageAnimation,
                      underline: const SizedBox.shrink(),
                      items: [
                        DropdownMenuItem(value: PageAnimation.curl, child: Text(l.animationCurl)),
                        DropdownMenuItem(value: PageAnimation.flip, child: Text(l.animationFlip)),
                        DropdownMenuItem(value: PageAnimation.slide, child: Text(l.animationSlide)),
                        DropdownMenuItem(value: PageAnimation.fade, child: Text(l.animationFade)),
                      ],
                      onChanged: (v) {
                        if (v != null) n.setPageAnimation(v);
                      },
                    ),
                  ),
                  ListTile(
                    title: Text(l.defaultView),
                    trailing: SegmentedButton<ReaderMode>(
                      showSelectedIcon: false,
                      segments: [
                        ButtonSegment(value: ReaderMode.translation, label: Text(l.viewTranslation)),
                        ButtonSegment(value: ReaderMode.mushaf, label: Text(l.viewMushafBook)),
                      ],
                      selected: {s.readerMode},
                      onSelectionChanged: (v) => n.setReaderMode(v.first),
                    ),
                  ),
                ],
              ),
              _Section(
                title: l.languages,
                children: [
                  ListTile(
                    leading: const Icon(Icons.translate),
                    title: Text(l.translations),
                    subtitle: Text(
                      s.translations.isEmpty ? l.arabicOnlyTapToAdd : selectedNames,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () => context.go('/settings/translations'),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                    child: Text(
                      l.translationsAvailable(
                        repo.editions.where((e) => e.type == 'translation').length,
                        repo.translationLanguages.length,
                      ),
                      style: TextStyle(fontSize: 12.5, color: scheme.onSurfaceVariant, height: 1.4),
                    ),
                  ),
                ],
              ),
              _Section(
                title: l.storage,
                children: [
                  ListTile(
                    leading: const Icon(Icons.download_for_offline_outlined),
                    title: Text(l.offlinePacks),
                    subtitle: Text(l.offlinePacksSubtitle),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () => context.go('/settings/offline'),
                  ),
                  ListTile(
                    leading: const Icon(Icons.cleaning_services_outlined),
                    title: Text(l.clearDownloadedData),
                    subtitle: Text(l.cachedDownloads(Storage.cache.length)),
                    onTap: () async {
                      final ok = await showDialog<bool>(
                        context: context,
                        builder: (c) => AlertDialog(
                          title: Text(l.clearDownloadedDataQuestion),
                          content: Text(l.clearDownloadedDataBody),
                          actions: [
                            TextButton(onPressed: () => Navigator.pop(c, false), child: Text(l.cancel)),
                            FilledButton(onPressed: () => Navigator.pop(c, true), child: Text(l.clear)),
                          ],
                        ),
                      );
                      if (ok == true) {
                        await Storage.cache.clear();
                        ref.invalidate(surahTranslationProvider);
                        ref.invalidate(surahWordsProvider);
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(l.downloadedDataCleared)));
                        }
                      }
                    },
                  ),
                ],
              ),
              _Section(
                title: l.about,
                children: [
                  ListTile(
                    leading: const Icon(Icons.menu_book_outlined),
                    title: Text(l.appTitle),
                    subtitle: Text(l.versionBuiltWith),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                    child: Text(
                      l.credits,
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
