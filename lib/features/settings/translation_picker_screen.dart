import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/arabic_utils.dart';
import '../../core/l10n.dart';
import '../../data/models.dart';
import '../../state/providers.dart';

/// Pick up to four translation editions, grouped by language.
class TranslationPickerScreen extends ConsumerStatefulWidget {
  const TranslationPickerScreen({super.key});

  @override
  ConsumerState<TranslationPickerScreen> createState() => _TranslationPickerScreenState();
}

class _TranslationPickerScreenState extends ConsumerState<TranslationPickerScreen> {
  String _query = '';

  @override
  Widget build(BuildContext context) {
    final repo = ref.quran;
    final settings = ref.watch(settingsProvider);
    final scheme = Theme.of(context).colorScheme;

    final all = repo.editions.where((e) => e.type == 'translation').toList();
    final q = _query.trim().toLowerCase();
    final filtered = q.isEmpty
        ? all
        : all.where((e) {
            return e.englishName.toLowerCase().contains(q) ||
                e.name.toLowerCase().contains(q) ||
                languageName(e.language).toLowerCase().contains(q) ||
                e.language == q;
          }).toList();

    final byLanguage = <String, List<Edition>>{};
    for (final e in filtered) {
      byLanguage.putIfAbsent(e.language, () => []).add(e);
    }
    final languages = byLanguage.keys.toList()
      ..sort((a, b) => languageName(a).compareTo(languageName(b)));

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.canPop() ? context.pop() : context.go('/settings'),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(context.l10n.translations),
            Text(
              context.l10n.selectedOfMax(settings.translations.length, AppSettings.maxTranslations),
              style: TextStyle(fontSize: 12, color: scheme.onSurfaceVariant),
            ),
          ],
        ),
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 820),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
                child: TextField(
                  onChanged: (v) => setState(() => _query = v),
                  decoration: InputDecoration(
                    hintText: context.l10n.searchLanguageOrTranslator,
                    prefixIcon: const Icon(Icons.search),
                  ),
                ),
              ),
              if (settings.translations.isNotEmpty)
                SizedBox(
                  height: 48,
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    children: [
                      for (final id in settings.translations)
                        Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: InputChip(
                            label: Text(repo.edition(id)?.englishName ?? id),
                            avatar: CircleAvatar(
                              backgroundColor: scheme.primary.withValues(alpha: 0.15),
                              child: Text(
                                (repo.edition(id)?.language ?? '?').toUpperCase(),
                                style: TextStyle(fontSize: 9, color: scheme.primary, fontWeight: FontWeight.w700),
                              ),
                            ),
                            onDeleted: () => ref.read(settingsProvider.notifier).toggleTranslation(id),
                          ),
                        ),
                    ],
                  ),
                ),
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                  itemCount: languages.length,
                  itemBuilder: (context, i) {
                    final lang = languages[i];
                    final editions = byLanguage[lang]!;
                    final selectedHere =
                        editions.where((e) => settings.translations.contains(e.identifier)).length;
                    return Card(
                      key: ValueKey(lang),
                      child: ExpansionTile(
                        shape: const RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(20))),
                        collapsedShape: const RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(20))),
                        initiallyExpanded: q.isNotEmpty || selectedHere > 0,
                        leading: CircleAvatar(
                          backgroundColor: scheme.primary.withValues(alpha: 0.12),
                          child: Text(
                            lang.toUpperCase(),
                            style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: scheme.primary),
                          ),
                        ),
                        title: Text(languageName(lang), style: const TextStyle(fontWeight: FontWeight.w700)),
                        subtitle: Text(
                          '${context.l10n.nTranslations(editions.length)}'
                          '${selectedHere > 0 ? ' · ${context.l10n.nSelected(selectedHere)}' : ''}',
                        ),
                        children: [
                          for (final e in editions)
                            CheckboxListTile(
                              value: settings.translations.contains(e.identifier),
                              title: Text(e.englishName),
                              subtitle: Text(
                                e.name,
                                textDirection: e.isRtl ? TextDirection.rtl : TextDirection.ltr,
                              ),
                              secondary: e.isRtl
                                  ? Tooltip(
                                      message: context.l10n.rightToLeftScript,
                                      child: Icon(Icons.format_textdirection_r_to_l,
                                          size: 18, color: scheme.onSurfaceVariant),
                                    )
                                  : null,
                              onChanged: (_) {
                                final ok = ref
                                    .read(settingsProvider.notifier)
                                    .toggleTranslation(e.identifier);
                                if (!ok) {
                                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                                    content: Text(context.l10n.translationLimit(AppSettings.maxTranslations)),
                                  ));
                                }
                              },
                            ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
