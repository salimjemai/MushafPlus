import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/arabic_utils.dart';
import '../../core/l10n.dart';
import '../../core/theme.dart';
import '../../state/providers.dart';
import '../../widgets/mini_player.dart';

/// Quick reading settings available from the reader's app bar.
Future<void> showReaderSettings(BuildContext context) {
  return showModalBottomSheet<void>(
    context: context,
    showDragHandle: true,
    useSafeArea: true,
    isScrollControlled: true,
    builder: (_) => const _ReaderSettingsSheet(),
  );
}

class _ReaderSettingsSheet extends ConsumerWidget {
  const _ReaderSettingsSheet();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = context.l10n;
    final s = ref.watch(settingsProvider);
    final n = ref.read(settingsProvider.notifier);
    final scheme = Theme.of(context).colorScheme;

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(l.readingSettings, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: scheme.surfaceContainerHighest.withValues(alpha: 0.4),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Text(
              bismillah,
              textDirection: TextDirection.rtl,
              textAlign: TextAlign.center,
              style: ArabicStyles.ayah(context, scale: s.arabicScale, font: s.arabicFont),
            ),
          ),
          const SizedBox(height: 8),
          _SliderRow(
            label: l.arabicSize,
            value: s.arabicScale,
            min: 0.7,
            max: 1.8,
            onChanged: n.setArabicScale,
          ),
          _SliderRow(
            label: l.translationSize,
            value: s.translationScale,
            min: 0.8,
            max: 1.5,
            onChanged: n.setTranslationScale,
          ),
          const SizedBox(height: 4),
          SegmentedButton<String>(
            segments: [
              ButtonSegment(value: ArabicStyles.quranFont, label: Text(l.amiriQuran)),
              ButtonSegment(value: ArabicStyles.nameFont, label: Text(l.amiriNaskh)),
            ],
            selected: {s.arabicFont},
            onSelectionChanged: (v) => n.setArabicFont(v.first),
          ),
          const SizedBox(height: 8),
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: const Icon(Icons.record_voice_over_outlined),
            title: Text(l.reciter),
            trailing: const ReciterDropdown(),
          ),
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            title: Text(l.tajweedColors),
            subtitle: Text(l.tajweedColorsSubtitle),
            value: s.tajweed,
            onChanged: n.setTajweed,
          ),
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            title: Text(l.showTransliteration),
            subtitle: Text(l.showTransliterationSubtitle),
            value: s.showTransliteration,
            onChanged: n.setShowTransliteration,
          ),
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            title: Text(l.wordByWordMode),
            subtitle: Text(l.wordByWordModeSubtitle),
            value: s.wordByWord,
            onChanged: n.setWordByWord,
          ),
          if (s.wordByWord)
            ListTile(
              contentPadding: EdgeInsets.zero,
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
        ],
      ),
    );
  }
}

class _SliderRow extends StatelessWidget {
  const _SliderRow({
    required this.label,
    required this.value,
    required this.min,
    required this.max,
    required this.onChanged,
  });

  final String label;
  final double value;
  final double min;
  final double max;
  final ValueChanged<double> onChanged;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        SizedBox(width: 120, child: Text(label)),
        Expanded(
          child: Slider(
            value: value.clamp(min, max),
            min: min,
            max: max,
            divisions: ((max - min) * 10).round(),
            label: '${(value * 100).round()}%',
            onChanged: onChanged,
          ),
        ),
      ],
    );
  }
}
