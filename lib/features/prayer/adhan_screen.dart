import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../core/l10n.dart';
import '../../data/adhans.dart';
import '../../data/audio_backend.dart';
import '../../data/downloads.dart';
import '../../state/providers.dart';

/// Browse, play, download and choose the default adhan recording.
class AdhanScreen extends ConsumerStatefulWidget {
  const AdhanScreen({super.key, this.autoplay = false, this.fajr = false});
  final bool autoplay;
  final bool fajr;

  @override
  ConsumerState<AdhanScreen> createState() => _AdhanScreenState();
}

class _AdhanScreenState extends ConsumerState<AdhanScreen> {
  late final AyahPlayer _player = createAyahPlayer();
  final _subs = <StreamSubscription<dynamic>>[];
  String? _playingId;
  bool _playing = false;
  bool _loading = false;
  Duration _position = Duration.zero;
  Duration _duration = Duration.zero;
  final _downloading = <String>{};
  String? _error;

  @override
  void initState() {
    super.initState();
    if (widget.autoplay) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        final chosen = ref.read(settingsProvider).adhanId;
        _toggle(adhanFor(chosen, fajr: widget.fajr));
      });
    }
    _subs.addAll([
      _player.status.listen((s) => setState(() {
            _playing = s == PlayerStatus.playing;
            if (s == PlayerStatus.playing) _loading = false;
            if (s == PlayerStatus.stopped) {
              _loading = false;
            }
          })),
      _player.position.listen((p) => setState(() => _position = p)),
      _player.duration.listen((d) => setState(() => _duration = d)),
      _player.completed.listen((_) => setState(() {
            _playing = false;
            _position = Duration.zero;
          })),
      _player.errors.listen((e) => setState(() {
            _error = e;
            _loading = false;
          })),
    ]);
  }

  @override
  void dispose() {
    for (final s in _subs) {
      s.cancel();
    }
    _player.dispose();
    super.dispose();
  }

  Future<void> _toggle(Adhan a) async {
    if (_playingId == a.id) {
      if (_playing) {
        await _player.pause();
      } else {
        await _player.resume();
      }
      return;
    }
    setState(() {
      _playingId = a.id;
      _loading = true;
      _error = null;
      _position = Duration.zero;
      _duration = Duration.zero;
    });
    try {
      var source = a.url;
      if (Downloads.supportsCache) source = await Downloads.cachedFile('adhans', a.fileName) ?? a.url;
      await _player.play(source);
    } catch (e) {
      setState(() {
        _error = '$e';
        _loading = false;
      });
    }
  }

  Future<void> _download(Adhan a) async {
    final l = context.l10n;
    setState(() => _downloading.add(a.id));
    try {
      await Downloads.saveUrl(a.url, 'adhan-${a.fileName}');
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(l.downloaded(a.name))));
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(l.downloadFailed('$e'))));
    } finally {
      if (mounted) setState(() => _downloading.remove(a.id));
    }
  }

  String _fmt(Duration d) => '${d.inMinutes}:${(d.inSeconds % 60).toString().padLeft(2, '0')}';

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final scheme = Theme.of(context).colorScheme;
    final chosen = ref.watch(settingsProvider.select((s) => s.adhanId));

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.canPop() ? context.pop() : context.go('/prayer'),
        ),
        title: Text(l.adhan),
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 760),
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Text(l.adhanIntro, style: TextStyle(color: scheme.onSurfaceVariant, height: 1.5, fontSize: 13.5)),
              if (_error != null) ...[
                const SizedBox(height: 8),
                Text(_error!, style: TextStyle(color: scheme.error, fontSize: 13)),
              ],
              const SizedBox(height: 12),
              for (final a in adhans) ...[
                Card(
                  color: a.id == chosen ? scheme.primary.withValues(alpha: 0.08) : null,
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(8, 6, 8, 6),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            IconButton.filledTonal(
                              tooltip: _playingId == a.id && _playing ? l.pause : l.play,
                              onPressed: () => _toggle(a),
                              icon: _playingId == a.id && _loading
                                  ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2))
                                  : Icon(_playingId == a.id && _playing ? Icons.pause : Icons.play_arrow),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(a.name, style: const TextStyle(fontWeight: FontWeight.w700)),
                                  Text(
                                    '${a.place} · ${_fmt(Duration(seconds: a.seconds))}${a.fajr ? ' · ${l.fajr}' : ''}',
                                    style: TextStyle(fontSize: 12.5, color: scheme.onSurfaceVariant),
                                  ),
                                  InkWell(
                                    onTap: () => launchUrl(Uri.parse(a.sourceUrl), mode: LaunchMode.externalApplication, webOnlyWindowName: '_blank'),
                                    child: Text(l.recordingCredit(a.author, a.license), style: TextStyle(fontSize: 11, color: scheme.primary)),
                                  ),
                                ],
                              ),
                            ),
                            IconButton(
                              tooltip: l.download,
                              onPressed: _downloading.contains(a.id) ? null : () => _download(a),
                              icon: _downloading.contains(a.id)
                                  ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2))
                                  : const Icon(Icons.download_outlined),
                            ),
                            IconButton(
                              tooltip: l.chooseAdhan,
                              onPressed: () => ref.read(settingsProvider.notifier).setAdhanId(a.id),
                              icon: Icon(a.id == chosen ? Icons.check_circle : Icons.radio_button_unchecked,
                                  color: a.id == chosen ? scheme.primary : scheme.onSurfaceVariant),
                            ),
                          ],
                        ),
                        if (_playingId == a.id)
                          Padding(
                            padding: const EdgeInsets.fromLTRB(8, 0, 8, 4),
                            child: Row(
                              children: [
                                Text(_fmt(_position), style: const TextStyle(fontSize: 11)),
                                Expanded(
                                  child: Slider(
                                    value: _duration.inMilliseconds == 0
                                        ? 0
                                        : (_position.inMilliseconds / _duration.inMilliseconds).clamp(0.0, 1.0),
                                    onChanged: (v) => _player.seek(Duration(milliseconds: (v * _duration.inMilliseconds).round())),
                                  ),
                                ),
                                Text(_fmt(_duration), style: const TextStyle(fontSize: 11)),
                              ],
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 8),
              ],
              const SizedBox(height: 8),
              Text(l.adhanCredits, style: TextStyle(fontSize: 11.5, color: scheme.outline, height: 1.4)),
            ],
          ),
        ),
      ),
    );
  }
}
