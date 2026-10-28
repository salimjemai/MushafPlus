import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../core/arabic_utils.dart';
import '../../data/countries.dart';
import '../../data/region.dart';
import '../../widgets/region_chip.dart';
import '../../data/masjid_share.dart';
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
                  // The reciter names are long: give the dropdown the full
                  // width under the label instead of squeezing the label
                  // next to it (Arabic labels wrapped letter by letter).
                  ListTile(
                    leading: const Icon(Icons.record_voice_over_outlined),
                    title: Text(l.reciter),
                    subtitle: const Padding(
                      padding: EdgeInsets.only(top: 4),
                      child: ReciterDropdown(isExpanded: true),
                    ),
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
              if (kIsWeb)
                _Section(
                  title: l.reciteAndCheck,
                  children: [
                    ListTile(
                      leading: const Icon(Icons.graphic_eq),
                      title: Text(l.recognitionEngine),
                      subtitle: Text(s.useVoiceModel ? l.engineVoiceModel : l.engineBrowser),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () => showRecognitionEngineDialog(context, ref),
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                      child: Text(
                        l.engineVoiceModelHelp,
                        style: TextStyle(fontSize: 12.5, color: scheme.onSurfaceVariant, height: 1.4),
                      ),
                    ),
                  ],
                ),
              _Section(
                title: l.profile,
                children: [
                  Consumer(builder: (context, ref, _) {
                    final p = ref.watch(profileProvider);
                    return ListTile(
                      leading: const Icon(Icons.person_outline),
                      title: Text(p == null ? l.createProfile : p.name),
                      subtitle: Text(p == null ? l.profileIntro : p.email, maxLines: 2, overflow: TextOverflow.ellipsis),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () => context.push('/settings/profile'),
                    );
                  }),
                  ListTile(
                    leading: const Icon(Icons.notifications_none),
                    title: Text(l.reminders),
                    subtitle: Text(l.remindersSettingsSubtitle),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () => context.push('/prayer/reminders'),
                  ),
                ],
              ),
              _Section(
                title: l.region,
                children: [
                  ListTile(
                    leading: Text(Region.flag(s.region), style: const TextStyle(fontSize: 26)),
                    title: Text(s.region == null ? l.region : countryNameFor(s.region)),
                    subtitle: Text(l.regionHelp),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () => showRegionSheet(context),
                  ),
                ],
              ),
              _Section(
                title: l.reading,
                children: [
                  SwitchListTile(
                    title: Text(l.tajweedColors),
                    subtitle: Text(l.tajweedColorsSubtitle),
                    value: s.tajweed,
                    onChanged: n.setTajweed,
                  ),
                  ListTile(
                    leading: const Icon(Icons.palette_outlined),
                    title: Text(l.tajweedGuide),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () => context.push('/tajweed'),
                  ),
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
                        for (final e in wordByWordLanguages.entries) DropdownMenuItem(value: e.key, child: Text(e.value)),
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
                title: l.supportTitle,
                children: [
                  ListTile(
                    leading: Icon(Icons.favorite, color: scheme.primary),
                    title: Text(l.supportTitle),
                    subtitle: Text(l.supportSubtitle),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () => context.push('/settings/support'),
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
                  ListTile(
                    leading: const Icon(Icons.source_outlined),
                    title: Text(l.dataSourcesLicences),
                    subtitle: Text(l.dataSourcesLicencesHint),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () => context.push('/settings/licenses'),
                  ),
                  ListTile(
                    leading: const Icon(Icons.privacy_tip_outlined),
                    title: Text(l.privacyPolicy),
                    trailing: const Icon(Icons.open_in_new, size: 18),
                    onTap: () => launchUrl(Uri.parse('${publicSiteUrl}privacy.html'),
                        mode: LaunchMode.externalApplication, webOnlyWindowName: '_blank'),
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

/// Lets the user pick the recite & check engine: the browser's own
/// recogniser (fast, letters only) or the on-device Mushaf+ voice model
/// (one-time download, vowel marks too). Returns true when the choice changed.
Future<bool> showRecognitionEngineDialog(BuildContext context, WidgetRef ref) async {
  final l = context.l10n;
  final current = ref.read(settingsProvider).recognitionEngine;
  final choice = await showDialog<String>(
    context: context,
    builder: (context) => SimpleDialog(
      title: Text(l.recognitionEngine),
      children: [
        RadioGroup<String>(
          groupValue: current,
          onChanged: (v) => Navigator.pop(context, v),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              RadioListTile<String>(
                value: 'browser',
                title: Text(l.engineBrowser),
                subtitle: Text(l.engineBrowserDesc),
              ),
              RadioListTile<String>(
                value: 'voice',
                title: Text(l.engineVoiceModel),
                subtitle: Text(l.engineVoiceModelDesc),
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(24, 8, 24, 8),
          child: Text(l.feedbackDisclaimer, style: TextStyle(fontSize: 12, color: Theme.of(context).colorScheme.onSurfaceVariant)),
        ),
      ],
    ),
  );
  if (choice == null || choice == current) return false;
  ref.read(settingsProvider.notifier).setRecognitionEngine(choice);
  return true;
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
