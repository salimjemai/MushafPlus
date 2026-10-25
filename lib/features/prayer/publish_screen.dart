import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../core/l10n.dart';
import '../../data/masjid.dart';
import '../../data/masjid_share.dart';
import '../../state/masjid_providers.dart';
import 'prayer_screen.dart' show copyWithToast;
import 'widget_screen.dart';

/// "Share & embed": public widget links, iframe embed code and a live
/// preview for one masjid. Everything is carried in the link, so no server
/// is involved.
class PublishScreen extends ConsumerStatefulWidget {
  const PublishScreen({super.key, this.masjidId});
  final String? masjidId;

  @override
  ConsumerState<PublishScreen> createState() => _PublishScreenState();
}

class _PublishScreenState extends ConsumerState<PublishScreen> {
  WidgetView _preview = WidgetView.combined;
  bool _dark = false;

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final masjid = ref.read(masjidsProvider.notifier).byId(widget.masjidId) ?? ref.watch(selectedMasjidProvider);
    final scheme = Theme.of(context).colorScheme;
    if (masjid == null) {
      return Scaffold(appBar: AppBar(title: Text(l.shareEmbed)), body: Center(child: Text(l.setUpMasjidFirst)));
    }

    final theme = _dark ? 'dark' : null;
    final links = <_Link>[
      _Link(l.combinedWidget, Icons.view_agenda_outlined, widgetUrl(masjid, theme: theme), 420, 820),
      _Link(l.dailyWidget, Icons.calendar_view_day_outlined, widgetUrl(masjid, view: WidgetView.daily, theme: theme), 420, 620),
      _Link(l.jumuahWidget, Icons.mosque_outlined, widgetUrl(masjid, view: WidgetView.jumuah, theme: theme), 420, 480),
      _Link(l.compactWidget, Icons.crop_portrait, widgetUrl(masjid, view: WidgetView.compact, theme: theme), 360, 720),
      _Link(l.tvDisplay, Icons.tv_outlined, tvUrl(masjid), 1280, 720),
    ];

    return Scaffold(
      appBar: AppBar(title: Text(l.shareEmbed)),
      body: LayoutBuilder(
        builder: (context, c) {
          final wide = c.maxWidth >= 900;
          final list = ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Text(masjid.name, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800)),
              const SizedBox(height: 4),
              Text(l.embedHelp, style: TextStyle(color: scheme.onSurfaceVariant, height: 1.45)),
              const SizedBox(height: 12),
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: Text(l.darkWidget),
                value: _dark,
                onChanged: (v) => setState(() => _dark = v),
              ),
              const SizedBox(height: 4),
              Text(l.widgetLinks.toUpperCase(), style: TextStyle(fontSize: 11, letterSpacing: 1.2, fontWeight: FontWeight.w700, color: scheme.onSurfaceVariant)),
              const SizedBox(height: 6),
              for (final k in links)
                Card(
                  clipBehavior: Clip.antiAlias,
                  child: ListTile(
                    leading: Icon(k.icon, color: scheme.primary),
                    title: Text(k.title, style: const TextStyle(fontWeight: FontWeight.w700)),
                    subtitle: Text(k.url, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 11.5)),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(tooltip: l.copy, icon: const Icon(Icons.link), onPressed: () => copyWithToast(context, k.url, l.linkCopied)),
                        IconButton(
                          tooltip: l.openLink,
                          icon: const Icon(Icons.open_in_new),
                          onPressed: () => launchUrl(Uri.parse(k.url), mode: LaunchMode.externalApplication, webOnlyWindowName: '_blank'),
                        ),
                      ],
                    ),
                  ),
                ),
              const SizedBox(height: 16),
              Text(l.embedCode.toUpperCase(), style: TextStyle(fontSize: 11, letterSpacing: 1.2, fontWeight: FontWeight.w700, color: scheme.onSurfaceVariant)),
              const SizedBox(height: 6),
              for (final k in links.where((k) => k.width < 1000))
                Card(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(14, 10, 8, 10),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(k.title, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13)),
                              const SizedBox(height: 4),
                              Text(
                                iframeSnippet(k.url, '${masjid.name} · ${k.title}', width: k.width, height: k.height),
                                maxLines: 3,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(fontFamily: 'monospace', fontSize: 11, color: scheme.onSurfaceVariant),
                              ),
                            ],
                          ),
                        ),
                        IconButton(
                          tooltip: l.copy,
                          icon: const Icon(Icons.copy_outlined),
                          onPressed: () => copyWithToast(
                              context, iframeSnippet(k.url, '${masjid.name} · ${k.title}', width: k.width, height: k.height), l.codeCopied),
                        ),
                      ],
                    ),
                  ),
                ),
              if (!wide) ...[
                const SizedBox(height: 16),
                _previewHeader(context),
                const SizedBox(height: 8),
                SizedBox(height: 620, child: _previewBox(masjid)),
              ],
              const SizedBox(height: 24),
            ],
          );
          if (!wide) return list;
          return Row(
            children: [
              Expanded(flex: 5, child: list),
              const VerticalDivider(width: 1),
              Expanded(
                flex: 4,
                child: Column(
                  children: [
                    Padding(padding: const EdgeInsets.fromLTRB(16, 12, 16, 8), child: _previewHeader(context)),
                    Expanded(child: Padding(padding: const EdgeInsets.fromLTRB(16, 0, 16, 16), child: _previewBox(masjid))),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _previewHeader(BuildContext context) {
    final l = context.l10n;
    return Row(
      children: [
        Text(l.preview, style: const TextStyle(fontWeight: FontWeight.w700)),
        const Spacer(),
        SegmentedButton<WidgetView>(
          showSelectedIcon: false,
          style: const ButtonStyle(visualDensity: VisualDensity.compact),
          segments: [
            ButtonSegment(value: WidgetView.combined, icon: const Icon(Icons.view_agenda_outlined, size: 16), tooltip: l.combinedWidget),
            ButtonSegment(value: WidgetView.daily, icon: const Icon(Icons.calendar_view_day_outlined, size: 16), tooltip: l.dailyWidget),
            ButtonSegment(value: WidgetView.jumuah, icon: const Icon(Icons.mosque_outlined, size: 16), tooltip: l.jumuahWidget),
            ButtonSegment(value: WidgetView.compact, icon: const Icon(Icons.crop_portrait, size: 16), tooltip: l.compactWidget),
          ],
          selected: {_preview},
          onSelectionChanged: (s) => setState(() => _preview = s.first),
        ),
      ],
    );
  }

  Widget _previewBox(Masjid masjid) {
    return Center(
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: _preview == WidgetView.compact ? 360 : 420),
        child: Material(
          elevation: 3,
          borderRadius: BorderRadius.circular(14),
          clipBehavior: Clip.antiAlias,
          child: PrayerWidgetScreen(
            key: ValueKey('preview-${_preview.name}-$_dark'),
            code: encodeMasjid(masjid),
            view: _preview,
            theme: _dark ? 'dark' : 'light',
          ),
        ),
      ),
    );
  }
}

class _Link {
  const _Link(this.title, this.icon, this.url, this.width, this.height);
  final String title;
  final IconData icon;
  final String url;
  final int width;
  final int height;
}
