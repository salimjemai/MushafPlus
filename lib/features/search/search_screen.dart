import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/arabic_utils.dart';
import '../../core/l10n.dart';
import '../../core/theme.dart';
import '../../data/quran_repository.dart';
import '../../data/translation_service.dart';
import '../../state/providers.dart';
import 'highlight.dart';
import '../../widgets/surah_number_badge.dart';

class SearchScreen extends ConsumerStatefulWidget {
  const SearchScreen({super.key, this.initialQuery});
  final String? initialQuery;

  @override
  ConsumerState<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends ConsumerState<SearchScreen> {
  final _controller = TextEditingController();
  Timer? _debounce;
  String _query = '';
  List<int> _results = const [];
  List<String>? _corpus;
  bool _searching = false;

  @override
  void initState() {
    super.initState();
    final q = widget.initialQuery?.trim() ?? '';
    if (q.isNotEmpty) {
      _controller.text = q;
      _query = q;
      WidgetsBinding.instance.addPostFrameCallback((_) => _run(q));
    }
    ref
        .read(translationServiceProvider)
        .bundledCorpus(TranslationService.defaultEdition)
        .then((c) {
      if (!mounted) return;
      _corpus = c;
      if (_query.isNotEmpty) _run(_query);
    });
  }

  @override
  void didUpdateWidget(covariant SearchScreen old) {
    super.didUpdateWidget(old);
    final q = widget.initialQuery?.trim() ?? '';
    if (q.isNotEmpty && q != old.initialQuery?.trim() && q != _query) {
      _controller.text = q;
      _onChanged(q);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  void _onChanged(String v) {
    _query = v;
    _debounce?.cancel();
    setState(() => _searching = v.trim().length >= 2);
    _debounce = Timer(const Duration(milliseconds: 250), () => _run(v));
  }

  void _run(String q) {
    if (!mounted) return;
    if (q.trim().length < 2) {
      setState(() {
        _results = const [];
        _searching = false;
      });
      return;
    }
    final repo = ref.quran;
    final seen = <int>{};
    final out = <int>[];
    for (final n in repo.searchArabicAndTransliteration(q)) {
      if (seen.add(n)) out.add(n);
    }
    final corpus = _corpus;
    if (corpus != null) {
      for (final n in QuranRepository.searchCorpus(corpus, q)) {
        if (seen.add(n)) out.add(n);
      }
    }
    setState(() {
      _results = out;
      _searching = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final repo = ref.quran;
    final scheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(title: Text(context.l10n.search)),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 820),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
                child: TextField(
                  controller: _controller,
                  autofocus: true,
                  onChanged: _onChanged,
                  textInputAction: TextInputAction.search,
                  decoration: InputDecoration(
                    hintText: context.l10n.searchHint,
                    prefixIcon: const Icon(Icons.search),
                    suffixIcon: _query.isEmpty
                        ? null
                        : IconButton(
                            icon: const Icon(Icons.close),
                            onPressed: () {
                              _controller.clear();
                              _onChanged('');
                            },
                          ),
                  ),
                ),
              ),
              if (_query.trim().length < 2)
                Expanded(child: _Hints(onPick: (s) {
                  _controller.text = s;
                  _onChanged(s);
                }))
              else if (_searching)
                const Expanded(child: Center(child: CircularProgressIndicator()))
              else if (_results.isEmpty)
                Expanded(
                  child: Center(
                    child: Text(context.l10n.noAyahMatches(_query),
                        style: TextStyle(color: scheme.onSurfaceVariant)),
                  ),
                )
              else
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                    itemCount: _results.length + 1,
                    itemBuilder: (context, i) {
                      if (i == 0) {
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 8, left: 4),
                          child: Text(
                            context.l10n.resultsCount('${_results.length}${_results.length >= 200 ? '+' : ''}'),
                            style: TextStyle(color: scheme.onSurfaceVariant, fontSize: 13),
                          ),
                        );
                      }
                      final n = _results[i - 1];
                      final ayah = repo.ayah(n);
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: AyahResultTile(
                          ayahNumber: n,
                          query: _query,
                          translation: _corpus?[n - 1],
                          onTap: () =>
                              context.go('/surah/${ayah.surah}?ayah=${ayah.numberInSurah}'),
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

class _Hints extends StatelessWidget {
  const _Hints({required this.onPick});
  final ValueChanged<String> onPick;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    const samples = ['الرحمن', 'Bismillah', 'mercy', 'يس', 'Qul huwa', 'patience'];
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          Icon(Icons.manage_search, size: 56, color: scheme.primary.withValues(alpha: 0.6)),
          const SizedBox(height: 12),
          Text(
            context.l10n.searchWholeQuran,
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: scheme.onSurface),
          ),
          const SizedBox(height: 6),
          Text(
            context.l10n.searchHelp,
            textAlign: TextAlign.center,
            style: TextStyle(color: scheme.onSurfaceVariant, height: 1.5),
          ),
          const SizedBox(height: 20),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            alignment: WrapAlignment.center,
            children: [
              for (final s in samples) ActionChip(label: Text(s), onPressed: () => onPick(s)),
            ],
          ),
        ],
      ),
    );
  }
}

/// A compact ayah preview used by search results and bookmarks.
class AyahResultTile extends ConsumerWidget {
  const AyahResultTile({
    super.key,
    required this.ayahNumber,
    required this.onTap,
    this.translation,
    this.trailing,
    this.query,
  });

  final int ayahNumber;
  final VoidCallback onTap;
  final String? translation;
  final Widget? trailing;

  /// The search text; matching words are highlighted and the snippet is
  /// trimmed around the first match.
  final String? query;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final repo = ref.quran;
    final ayah = repo.ayah(ayahNumber);
    final surah = repo.surah(ayah.surah);
    final settings = ref.watch(settingsProvider);
    final scheme = Theme.of(context).colorScheme;

    return Card(
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  SurahNumberBadge(number: ayah.numberInSurah, size: 32),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      '${surah.englishName} · ${ayah.key}',
                      style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13.5),
                    ),
                  ),
                  Text(
                    surah.name,
                    style: ArabicStyles.surahName(context, size: 16, color: scheme.primary),
                  ),
                  if (trailing != null) trailing!,
                ],
              ),
              const SizedBox(height: 8),
              Builder(builder: (context) {
                final arabicStyle = ArabicStyles.ayah(context, scale: 0.75, font: settings.arabicFont);
                final hi = arabicStyle.copyWith(
                  backgroundColor: highlightColors[0].withValues(alpha: Theme.of(context).brightness == Brightness.dark ? 0.35 : 0.6),
                  color: scheme.onSurface,
                );
                final q = query?.trim() ?? '';
                final matched = q.isEmpty ? const <int>{} : matchedArabicWords(ayah.text, repo.transliterationOf(ayah.number), q);
                return Text.rich(
                  TextSpan(children: arabicSnippetSpans(ayah.text, matched, arabicStyle, hi)),
                  textDirection: TextDirection.rtl,
                  textAlign: TextAlign.right,
                  maxLines: matched.isEmpty ? 2 : 3,
                  overflow: TextOverflow.ellipsis,
                );
              }),
              if (query != null && query!.trim().length >= 2 && !containsArabic(query!) && repo.transliterationOf(ayah.number).toLowerCase().contains(query!.trim().toLowerCase().split(' ').first)) ...[
                const SizedBox(height: 4),
                Text.rich(
                  TextSpan(
                    children: latinSnippetSpans(
                      repo.transliterationOf(ayah.number),
                      query!,
                      TextStyle(fontSize: 12.5, fontStyle: FontStyle.italic, color: scheme.primary, height: 1.4),
                      TextStyle(fontSize: 12.5, fontStyle: FontStyle.italic, fontWeight: FontWeight.w800, color: scheme.primary, height: 1.4,
                          backgroundColor: scheme.primary.withValues(alpha: 0.15)),
                    ),
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
              if (translation != null) ...[
                const SizedBox(height: 4),
                Text.rich(
                  TextSpan(
                    children: query == null || query!.trim().length < 2
                        ? [TextSpan(text: translation!, style: TextStyle(fontSize: 13.5, height: 1.45, color: scheme.onSurfaceVariant))]
                        : latinSnippetSpans(
                            translation!,
                            query!,
                            TextStyle(fontSize: 13.5, height: 1.45, color: scheme.onSurfaceVariant),
                            TextStyle(fontSize: 13.5, height: 1.45, fontWeight: FontWeight.w800, color: scheme.onSurface,
                                backgroundColor: highlightColors[0].withValues(alpha: Theme.of(context).brightness == Brightness.dark ? 0.35 : 0.6)),
                          ),
                  ),
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
