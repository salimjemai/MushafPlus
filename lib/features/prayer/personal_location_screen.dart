import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/l10n.dart';
import '../../data/countries.dart';
import '../../data/geocoding_service.dart';
import '../../data/masjid.dart';
import '../../data/prayer_times.dart';
import '../../data/region.dart';
import '../../data/reminders.dart';
import '../../state/masjid_providers.dart';
import '../../state/providers.dart';
import 'locate.dart';

/// Where the user prays: precise device location, or a city typed with the
/// address fields that country uses. Separate from masjid profiles.
class PersonalLocationScreen extends ConsumerStatefulWidget {
  const PersonalLocationScreen({super.key});

  @override
  ConsumerState<PersonalLocationScreen> createState() => _PersonalLocationScreenState();
}

class _PersonalLocationScreenState extends ConsumerState<PersonalLocationScreen> {
  late final TextEditingController _countryName;
  final _countryFocus = FocusNode();
  final _city = TextEditingController();
  final _state = TextEditingController();
  final _postal = TextEditingController();
  String _cc = '';
  String _methodId = 'mwl';
  bool _asrHanafi = false;
  bool _busy = false;
  String? _status;
  List<GeoResult> _candidates = const [];
  String? _tz;

  @override
  void initState() {
    super.initState();
    final current = ref.read(myLocationProvider);
    _cc = current?.countryCode ?? ref.read(settingsProvider).region ?? '';
    _countryName = TextEditingController(text: countryNameFor(_cc.isEmpty ? null : _cc));
    _city.text = current?.city ?? '';
    _state.text = current?.state ?? '';
    _postal.text = current?.postalCode ?? '';
    _methodId = current?.methodId ?? Region.methodFor(_cc.isEmpty ? null : _cc);
    _asrHanafi = current?.asrHanafi ?? Region.hanafiFor(_cc.isEmpty ? null : _cc);
    if (current != null) _tz = current.timezone;
  }

  @override
  void dispose() {
    for (final c in [_countryName, _city, _state, _postal]) {
      c.dispose();
    }
    _countryFocus.dispose();
    super.dispose();
  }

  void _countryChanged(String? code) {
    if (code == null || code == _cc) return;
    setState(() {
      _cc = code;
      _methodId = Region.methodFor(code);
      _asrHanafi = Region.hanafiFor(code);
    });
  }

  /// Address fields in the order and wording that country uses.
  List<(TextEditingController, String)> _fields(AppLocalizations l) => switch (_cc) {
        'US' => [(_city, l.city), (_state, l.stateProvince), (_postal, l.zip)],
        'CA' => [(_city, l.city), (_state, l.province), (_postal, l.postcode)],
        'GB' || 'IE' => [(_city, l.town), (_postal, l.postcode)],
        'AU' || 'NZ' => [(_city, l.suburb), (_state, l.stateProvince), (_postal, l.postcode)],
        _ => [(_city, l.city), (_state, l.regionOptional), (_postal, l.postalOptional)],
      };

  Future<void> _useGps() async {
    setState(() {
      _busy = true;
      _status = context.l10n.gettingPosition;
    });
    try {
      final m = await locateDevice(ref);
      await _save(m);
    } catch (e) {
      if (mounted) setState(() => _status = context.l10n.couldNotGetLocation('$e'));
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _find() async {
    final l = context.l10n;
    if (_city.text.trim().isEmpty && _postal.text.trim().isEmpty) {
      setState(() => _status = l.enterZipOrCity);
      return;
    }
    setState(() {
      _busy = true;
      _status = l.lookingUpAddress;
      _candidates = const [];
    });
    try {
      final found = await ref.read(geocodingServiceProvider).resolve(
            street: '',
            city: _city.text,
            state: _state.text,
            postalCode: _postal.text,
            country: countryCodeFor(_countryName.text) ?? _countryName.text,
            language: Localizations.localeOf(context).languageCode,
          );
      if (!mounted) return;
      if (found.results.isEmpty) {
        setState(() => _status = l.noMatchTryCountry);
      } else if (found.results.length == 1) {
        await _apply(found.results.first);
      } else {
        setState(() {
          _candidates = found.results;
          _status = l.chooseLocation;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _status = l.lookupFailed('$e'));
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _apply(GeoResult r) async {
    setState(() {
      _busy = true;
      _candidates = const [];
      _status = context.l10n.resolvingTimeZone;
    });
    try {
      final tz = await ref.read(geocodingServiceProvider).timezoneFor(r.latitude, r.longitude);
      if (!mounted) return;
      _tz = tz;
      if (r.countryCode != null) {
        _countryName.text = countryNameFor(r.countryCode);
        _countryChanged(r.countryCode);
      }
      if (r.city != null && _city.text.trim().isEmpty) _city.text = r.city!;
      setState(() => _status = context.l10n.located(r.displayName));
      await _save(Masjid(
        id: 'me',
        name: r.city ?? _city.text.trim(),
        city: r.city ?? _city.text.trim(),
        state: r.state ?? _state.text.trim(),
        postalCode: r.postcode ?? _postal.text.trim(),
        countryCode: (r.countryCode ?? _cc).toUpperCase(),
        latitude: r.latitude,
        longitude: r.longitude,
        timezone: tz,
        methodId: _methodId,
        asrHanafi: _asrHanafi,
      ));
    } catch (e) {
      if (mounted) setState(() => _status = context.l10n.lookupFailed('$e'));
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _save(Masjid m) async {
    final place = m.copyWith(methodId: _methodId, asrHanafi: _asrHanafi);
    await ref.read(myLocationProvider.notifier).save(place);
    ref.read(settingsProvider.notifier).setPrayerMode('personal');
    if (!mounted) return;
    await rescheduleReminders(ref, context.l10n);
    if (!mounted) return;
    if (context.canPop()) {
      context.pop();
    } else {
      context.go('/prayer');
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final scheme = Theme.of(context).colorScheme;
    final current = ref.watch(myLocationProvider);
    return Scaffold(
      appBar: AppBar(title: Text(l.myPrayerTimes)),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 640),
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Text(l.personalIntro, style: TextStyle(color: scheme.onSurfaceVariant, height: 1.45)),
              const SizedBox(height: 14),
              FilledButton.icon(
                onPressed: _busy ? null : _useGps,
                icon: _busy && _status == l.gettingPosition
                    ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                    : const Icon(Icons.my_location),
                label: Text(l.useMyLocation),
              ),
              const SizedBox(height: 18),
              Row(children: [
                const Expanded(child: Divider()),
                Padding(padding: const EdgeInsets.symmetric(horizontal: 12), child: Text(l.orEnterCity, style: TextStyle(color: scheme.onSurfaceVariant))),
                const Expanded(child: Divider()),
              ]),
              const SizedBox(height: 12),
              RawAutocomplete<String>(
                textEditingController: _countryName,
                focusNode: _countryFocus,
                optionsBuilder: (v) => countrySuggestions(v.text),
                onSelected: (name) {
                  _countryName.text = name;
                  _countryChanged(countryCodeFor(name));
                },
                fieldViewBuilder: (context, controller, focus, onSubmit) => TextFormField(
                  controller: controller,
                  focusNode: focus,
                  decoration: InputDecoration(
                    labelText: l.countryLabel,
                    prefixText: _cc.isEmpty ? null : '${Region.flag(_cc)} ',
                  ),
                  onChanged: (v) {
                    final c = countryCodeFor(v);
                    if (c != null) _countryChanged(c);
                  },
                  onFieldSubmitted: (_) => onSubmit(),
                ),
                optionsViewBuilder: (context, onSelected, options) => Align(
                  alignment: AlignmentDirectional.topStart,
                  child: Material(
                    elevation: 4,
                    borderRadius: BorderRadius.circular(12),
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxHeight: 240, maxWidth: 360),
                      child: ListView(
                        shrinkWrap: true,
                        padding: EdgeInsets.zero,
                        children: [
                          for (final o in options)
                            ListTile(dense: true, leading: Text(Region.flag(countryCodeFor(o)), style: const TextStyle(fontSize: 20)), title: Text(o), onTap: () => onSelected(o)),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 10),
              for (final (controller, label) in _fields(l)) ...[
                TextFormField(
                  controller: controller,
                  decoration: InputDecoration(labelText: label),
                  textInputAction: TextInputAction.search,
                  onFieldSubmitted: (_) => _find(),
                ),
                const SizedBox(height: 10),
              ],
              FilledButton.tonalIcon(
                onPressed: _busy ? null : _find,
                icon: const Icon(Icons.search),
                label: Text(l.findLocation),
              ),
              if (_status != null) ...[
                const SizedBox(height: 8),
                Text(_status!, style: TextStyle(fontSize: 12.5, color: scheme.onSurfaceVariant)),
              ],
              for (final c in _candidates)
                Card(
                  child: ListTile(
                    leading: const Icon(Icons.place_outlined),
                    title: Text(c.displayName, maxLines: 2, overflow: TextOverflow.ellipsis),
                    onTap: _busy ? null : () => _apply(c),
                  ),
                ),
              const SizedBox(height: 18),
              Text(l.calculation.toUpperCase(), style: TextStyle(fontSize: 11, letterSpacing: 1.1, fontWeight: FontWeight.w700, color: scheme.onSurfaceVariant)),
              const SizedBox(height: 6),
              DropdownButtonFormField<String>(
                initialValue: calculationMethods.any((m) => m.id == _methodId) ? _methodId : 'mwl',
                decoration: InputDecoration(labelText: l.calculationMethod),
                items: [for (final m in calculationMethods) DropdownMenuItem(value: m.id, child: Text(m.name, overflow: TextOverflow.ellipsis))],
                onChanged: (v) => setState(() => _methodId = v ?? _methodId),
              ),
              const SizedBox(height: 10),
              SegmentedButton<bool>(
                segments: [
                  ButtonSegment(value: false, label: Text(l.asrShafiiFull)),
                  ButtonSegment(value: true, label: Text(l.asrHanafiFull)),
                ],
                selected: {_asrHanafi},
                onSelectionChanged: (v) => setState(() => _asrHanafi = v.first),
              ),
              if (current != null) ...[
                const SizedBox(height: 18),
                OutlinedButton.icon(
                  onPressed: _busy
                      ? null
                      : () => _save(current.copyWith(methodId: _methodId, asrHanafi: _asrHanafi)),
                  icon: const Icon(Icons.save_outlined),
                  label: Text(l.save),
                ),
                const SizedBox(height: 6),
                Text('${current.name} · ${current.latitude.toStringAsFixed(4)}, ${current.longitude.toStringAsFixed(4)} · ${_tz ?? current.timezone}',
                    style: TextStyle(fontSize: 11.5, color: scheme.outline)),
              ],
              const SizedBox(height: 12),
              Text(l.masjidAdminHint, style: TextStyle(fontSize: 12, color: scheme.outline, height: 1.4)),
            ],
          ),
        ),
      ),
    );
  }
}
