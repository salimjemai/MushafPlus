import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/l10n.dart';
import '../../core/theme.dart';
import '../../data/models.dart';
import '../../data/tajweed.dart';
import '../../state/providers.dart';

/// Localised rule name.
String tajweedRuleName(AppLocalizations l, TajweedRule r) => switch (r) {
      TajweedRule.hamzatWasl => l.tjHamzatWasl,
      TajweedRule.silent => l.tjSilent,
      TajweedRule.laamShamsiyyah => l.tjLaamShamsiyyah,
      TajweedRule.maddNormal => l.tjMaddNormal,
      TajweedRule.maddPermissible => l.tjMaddPermissible,
      TajweedRule.maddNecessary => l.tjMaddNecessary,
      TajweedRule.qalqalah => l.tjQalqalah,
      TajweedRule.maddObligatory => l.tjMaddObligatory,
      TajweedRule.ikhfaShafawi => l.tjIkhfaShafawi,
      TajweedRule.ikhfa => l.tjIkhfa,
      TajweedRule.idghamShafawi => l.tjIdghamShafawi,
      TajweedRule.iqlab => l.tjIqlab,
      TajweedRule.idghamGhunnah => l.tjIdghamGhunnah,
      TajweedRule.idghamNoGhunnah => l.tjIdghamNoGhunnah,
      TajweedRule.idghamMutajanisayn => l.tjIdghamMutajanisayn,
      TajweedRule.idghamMutaqaribayn => l.tjIdghamMutaqaribayn,
      TajweedRule.ghunnah => l.tjGhunnah,
    };

/// Localised explanation of how the rule is recited.
String tajweedRuleDescription(AppLocalizations l, TajweedRule r) => switch (r) {
      TajweedRule.hamzatWasl => l.tjdHamzatWasl,
      TajweedRule.silent => l.tjdSilent,
      TajweedRule.laamShamsiyyah => l.tjdLaamShamsiyyah,
      TajweedRule.maddNormal => l.tjdMaddNormal,
      TajweedRule.maddPermissible => l.tjdMaddPermissible,
      TajweedRule.maddNecessary => l.tjdMaddNecessary,
      TajweedRule.qalqalah => l.tjdQalqalah,
      TajweedRule.maddObligatory => l.tjdMaddObligatory,
      TajweedRule.ikhfaShafawi => l.tjdIkhfaShafawi,
      TajweedRule.ikhfa => l.tjdIkhfa,
      TajweedRule.idghamShafawi => l.tjdIdghamShafawi,
      TajweedRule.iqlab => l.tjdIqlab,
      TajweedRule.idghamGhunnah => l.tjdIdghamGhunnah,
      TajweedRule.idghamNoGhunnah => l.tjdIdghamNoGhunnah,
      TajweedRule.idghamMutajanisayn => l.tjdIdghamMutajanisayn,
      TajweedRule.idghamMutaqaribayn => l.tjdIdghamMutaqaribayn,
      TajweedRule.ghunnah => l.tjdGhunnah,
    };

String tajweedGroupName(AppLocalizations l, TajweedGroup g) => switch (g) {
      TajweedGroup.madd => l.tjgMadd,
      TajweedGroup.nunTanwin => l.tjgNunTanwin,
      TajweedGroup.meemSakinah => l.tjgMeemSakinah,
      TajweedGroup.ghunnah => l.tjgGhunnah,
      TajweedGroup.qalqalah => l.tjgQalqalah,
      TajweedGroup.lam => l.tjgLam,
      TajweedGroup.silent => l.tjgSilent,
      TajweedGroup.idghamAdjacent => l.tjgIdghamAdjacent,
    };

/// The spans of one word: each segment in its rule colour (or the base
/// colour), all sharing [recognizer] and the ayah's background.
List<InlineSpan> tajweedWordSpans(
  TajweedWord word,
  TextStyle base, {
  bool colored = true,
  bool dark = false,
  GestureRecognizer? recognizer,
}) {
  return [
    for (final s in word.segments)
      TextSpan(
        text: s.text,
        recognizer: recognizer,
        style: colored && s.rule != null ? base.copyWith(color: tajweedColor(s.rule!, dark)) : base,
      ),
  ];
}

/// The rule colour, lightened on dark paper so it stays legible.
Color tajweedColor(TajweedRule r, bool dark) => dark ? Color.lerp(r.color, Colors.white, 0.38)! : r.color;

/// A single word drawn large with its tajweed colours (word panel, guide).
class TajweedWordText extends StatelessWidget {
  const TajweedWordText({super.key, required this.word, required this.style, this.textAlign = TextAlign.center});
  final TajweedWord word;
  final TextStyle style;
  final TextAlign textAlign;

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    return Text.rich(
      TextSpan(children: tajweedWordSpans(word, style, dark: dark)),
      textDirection: TextDirection.rtl,
      textAlign: textAlign,
    );
  }
}

/// An ayah's Arabic text, coloured by tajweed rule when the setting is on
/// and the data is loaded, otherwise plain. Tapping a word reports its index.
class TajweedAyahText extends ConsumerStatefulWidget {
  const TajweedAyahText({super.key, required this.ayah, required this.style, this.onWordTap, this.textAlign = TextAlign.right});
  final Ayah ayah;
  final TextStyle style;
  final ValueChanged<int>? onWordTap;
  final TextAlign textAlign;

  @override
  ConsumerState<TajweedAyahText> createState() => _TajweedAyahTextState();
}

class _TajweedAyahTextState extends ConsumerState<TajweedAyahText> {
  final _recognizers = <TapGestureRecognizer>[];

  @override
  void dispose() {
    for (final r in _recognizers) {
      r.dispose();
    }
    super.dispose();
  }

  TapGestureRecognizer _recognizer(int i) {
    while (_recognizers.length <= i) {
      final k = _recognizers.length;
      _recognizers.add(TapGestureRecognizer()..onTap = () => widget.onWordTap?.call(k));
    }
    return _recognizers[i];
  }

  @override
  Widget build(BuildContext context) {
    final on = ref.watch(settingsProvider.select((s) => s.tajweed));
    final repo = on ? ref.watch(tajweedProvider).asData?.value : null;
    if (repo == null) {
      final words = widget.ayah.text.split(' ');
      return Text.rich(
        TextSpan(children: [
          for (var i = 0; i < words.length; i++) ...[
            if (i > 0) const TextSpan(text: ' '),
            TextSpan(text: words[i], style: widget.style, recognizer: widget.onWordTap == null ? null : _recognizer(i)),
          ],
        ]),
        textDirection: TextDirection.rtl,
        textAlign: widget.textAlign,
        style: widget.style,
      );
    }
    final words = repo.wordsOf(widget.ayah.number);
    final dark = Theme.of(context).brightness == Brightness.dark;
    return Text.rich(
      TextSpan(children: [
        for (var i = 0; i < words.length; i++) ...[
          if (i > 0) TextSpan(text: ' ', style: widget.style),
          ...tajweedWordSpans(words[i], widget.style, dark: dark, recognizer: widget.onWordTap == null ? null : _recognizer(i)),
        ],
      ]),
      textDirection: TextDirection.rtl,
      textAlign: widget.textAlign,
      style: widget.style,
    );
  }
}

/// Small colour chip used in legends.
class TajweedSwatch extends StatelessWidget {
  const TajweedSwatch({super.key, required this.rule, this.size = 14});
  final TajweedRule rule;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(color: rule.color, shape: BoxShape.circle, border: Border.all(color: Colors.black12)),
    );
  }
}

/// Base Arabic style used for example words in legends and guides.
TextStyle tajweedExampleStyle(BuildContext context, {double size = 30}) {
  final font = ProviderScope.containerOf(context, listen: false).read(settingsProvider).arabicFont;
  return TextStyle(fontFamily: font, fontSize: size, height: font == ArabicStyles.quranFont ? 2.0 : 1.8, color: Theme.of(context).colorScheme.onSurface);
}
