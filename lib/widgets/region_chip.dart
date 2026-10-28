import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/l10n.dart';
import '../data/countries.dart';
import '../data/region.dart';
import '../state/providers.dart';

/// Flag of the current region in the top bar; tap to change it.
class RegionChip extends ConsumerWidget {
  const RegionChip({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final code = ref.watch(settingsProvider.select((s) => s.region));
    final l = context.l10n;
    return Tooltip(
      message: code == null ? l.region : '${countryNameFor(code)} · ${l.changeRegion}',
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: () => showRegionSheet(context),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(Region.flag(code), style: const TextStyle(fontSize: 22)),
              const SizedBox(width: 6),
              Text(code ?? '—', style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13)),
            ],
          ),
        ),
      ),
    );
  }
}

/// Country picker with search and an automatic-detection button.
Future<void> showRegionSheet(BuildContext context) {
  return showModalBottomSheet<void>(
    context: context,
    showDragHandle: true,
    useSafeArea: true,
    isScrollControlled: true,
    builder: (context) => const _RegionSheet(),
  );
}

class _RegionSheet extends ConsumerStatefulWidget {
  const _RegionSheet();

  @override
  ConsumerState<_RegionSheet> createState() => _RegionSheetState();
}

class _RegionSheetState extends ConsumerState<_RegionSheet> {
  String _query = '';
  bool _detecting = false;

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final current = ref.watch(settingsProvider.select((s) => s.region));
    final scheme = Theme.of(context).colorScheme;
    final q = _query.trim().toLowerCase();
    final entries = countries.entries.where((e) => q.isEmpty || e.value.toLowerCase().contains(q) || e.key.toLowerCase() == q).toList()
      ..sort((a, b) => a.value.compareTo(b.value));
    return DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.75,
      maxChildSize: 0.95,
      builder: (_, controller) => Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(Region.flag(current), style: const TextStyle(fontSize: 28)),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(l.region, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
                          Text(current == null ? l.regionHelp : countryNameFor(current),
                              style: TextStyle(fontSize: 12.5, color: scheme.onSurfaceVariant)),
                        ],
                      ),
                    ),
                    FilledButton.tonalIcon(
                      onPressed: _detecting
                          ? null
                          : () async {
                              setState(() => _detecting = true);
                              final code = await Region.detect();
                              if (!context.mounted) return;
                              setState(() => _detecting = false);
                              if (code != null) {
                                ref.read(settingsProvider.notifier).setRegion(code);
                                Navigator.of(context).pop();
                              } else {
                                ScaffoldMessenger.maybeOf(context)?.showSnackBar(SnackBar(content: Text(l.regionNotDetected)));
                              }
                            },
                      icon: _detecting
                          ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2))
                          : const Icon(Icons.my_location, size: 18),
                      label: Text(l.detectRegion),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                TextField(
                  autofocus: false,
                  onChanged: (v) => setState(() => _query = v),
                  decoration: InputDecoration(hintText: l.findCountry, prefixIcon: const Icon(Icons.search), isDense: true),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              controller: controller,
              itemCount: entries.length,
              itemBuilder: (context, i) {
                final e = entries[i];
                final selected = e.key == current;
                return ListTile(
                  dense: true,
                  leading: Text(Region.flag(e.key), style: const TextStyle(fontSize: 22)),
                  title: Text(e.value),
                  trailing: selected ? Icon(Icons.check, color: scheme.primary) : Text(e.key, style: TextStyle(fontSize: 11, color: scheme.outline)),
                  selected: selected,
                  onTap: () {
                    ref.read(settingsProvider.notifier).setRegion(e.key);
                    Navigator.of(context).pop();
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
