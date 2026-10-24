import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/arabic_utils.dart';
import '../../core/l10n.dart';
import '../../core/theme.dart';
import '../../data/models.dart';
import '../../state/audio_controller.dart';
import '../../state/providers.dart';
import 'reader_screen.dart';

/// Continuous Arabic-only layout, like a printed Mushaf page. Tap an ayah to
/// open its actions.
class MushafView extends ConsumerWidget {
  const MushafView({
    super.key,
    required this.surah,
    required this.ayahs,
    required this.onAyahTap,
    this.initialAyah,
  });

  final Surah surah;
  final List<Ayah> ayahs;
  final ValueChanged<Ayah> onAyahTap;
  final int? initialAyah;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final scheme = Theme.of(context).colorScheme;
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
      child: Column(
        children: [
          SurahHeader(surah: surah),
          Card(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
              child: MushafText(
                ayahs: ayahs,
                onAyahTap: onAyahTap,
                initialSelected: initialAyah == null ? null : surah.startAyah + initialAyah! - 1,
              ),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            context.l10n.tapAyahHint,
            style: TextStyle(fontSize: 12, color: scheme.onSurfaceVariant),
          ),
        ],
      ),
    );
  }
}

/// The flowing, justified Arabic text of a run of ayahs with ayah-end
/// ornaments. Highlights the ayah being recited and the tapped ayah.
class MushafText extends ConsumerStatefulWidget {
  const MushafText({
    super.key,
    required this.ayahs,
    required this.onAyahTap,
    this.initialSelected,
  });

  final List<Ayah> ayahs;
  final ValueChanged<Ayah> onAyahTap;

  /// Global number of the ayah to highlight initially.
  final int? initialSelected;

  @override
  ConsumerState<MushafText> createState() => _MushafTextState();
}

class _MushafTextState extends ConsumerState<MushafText> {
  final _recognizers = <TapGestureRecognizer>[];
  int? _selected;

  @override
  void initState() {
    super.initState();
    _selected = widget.initialSelected;
    _buildRecognizers();
  }

  @override
  void didUpdateWidget(covariant MushafText old) {
    super.didUpdateWidget(old);
    if (old.ayahs != widget.ayahs) {
      _disposeRecognizers();
      _buildRecognizers();
    }
  }

  void _buildRecognizers() {
    for (final a in widget.ayahs) {
      _recognizers.add(TapGestureRecognizer()
        ..onTap = () {
          setState(() => _selected = a.number);
          ref.read(lastReadProvider.notifier).set(a.number);
          widget.onAyahTap(a);
        });
    }
  }

  void _disposeRecognizers() {
    for (final r in _recognizers) {
      r.dispose();
    }
    _recognizers.clear();
  }

  @override
  void dispose() {
    _disposeRecognizers();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final settings = ref.watch(settingsProvider);
    final scheme = Theme.of(context).colorScheme;
    final base = ArabicStyles.ayah(context, scale: settings.arabicScale, font: settings.arabicFont);
    final playingAyah = ref.watch(audioProvider.select((a) => a.ayah));

    return Text.rich(
      TextSpan(
        children: [
          for (var i = 0; i < widget.ayahs.length; i++) ...[
            TextSpan(
              text: widget.ayahs[i].text,
              recognizer: _recognizers[i],
              style: playingAyah == widget.ayahs[i].number
                  ? base.copyWith(backgroundColor: scheme.primary.withValues(alpha: 0.22))
                  : _selected == widget.ayahs[i].number
                      ? base.copyWith(backgroundColor: scheme.secondary.withValues(alpha: 0.22))
                      : base,
            ),
            TextSpan(
              text: ' ${ayahEndMarker(widget.ayahs[i].numberInSurah)} ',
              recognizer: _recognizers[i],
              style: base.copyWith(fontFamily: ArabicStyles.nameFont, color: scheme.secondary),
            ),
          ],
        ],
      ),
      textDirection: TextDirection.rtl,
      textAlign: TextAlign.justify,
    );
  }
}
