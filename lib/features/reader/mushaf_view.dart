import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/arabic_utils.dart';
import '../../core/theme.dart';
import '../../data/models.dart';
import '../../state/providers.dart';
import 'reader_screen.dart';

/// Continuous Arabic-only layout, like a printed Mushaf page. Tap an ayah to
/// open its actions.
class MushafView extends ConsumerStatefulWidget {
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
  ConsumerState<MushafView> createState() => _MushafViewState();
}

class _MushafViewState extends ConsumerState<MushafView> {
  final _recognizers = <TapGestureRecognizer>[];
  int? _selected;

  @override
  void initState() {
    super.initState();
    _selected = widget.initialAyah;
    for (final a in widget.ayahs) {
      _recognizers.add(TapGestureRecognizer()
        ..onTap = () {
          setState(() => _selected = a.numberInSurah);
          ref.read(lastReadProvider.notifier).set(a.number);
          widget.onAyahTap(a);
        });
    }
  }

  @override
  void dispose() {
    for (final r in _recognizers) {
      r.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final settings = ref.watch(settingsProvider);
    final scheme = Theme.of(context).colorScheme;
    final base = ArabicStyles.ayah(context, scale: settings.arabicScale, font: settings.arabicFont);

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
      child: Column(
        children: [
          SurahHeader(surah: widget.surah),
          Card(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
              child: Text.rich(
                TextSpan(
                  children: [
                    for (var i = 0; i < widget.ayahs.length; i++) ...[
                      TextSpan(
                        text: widget.ayahs[i].text,
                        recognizer: _recognizers[i],
                        style: _selected == widget.ayahs[i].numberInSurah
                            ? base.copyWith(
                                backgroundColor: scheme.secondary.withValues(alpha: 0.22),
                              )
                            : base,
                      ),
                      TextSpan(
                        text: ' ${ayahEndMarker(widget.ayahs[i].numberInSurah)} ',
                        recognizer: _recognizers[i],
                        style: base.copyWith(
                          fontFamily: ArabicStyles.nameFont,
                          color: scheme.secondary,
                        ),
                      ),
                    ],
                  ],
                ),
                textDirection: TextDirection.rtl,
                textAlign: TextAlign.justify,
              ),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Tap any ayah for translation, transliteration and word-by-word.',
            style: TextStyle(fontSize: 12, color: scheme.onSurfaceVariant),
          ),
        ],
      ),
    );
  }
}
