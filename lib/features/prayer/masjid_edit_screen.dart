import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:go_router/go_router.dart';

import '../../data/geocoding_service.dart';
import '../../data/masjid.dart';
import '../../data/prayer_times.dart';
import '../../state/masjid_providers.dart';

/// Create or edit a masjid: address → precise coordinates + time zone,
/// calculation settings, iqama rules and Jumu'ah services.
class MasjidEditScreen extends ConsumerStatefulWidget {
  const MasjidEditScreen({super.key, this.masjidId});
  final String? masjidId;

  @override
  ConsumerState<MasjidEditScreen> createState() => _MasjidEditScreenState();
}

class _MasjidEditScreenState extends ConsumerState<MasjidEditScreen> {
  final _form = GlobalKey<FormState>();
  late final TextEditingController _name;
  late final TextEditingController _street;
  late final TextEditingController _city;
  late final TextEditingController _state;
  late final TextEditingController _postal;
  late final TextEditingController _country;
  late final TextEditingController _lat;
  late final TextEditingController _lng;
  late final TextEditingController _tz;

  String _methodId = 'isna';
  bool _asrHanafi = false;
  int _dhuhrOffset = 0;
  int _maghribOffset = 0;
  late Map<Prayer, int> _adjustments;
  late Map<Prayer, IqamaRule> _iqama;
  late List<JumuahService> _jumuah;
  int _hijriAdjustment = 0;

  bool _busy = false;
  String? _status;
  List<GeoResult> _candidates = const [];
  bool _located = false;

  Masjid? get _existing => ref.read(masjidsProvider.notifier).byId(widget.masjidId);

  @override
  void initState() {
    super.initState();
    final m = _existing;
    _name = TextEditingController(text: m?.name ?? '');
    _street = TextEditingController(text: m?.street ?? '');
    _city = TextEditingController(text: m?.city ?? '');
    _state = TextEditingController(text: m?.state ?? '');
    _postal = TextEditingController(text: m?.postalCode ?? '');
    _country = TextEditingController(text: m?.countryCode ?? '');
    _lat = TextEditingController(text: m == null ? '' : m.latitude.toStringAsFixed(6));
    _lng = TextEditingController(text: m == null ? '' : m.longitude.toStringAsFixed(6));
    _tz = TextEditingController(text: m?.timezone ?? '');
    _methodId = m?.methodId ?? 'isna';
    _asrHanafi = m?.asrHanafi ?? false;
    _dhuhrOffset = m?.dhuhrOffsetMinutes ?? 0;
    _maghribOffset = m?.maghribOffsetMinutes ?? 0;
    _adjustments = {...?m?.adjustments};
    _iqama = {...?m?.iqama};
    _jumuah = [...?m?.jumuah];
    _hijriAdjustment = m?.hijriAdjustment ?? 0;
    _located = m != null;
  }

  @override
  void dispose() {
    for (final c in [_name, _street, _city, _state, _postal, _country, _lat, _lng, _tz]) {
      c.dispose();
    }
    super.dispose();
  }

  // ---- geocoding -----------------------------------------------------------

  Future<void> _find() async {
    final geo = ref.read(geocodingServiceProvider);
    final query = [_street.text, _city.text, _state.text, _postal.text, _country.text]
        .map((s) => s.trim())
        .where((s) => s.isNotEmpty)
        .join(', ');
    if (query.isEmpty) {
      setState(() => _status = 'Enter at least a ZIP / postal code or a city.');
      return;
    }
    setState(() {
      _busy = true;
      _status = 'Looking up the address…';
      _candidates = const [];
    });
    try {
      var results = await geo.searchAddress(query, countryCode: _country.text.trim().length == 2 ? _country.text.trim() : null);
      if (results.isEmpty && _postal.text.trim().isNotEmpty && _country.text.trim().length == 2) {
        final z = await geo.lookupPostalCode(_country.text.trim(), _postal.text.trim());
        if (z != null) results = [z];
      }
      if (results.isEmpty) {
        setState(() => _status = 'No match. Try adding the city and a 2-letter country code (e.g. US, GB, FR).');
      } else if (results.length == 1) {
        await _apply(results.first);
      } else {
        setState(() {
          _candidates = results;
          _status = 'Choose the correct location:';
        });
      }
    } catch (e) {
      setState(() => _status = 'Lookup failed: $e');
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _apply(GeoResult r) async {
    setState(() {
      _busy = true;
      _candidates = const [];
      _status = 'Resolving time zone…';
      _lat.text = r.latitude.toStringAsFixed(6);
      _lng.text = r.longitude.toStringAsFixed(6);
      if (_city.text.trim().isEmpty && r.city != null) _city.text = r.city!;
      if (_state.text.trim().isEmpty && r.state != null) _state.text = r.state!;
      if (_postal.text.trim().isEmpty && r.postcode != null) _postal.text = r.postcode!;
      if (_country.text.trim().isEmpty && r.countryCode != null) _country.text = r.countryCode!;
    });
    try {
      final tzId = await ref.read(geocodingServiceProvider).timezoneFor(r.latitude, r.longitude);
      setState(() {
        _tz.text = tzId;
        _located = true;
        _status = 'Located: ${r.displayName}';
      });
    } catch (e) {
      setState(() {
        _located = _tz.text.trim().isNotEmpty;
        _status = 'Coordinates set, but time zone lookup failed ($e). Enter an IANA zone such as America/New_York.';
      });
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _useDevice() async {
    setState(() {
      _busy = true;
      _status = 'Getting your position…';
    });
    try {
      var permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied || permission == LocationPermission.deniedForever) {
        throw Exception('location permission denied');
      }
      final pos = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(accuracy: LocationAccuracy.best),
      ).timeout(const Duration(seconds: 30));
      final geo = ref.read(geocodingServiceProvider);
      final r = await geo.reverse(pos.latitude, pos.longitude) ??
          GeoResult(latitude: pos.latitude, longitude: pos.longitude, displayName: '${pos.latitude}, ${pos.longitude}');
      if (_street.text.trim().isEmpty) _street.text = r.displayName.split(',').take(2).join(',').trim();
      await _apply(r);
    } catch (e) {
      setState(() {
        _busy = false;
        _status = 'Could not use device location: $e';
      });
    }
  }

  // ---- save -----------------------------------------------------------------

  Future<void> _save() async {
    if (!(_form.currentState?.validate() ?? false)) return;
    final lat = double.tryParse(_lat.text.trim());
    final lng = double.tryParse(_lng.text.trim());
    if (lat == null || lng == null || _tz.text.trim().isEmpty) {
      setState(() => _status = 'Tap "Find location" first so the coordinates and time zone are set.');
      return;
    }
    final m = Masjid(
      id: _existing?.id ?? DateTime.now().millisecondsSinceEpoch.toRadixString(36),
      name: _name.text.trim(),
      street: _street.text.trim(),
      city: _city.text.trim(),
      state: _state.text.trim(),
      postalCode: _postal.text.trim(),
      countryCode: _country.text.trim().toUpperCase(),
      latitude: lat,
      longitude: lng,
      timezone: _tz.text.trim(),
      methodId: _methodId,
      asrHanafi: _asrHanafi,
      dhuhrOffsetMinutes: _dhuhrOffset,
      maghribOffsetMinutes: _maghribOffset,
      adjustments: _adjustments,
      iqama: _iqama,
      jumuah: _jumuah,
      hijriAdjustment: _hijriAdjustment,
    );
    await ref.read(masjidsProvider.notifier).save(m);
    ref.read(masjidsProvider.notifier).select(m.id);
    if (mounted) context.canPop() ? context.pop() : context.go('/prayer');
  }

  // ---- UI -------------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.canPop() ? context.pop() : context.go('/prayer'),
        ),
        title: Text(widget.masjidId == null ? 'Add masjid' : 'Edit masjid'),
        actions: [
          TextButton.icon(onPressed: _busy ? null : _save, icon: const Icon(Icons.check), label: const Text('Save')),
        ],
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 760),
          child: Form(
            key: _form,
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                _section('Masjid'),
                TextFormField(
                  controller: _name,
                  decoration: const InputDecoration(labelText: 'Masjid name', prefixIcon: Icon(Icons.mosque_outlined)),
                  validator: (v) => (v ?? '').trim().isEmpty ? 'Enter a name' : null,
                  textInputAction: TextInputAction.next,
                ),
                const SizedBox(height: 16),
                _section('Address'),
                TextFormField(controller: _street, decoration: const InputDecoration(labelText: 'Street address'), textInputAction: TextInputAction.next),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(flex: 3, child: TextFormField(controller: _city, decoration: const InputDecoration(labelText: 'City'))),
                    const SizedBox(width: 10),
                    Expanded(flex: 2, child: TextFormField(controller: _state, decoration: const InputDecoration(labelText: 'State / Province'))),
                  ],
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(child: TextFormField(controller: _postal, decoration: const InputDecoration(labelText: 'ZIP / Postal code'))),
                    const SizedBox(width: 10),
                    Expanded(
                      child: TextFormField(
                        controller: _country,
                        decoration: const InputDecoration(labelText: 'Country code (US, GB, FR…)'),
                        textCapitalization: TextCapitalization.characters,
                        maxLength: 2,
                        buildCounter: (_, {required currentLength, required isFocused, maxLength}) => null,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      child: FilledButton.icon(
                        onPressed: _busy ? null : _find,
                        icon: _busy
                            ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                            : const Icon(Icons.search),
                        label: const Text('Find location'),
                      ),
                    ),
                    const SizedBox(width: 8),
                    OutlinedButton.icon(
                      onPressed: _busy ? null : _useDevice,
                      icon: const Icon(Icons.my_location),
                      label: const Text('Device GPS'),
                    ),
                  ],
                ),
                if (_status != null) ...[
                  const SizedBox(height: 8),
                  Text(_status!, style: TextStyle(fontSize: 13, color: _located ? scheme.primary : scheme.onSurfaceVariant)),
                ],
                for (final c in _candidates)
                  Card(
                    margin: const EdgeInsets.only(top: 6),
                    child: ListTile(
                      leading: const Icon(Icons.place_outlined),
                      title: Text(c.displayName, maxLines: 2, overflow: TextOverflow.ellipsis),
                      subtitle: Text('${c.latitude.toStringAsFixed(5)}, ${c.longitude.toStringAsFixed(5)}'),
                      onTap: () => _apply(c),
                    ),
                  ),
                const SizedBox(height: 12),
                ExpansionTile(
                  title: const Text('Coordinates & time zone'),
                  subtitle: Text(_located ? '${_lat.text}, ${_lng.text} · ${_tz.text}' : 'Set automatically from the address'),
                  tilePadding: EdgeInsets.zero,
                  childrenPadding: const EdgeInsets.only(bottom: 8),
                  children: [
                    Row(
                      children: [
                        Expanded(child: TextFormField(controller: _lat, decoration: const InputDecoration(labelText: 'Latitude'), keyboardType: const TextInputType.numberWithOptions(decimal: true, signed: true))),
                        const SizedBox(width: 10),
                        Expanded(child: TextFormField(controller: _lng, decoration: const InputDecoration(labelText: 'Longitude'), keyboardType: const TextInputType.numberWithOptions(decimal: true, signed: true))),
                      ],
                    ),
                    const SizedBox(height: 10),
                    TextFormField(controller: _tz, decoration: const InputDecoration(labelText: 'IANA time zone (e.g. Europe/London)')),
                  ],
                ),
                const SizedBox(height: 16),
                _section('Calculation'),
                DropdownButtonFormField<String>(
                  initialValue: _methodId,
                  decoration: const InputDecoration(labelText: 'Calculation method'),
                  items: [for (final m in calculationMethods) DropdownMenuItem(value: m.id, child: Text(m.name))],
                  onChanged: (v) => setState(() => _methodId = v ?? _methodId),
                ),
                const SizedBox(height: 10),
                SegmentedButton<bool>(
                  segments: const [
                    ButtonSegment(value: false, label: Text("Asr: Shafi'i / Maliki / Hanbali")),
                    ButtonSegment(value: true, label: Text('Asr: Hanafi')),
                  ],
                  selected: {_asrHanafi},
                  onSelectionChanged: (v) => setState(() => _asrHanafi = v.first),
                ),
                const SizedBox(height: 6),
                _Stepper(label: 'Dhuhr: minutes after zawal', value: _dhuhrOffset, min: 0, max: 30, onChanged: (v) => setState(() => _dhuhrOffset = v)),
                _Stepper(label: 'Maghrib: minutes after sunset', value: _maghribOffset, min: 0, max: 30, onChanged: (v) => setState(() => _maghribOffset = v)),
                ExpansionTile(
                  title: const Text('Fine-tune each prayer (minutes)'),
                  tilePadding: EdgeInsets.zero,
                  children: [
                    for (final p in Prayer.values)
                      _Stepper(
                        label: p.label,
                        value: _adjustments[p] ?? 0,
                        min: -30,
                        max: 30,
                        onChanged: (v) => setState(() => _adjustments = {..._adjustments, p: v}),
                      ),
                    _Stepper(label: 'Hijri date adjustment (days)', value: _hijriAdjustment, min: -2, max: 2, onChanged: (v) => setState(() => _hijriAdjustment = v)),
                  ],
                ),
                const SizedBox(height: 16),
                _section('Iqama'),
                for (final p in Prayer.values.where((p) => p.isSalah)) _iqamaEditor(p),
                const SizedBox(height: 16),
                _section("Jumu'ah services"),
                for (var i = 0; i < _jumuah.length; i++) _jumuahEditor(i),
                if (_jumuah.length < 4)
                  OutlinedButton.icon(
                    onPressed: () => setState(() => _jumuah = [..._jumuah, const JumuahService(minutes: 13 * 60 + 30)]),
                    icon: const Icon(Icons.add),
                    label: Text(_jumuah.isEmpty ? "Add Jumu'ah time" : 'Add another service'),
                  ),
                const SizedBox(height: 24),
                FilledButton.icon(onPressed: _busy ? null : _save, icon: const Icon(Icons.check), label: const Text('Save masjid')),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _section(String title) {
    final scheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(title.toUpperCase(),
          style: TextStyle(fontSize: 11.5, letterSpacing: 1.4, fontWeight: FontWeight.w700, color: scheme.primary)),
    );
  }

  Widget _iqamaEditor(Prayer p) {
    final rule = _iqama[p] ?? const IqamaRule();
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          SizedBox(width: 70, child: Text(p.label, style: const TextStyle(fontWeight: FontWeight.w600))),
          Expanded(
            child: SegmentedButton<IqamaMode>(
              showSelectedIcon: false,
              segments: const [
                ButtonSegment(value: IqamaMode.none, label: Text('None')),
                ButtonSegment(value: IqamaMode.fixed, label: Text('Fixed')),
                ButtonSegment(value: IqamaMode.afterAdhan, label: Text('+ min')),
              ],
              selected: {rule.mode},
              onSelectionChanged: (v) => setState(() => _iqama = {..._iqama, p: rule.copyWith(mode: v.first)}),
            ),
          ),
          const SizedBox(width: 8),
          SizedBox(
            width: 96,
            child: switch (rule.mode) {
              IqamaMode.none => const SizedBox.shrink(),
              IqamaMode.fixed => OutlinedButton(
                  onPressed: () async {
                    final t = await showTimePicker(
                      context: context,
                      initialTime: TimeOfDay(hour: rule.fixedMinutes ~/ 60, minute: rule.fixedMinutes % 60),
                    );
                    if (t != null) setState(() => _iqama = {..._iqama, p: rule.copyWith(fixedMinutes: t.hour * 60 + t.minute)});
                  },
                  child: Text(formatMinutes(rule.fixedMinutes), style: const TextStyle(fontSize: 12)),
                ),
              IqamaMode.afterAdhan => TextFormField(
                  initialValue: '${rule.offsetMinutes}',
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(suffixText: 'min', isDense: true),
                  onChanged: (v) {
                    final n = int.tryParse(v);
                    if (n != null) _iqama = {..._iqama, p: rule.copyWith(offsetMinutes: n)};
                  },
                ),
            },
          ),
        ],
      ),
    );
  }

  Widget _jumuahEditor(int i) {
    final j = _jumuah[i];
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(12, 8, 4, 8),
        child: Row(
          children: [
            Text('${i + 1}', style: const TextStyle(fontWeight: FontWeight.w800)),
            const SizedBox(width: 10),
            OutlinedButton(
              onPressed: () async {
                final t = await showTimePicker(context: context, initialTime: TimeOfDay(hour: j.minutes ~/ 60, minute: j.minutes % 60));
                if (t != null) {
                  setState(() => _jumuah[i] = JumuahService(minutes: t.hour * 60 + t.minute, label: j.label, khutbahMinutes: j.khutbahMinutes));
                }
              },
              child: Text(formatMinutes(j.minutes)),
            ),
            const SizedBox(width: 8),
            TextButton(
              onPressed: () async {
                final t = await showTimePicker(
                  context: context,
                  initialTime: TimeOfDay(hour: (j.khutbahMinutes ?? j.minutes - 30) ~/ 60, minute: (j.khutbahMinutes ?? j.minutes - 30) % 60),
                );
                if (t != null) {
                  setState(() => _jumuah[i] = JumuahService(minutes: j.minutes, label: j.label, khutbahMinutes: t.hour * 60 + t.minute));
                }
              },
              child: Text(j.khutbahMinutes == null ? 'Khutbah…' : 'Khutbah ${formatMinutes(j.khutbahMinutes!)}', style: const TextStyle(fontSize: 12)),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: TextFormField(
                initialValue: j.label,
                decoration: const InputDecoration(hintText: 'Label (language, hall, khateeb)', isDense: true),
                onChanged: (v) => _jumuah[i] = JumuahService(minutes: j.minutes, label: v, khutbahMinutes: j.khutbahMinutes),
              ),
            ),
            IconButton(icon: const Icon(Icons.close), onPressed: () => setState(() => _jumuah.removeAt(i))),
          ],
        ),
      ),
    );
  }
}

class _Stepper extends StatelessWidget {
  const _Stepper({required this.label, required this.value, required this.min, required this.max, required this.onChanged});
  final String label;
  final int value;
  final int min;
  final int max;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(child: Text(label)),
        IconButton(onPressed: value > min ? () => onChanged(value - 1) : null, icon: const Icon(Icons.remove_circle_outline)),
        SizedBox(width: 36, child: Text('$value', textAlign: TextAlign.center, style: const TextStyle(fontWeight: FontWeight.w700))),
        IconButton(onPressed: value < max ? () => onChanged(value + 1) : null, icon: const Icon(Icons.add_circle_outline)),
      ],
    );
  }
}
