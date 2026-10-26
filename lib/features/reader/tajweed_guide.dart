import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/l10n.dart';
import '../../data/tajweed.dart';
import '../../state/providers.dart';
import 'tajweed_text.dart';

/// Compact legend sheet for the Mushaf: the colour toggle, every rule with
/// its colour, and a link to the full guide.
Future<void> showTajweedLegend(BuildContext context) {
  return showModalBottomSheet<void>(
    context: context,
    showDragHandle: true,
    useSafeArea: true,
    isScrollControlled: true,
    builder: (context) => DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.7,
      maxChildSize: 0.95,
      builder: (context, controller) => Consumer(
        builder: (context, ref, _) {
          final l = context.l10n;
          final on = ref.watch(settingsProvider.select((s) => s.tajweed));
          final scheme = Theme.of(context).colorScheme;
          return ListView(
            controller: controller,
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
            children: [
              Row(
                children: [
                  Expanded(child: Text(l.tajweedLegend, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700))),
                  FilledButton.tonalIcon(
                    onPressed: () {
                      Navigator.of(context).pop();
                      context.push('/tajweed');
                    },
                    icon: const Icon(Icons.menu_book_outlined, size: 18),
                    label: Text(l.seeGuide),
                  ),
                ],
              ),
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: Text(l.tajweedColors),
                subtitle: Text(l.tajweedColorsSubtitle),
                value: on,
                onChanged: ref.read(settingsProvider.notifier).setTajweed,
              ),
              const Divider(),
              for (final g in TajweedGroup.values) ...[
                Padding(
                  padding: const EdgeInsets.fromLTRB(0, 10, 0, 4),
                  child: Text(tajweedGroupName(l, g).toUpperCase(),
                      style: TextStyle(fontSize: 11, letterSpacing: 1.1, fontWeight: FontWeight.w700, color: scheme.onSurfaceVariant)),
                ),
                for (final r in TajweedRule.values.where((r) => r.group == g))
                  ListTile(
                    dense: true,
                    contentPadding: EdgeInsets.zero,
                    leading: TajweedSwatch(rule: r, size: 18),
                    title: Text(tajweedRuleName(l, r)),
                    subtitle: _legendSubtitle(l, r),
                    onTap: () {
                      Navigator.of(context).pop();
                      context.push('/tajweed?rule=${r.name}');
                    },
                  ),
              ],
            ],
          );
        },
      ),
    ),
  );
}

/// The full tajweed guide: every rule with its colour, explanation,
/// trigger letters, prolongation length, classical references and an
/// example word from the Quran that opens in the reader.
class TajweedGuideScreen extends ConsumerWidget {
  const TajweedGuideScreen({super.key, this.highlight});
  final String? highlight;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = context.l10n;
    final scheme = Theme.of(context).colorScheme;
    final repo = ref.watch(tajweedProvider);
    final quran = ref.quran;
    final settings = ref.watch(settingsProvider);
    final keys = {for (final r in TajweedRule.values) r: GlobalKey()};

    if (highlight != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        final k = keys.entries.where((e) => e.key.name == highlight).firstOrNull?.value;
        final ctx = k?.currentContext;
        if (ctx != null) Scrollable.ensureVisible(ctx, duration: const Duration(milliseconds: 400), alignment: 0.1);
      });
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(l.tajweedGuide),
        actions: [
          Switch(value: settings.tajweed, onChanged: ref.read(settingsProvider.notifier).setTajweed),
          const SizedBox(width: 8),
        ],
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 820),
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Text(l.tajweedIntro, style: TextStyle(height: 1.5, color: scheme.onSurfaceVariant)),
              const SizedBox(height: 8),
              for (final g in TajweedGroup.values) ...[
                Padding(
                  padding: const EdgeInsets.fromLTRB(4, 18, 4, 6),
                  child: Text(tajweedGroupName(l, g), style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w800)),
                ),
                for (final r in TajweedRule.values.where((r) => r.group == g))
                  Card(
                    key: keys[r],
                    color: highlight == r.name ? scheme.primaryContainer.withValues(alpha: 0.35) : null,
                    child: Padding(
                      padding: const EdgeInsets.all(14),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              TajweedSwatch(rule: r, size: 20),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Text(tajweedRuleName(l, r), style: const TextStyle(fontSize: 15.5, fontWeight: FontWeight.w700)),
                              ),
                              if (r.arabic != tajweedRuleName(l, r))
                                Text(r.arabic, style: TextStyle(fontFamily: 'Amiri', fontSize: 18, color: scheme.primary)),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(tajweedRuleDescription(l, r), style: const TextStyle(height: 1.5)),
                          const SizedBox(height: 8),
                          Wrap(
                            spacing: 8,
                            runSpacing: 6,
                            children: [
                              if (r.letters != null)
                                Chip(
                                  visualDensity: VisualDensity.compact,
                                  avatar: const Icon(Icons.abc, size: 18),
                                  label: Text('${l.triggerLetters}: ${r.letters}', style: const TextStyle(fontFamily: 'Amiri', fontSize: 15)),
                                ),
                              if (r.counts != null)
                                Chip(visualDensity: VisualDensity.compact, avatar: const Icon(Icons.timer_outlined, size: 18), label: Text(l.countsValue(r.counts!))),
                              if (r.tuhfa != null)
                                Chip(visualDensity: VisualDensity.compact, avatar: const Icon(Icons.format_quote, size: 18), label: Text(l.tuhfaRef(r.tuhfa!))),
                              if (r.jazariyyah != null)
                                Chip(visualDensity: VisualDensity.compact, avatar: const Icon(Icons.format_quote, size: 18), label: Text(l.jazariyyahRef(r.jazariyyah!))),
                            ],
                          ),
                          repo.when(
                            data: (t) {
                              final ex = t.exampleOf(r);
                              if (ex == null) return const SizedBox.shrink();
                              final a = quran.ayah(ex.$1);
                              final s = quran.surah(a.surah);
                              return Padding(
                                padding: const EdgeInsets.only(top: 10),
                                child: InkWell(
                                  borderRadius: BorderRadius.circular(12),
                                  onTap: () => context.push('/surah/${a.surah}?ayah=${a.numberInSurah}'),
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                                    decoration: BoxDecoration(
                                      color: scheme.surfaceContainerHighest.withValues(alpha: 0.5),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Row(
                                      children: [
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text(l.example.toUpperCase(),
                                                  style: TextStyle(fontSize: 10.5, letterSpacing: 1, fontWeight: FontWeight.w700, color: scheme.onSurfaceVariant)),
                                              Text('${s.englishName} ${a.key}', style: TextStyle(fontSize: 12.5, color: scheme.onSurfaceVariant)),
                                            ],
                                          ),
                                        ),
                                        TajweedWordText(word: ex.$2, style: tajweedExampleStyle(context, size: 30)),
                                        const SizedBox(width: 6),
                                        Icon(Icons.chevron_right, color: scheme.onSurfaceVariant),
                                      ],
                                    ),
                                  ),
                                ),
                              );
                            },
                            loading: () => const Padding(padding: EdgeInsets.only(top: 10), child: LinearProgressIndicator(minHeight: 2)),
                            error: (e, _) => const SizedBox.shrink(),
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
              const SizedBox(height: 16),
              Text(l.tajweedSource, style: TextStyle(fontSize: 11.5, color: scheme.outline, height: 1.4)),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}

/// Arabic name (only when the interface name is not already Arabic) and the
/// prolongation length.
Widget? _legendSubtitle(AppLocalizations l, TajweedRule r) {
  final parts = [
    if (r.arabic != tajweedRuleName(l, r)) r.arabic,
    if (r.counts != null) l.countsValue(r.counts!),
  ];
  if (parts.isEmpty) return null;
  return Text(parts.join(' · '), style: const TextStyle(fontSize: 12));
}
