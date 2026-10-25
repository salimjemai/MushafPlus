import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../core/l10n.dart';
import '../core/theme.dart';
import '../data/reciters.dart';
import '../state/audio_controller.dart';
import '../state/providers.dart';

/// Compact recitation controls shown at the bottom while audio is active.
class MiniPlayer extends ConsumerWidget {
  const MiniPlayer({super.key, this.showLocation = true});

  /// Whether to show the surah/ayah text as a tappable link to the reader.
  final bool showLocation;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final audio = ref.watch(audioProvider);
    if (!audio.isActive) return const SizedBox.shrink();

    final repo = ref.quran;
    final ayah = repo.ayah(audio.ayah!);
    final surah = repo.surah(ayah.surah);
    final reciter = reciterById(ref.watch(settingsProvider).reciter);
    final scheme = Theme.of(context).colorScheme;
    final ctrl = ref.read(audioProvider.notifier);
    final progress = audio.duration.inMilliseconds == 0
        ? 0.0
        : (audio.position.inMilliseconds / audio.duration.inMilliseconds).clamp(0.0, 1.0);

    return Material(
      color: scheme.surfaceContainerHigh,
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              height: 3,
              child: LinearProgressIndicator(
                value: audio.loading ? null : progress,
                backgroundColor: scheme.outlineVariant.withValues(alpha: 0.3),
                color: AppColors.gold,
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 4, 4, 4),
              child: Row(
                children: [
                  Icon(Icons.graphic_eq, color: scheme.primary, size: 20),
                  const SizedBox(width: 10),
                  Expanded(
                    child: InkWell(
                      onTap: showLocation
                          ? () => context.go('/surah/${surah.number}?ayah=${ayah.numberInSurah}')
                          : null,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            '${surah.englishName} · ${context.l10n.ayahN(ayah.numberInSurah)}'
                            '${audio.loop ? ' · ${context.l10n.loop}' : ''}',
                            style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13.5),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          Text(
                            audio.error ?? reciter.name,
                            style: TextStyle(
                              fontSize: 11.5,
                              color: audio.error != null ? scheme.error : scheme.onSurfaceVariant,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  ),
                  IconButton(
                    tooltip: context.l10n.previousAyah,
                    icon: const Icon(Icons.skip_previous),
                    onPressed: ctrl.previous,
                  ),
                  IconButton.filled(
                    tooltip: audio.playing ? context.l10n.pause : context.l10n.play,
                    icon: audio.loading
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                          )
                        : Icon(audio.playing ? Icons.pause : Icons.play_arrow),
                    onPressed: ctrl.toggle,
                  ),
                  IconButton(
                    tooltip: context.l10n.nextAyah,
                    icon: const Icon(Icons.skip_next),
                    onPressed: ctrl.next,
                  ),
                  IconButton(
                    tooltip: context.l10n.stop,
                    icon: const Icon(Icons.close),
                    onPressed: ctrl.stop,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Dropdown to choose the reciter; reloads the current ayah if one is playing.
class ReciterDropdown extends ConsumerWidget {
  const ReciterDropdown({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final id = ref.watch(settingsProvider.select((s) => s.reciter));
    return DropdownButton<String>(
      value: reciters.any((r) => r.id == id) ? id : defaultReciterId,
      underline: const SizedBox.shrink(),
      isExpanded: false,
      items: [
        for (final r in reciters)
          DropdownMenuItem(value: r.id, child: Text(r.name, overflow: TextOverflow.ellipsis)),
      ],
      onChanged: (v) {
        if (v == null) return;
        ref.read(settingsProvider.notifier).setReciter(v);
        ref.read(audioProvider.notifier).reciterChanged();
      },
    );
  }
}

/// QuranFlash-style listen bar: the mini player plus AUTO (continue past the
/// ayah), repeat-each-ayah count, reciter picker and a seek slider.
class ListenBar extends ConsumerWidget {
  const ListenBar({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final audio = ref.watch(audioProvider);
    if (!audio.isActive) return const SizedBox.shrink();
    final l = context.l10n;
    final scheme = Theme.of(context).colorScheme;
    final ctrl = ref.read(audioProvider.notifier);
    final total = audio.duration.inMilliseconds;
    final pos = audio.position.inMilliseconds.clamp(0, total == 0 ? 0 : total);

    return Material(
      color: scheme.surfaceContainerHigh,
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const MiniPlayer(showLocation: false),
            if (total > 0)
              SizedBox(
                height: 22,
                child: SliderTheme(
                  data: SliderTheme.of(context).copyWith(
                    trackHeight: 2,
                    thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 6),
                    overlayShape: const RoundSliderOverlayShape(overlayRadius: 12),
                  ),
                  child: Slider(
                    value: pos.toDouble(),
                    max: total.toDouble(),
                    onChanged: (v) => ctrl.seek(Duration(milliseconds: v.round())),
                  ),
                ),
              ),
            Padding(
              padding: const EdgeInsets.fromLTRB(10, 0, 10, 6),
              child: Row(
                children: [
                  FilterChip(
                    label: Text(l.continuous),
                    avatar: Icon(Icons.all_inclusive, size: 16, color: audio.continuous ? scheme.onSecondaryContainer : null),
                    selected: audio.continuous,
                    visualDensity: VisualDensity.compact,
                    onSelected: ctrl.setContinuous,
                  ),
                  const SizedBox(width: 8),
                  PopupMenuButton<int>(
                    tooltip: l.repeatEach,
                    initialValue: audio.repeatEach,
                    onSelected: ctrl.setRepeatEach,
                    itemBuilder: (_) => [
                      for (final n in const [1, 2, 3, 5, 7, 10])
                        PopupMenuItem(value: n, child: Text(n == 1 ? '${l.repeatEach}: —' : '${l.repeatEach} ×$n')),
                    ],
                    child: Chip(
                      avatar: Icon(Icons.repeat_one, size: 16, color: audio.repeatEach > 1 ? scheme.primary : null),
                      label: Text(audio.repeatEach > 1 ? '×${audio.repeatEach}' : l.repeatEach),
                      visualDensity: VisualDensity.compact,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Align(
                      alignment: AlignmentDirectional.centerEnd,
                      child: DefaultTextStyle.merge(
                        style: const TextStyle(fontSize: 12.5),
                        child: const ReciterDropdown(),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
