import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../data/translation_service.dart';
import '../../state/providers.dart';
import '../search/search_screen.dart';

class BookmarksScreen extends ConsumerWidget {
  const BookmarksScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bookmarks = ref.watch(bookmarksProvider);
    final repo = ref.quran;
    final scheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(title: Text('Saved ayahs${bookmarks.isEmpty ? '' : ' (${bookmarks.length})'}')),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 820),
          child: bookmarks.isEmpty
              ? Padding(
                  padding: const EdgeInsets.all(32),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.bookmark_add_outlined,
                          size: 56, color: scheme.primary.withValues(alpha: 0.6)),
                      const SizedBox(height: 12),
                      const Text('No bookmarks yet',
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
                      const SizedBox(height: 6),
                      Text(
                        'Tap the bookmark icon on any ayah while reading to save it here.',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: scheme.onSurfaceVariant, height: 1.5),
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
                  itemCount: bookmarks.length,
                  itemBuilder: (context, i) {
                    final b = bookmarks[i];
                    final ayah = repo.ayah(b.ayahNumber);
                    final translation = ref.watch(surahTranslationProvider(
                      (surah: ayah.surah, edition: TranslationService.defaultEdition),
                    ));
                    return Dismissible(
                      key: ValueKey('bm-${b.ayahNumber}'),
                      direction: DismissDirection.endToStart,
                      background: Container(
                        alignment: Alignment.centerRight,
                        padding: const EdgeInsets.only(right: 24),
                        decoration: BoxDecoration(
                          color: scheme.errorContainer,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Icon(Icons.delete_outline, color: scheme.onErrorContainer),
                      ),
                      onDismissed: (_) =>
                          ref.read(bookmarksProvider.notifier).remove(b.ayahNumber),
                      child: Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: AyahResultTile(
                          ayahNumber: b.ayahNumber,
                          translation: translation.asData?.value[ayah.numberInSurah - 1],
                          trailing: IconButton(
                            tooltip: 'Remove',
                            icon: const Icon(Icons.bookmark_remove_outlined, size: 20),
                            onPressed: () =>
                                ref.read(bookmarksProvider.notifier).remove(b.ayahNumber),
                          ),
                          onTap: () =>
                              context.go('/surah/${ayah.surah}?ayah=${ayah.numberInSurah}'),
                        ),
                      ),
                    );
                  },
                ),
        ),
      ),
    );
  }
}
