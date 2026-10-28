import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart' show DateFormat;

import '../../core/l10n.dart';
import '../../data/adhans.dart';
import '../../data/adhkar.dart';
import '../../data/notifications.dart';
import '../../data/reminders.dart';
import '../../state/masjid_providers.dart';
import '../../state/providers.dart';

/// Prayer-time, adhkar and daily reminders.
class RemindersScreen extends ConsumerStatefulWidget {
  const RemindersScreen({super.key});

  @override
  ConsumerState<RemindersScreen> createState() => _RemindersScreenState();
}

class _RemindersScreenState extends ConsumerState<RemindersScreen> {
  bool? _permission;

  Future<void> _enable(void Function(bool) setter, bool on) async {
    if (on) {
      final ok = await Notifications.requestPermission();
      if (!mounted) return;
      setState(() => _permission = ok);
      if (!ok) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(context.l10n.notificationsDenied)));
      }
    }
    setter(on);
    if (!mounted) return;
    await rescheduleReminders(ref, context.l10n);
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final s = ref.watch(settingsProvider);
    final n = ref.read(settingsProvider.notifier);
    final scheme = Theme.of(context).colorScheme;
    final place = ref.watch(activePlaceProvider);
    final repo = ref.watch(repositoryProvider).asData?.value;
    final adhkar = ref.watch(adhkarProvider).asData?.value;
    final upcoming = repo == null ? const <Reminder>[] : buildReminders(place: place, s: s, l: l, repo: repo, adhkar: adhkar, days: 2).take(8).toList();
    final adhan = adhanFor(s.adhanId, fajr: false);

    return Scaffold(
      appBar: AppBar(title: Text(l.reminders)),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 640),
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              if (!Notifications.backgroundCapable)
                Card(
                  color: scheme.tertiaryContainer.withValues(alpha: 0.5),
                  child: Padding(
                    padding: const EdgeInsets.all(14),
                    child: Row(children: [
                      Icon(Icons.info_outline, color: scheme.onTertiaryContainer),
                      const SizedBox(width: 10),
                      Expanded(child: Text(l.notificationsWebNote, style: const TextStyle(height: 1.4))),
                    ]),
                  ),
                ),
              if (_permission == false)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: Text(l.notificationsDenied, style: TextStyle(color: scheme.error)),
                ),
              if (place == null)
                Card(
                  child: ListTile(
                    leading: Icon(Icons.place_outlined, color: scheme.primary),
                    title: Text(l.setLocationFirst),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () => context.push('/prayer/me'),
                  ),
                ),
              const SizedBox(height: 8),
              SwitchListTile(
                secondary: const Icon(Icons.mosque_outlined),
                title: Text(l.prayerReminders),
                subtitle: Text(l.prayerRemindersSubtitle(adhan.name)),
                value: s.remindPrayers,
                onChanged: (v) => _enable(n.setRemindPrayers, v),
              ),
              if (s.remindPrayers)
                ListTile(
                  title: Text(l.remindBefore),
                  trailing: DropdownButton<int>(
                    value: s.prayerReminderMinutes,
                    underline: const SizedBox.shrink(),
                    items: [for (final m in const [0, 5, 10, 15, 30]) DropdownMenuItem(value: m, child: Text(m == 0 ? l.atPrayerTime : l.minutesBefore(m)))],
                    onChanged: (v) async {
                      if (v == null) return;
                      n.setPrayerReminderMinutes(v);
                      await rescheduleReminders(ref, l);
                    },
                  ),
                ),
              ListTile(
                leading: const SizedBox(width: 24),
                title: Text(l.chooseAdhan),
                subtitle: Text(adhan.name),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => context.push('/prayer/adhan'),
              ),
              const Divider(),
              SwitchListTile(
                secondary: const Icon(Icons.auto_awesome),
                title: Text(l.adhkarReminders),
                subtitle: Text(l.adhkarRemindersSubtitle),
                value: s.remindAdhkar,
                onChanged: (v) => _enable(n.setRemindAdhkar, v),
              ),
              const Divider(),
              SwitchListTile(
                secondary: const Icon(Icons.wb_twilight_outlined),
                title: Text(l.dailyReminder),
                subtitle: Text(l.dailyReminderSubtitle),
                value: s.dailyReminder,
                onChanged: (v) => _enable(n.setDailyReminder, v),
              ),
              if (s.dailyReminder)
                ListTile(
                  title: Text(l.reminderTime),
                  trailing: TextButton(
                    onPressed: () async {
                      final t = await showTimePicker(context: context, initialTime: TimeOfDay(hour: s.dailyReminderHour, minute: 0));
                      if (t == null) return;
                      n.setDailyReminderHour(t.hour);
                      if (!context.mounted) return;
                      await rescheduleReminders(ref, l);
                    },
                    child: Text(TimeOfDay(hour: s.dailyReminderHour, minute: 0).format(context)),
                  ),
                ),
              if (upcoming.isNotEmpty) ...[
                const SizedBox(height: 16),
                Text(l.nextReminders.toUpperCase(), style: TextStyle(fontSize: 11, letterSpacing: 1.1, fontWeight: FontWeight.w700, color: scheme.onSurfaceVariant)),
                const SizedBox(height: 6),
                for (final r in upcoming)
                  ListTile(
                    dense: true,
                    leading: Icon(r.adhan ? Icons.campaign_outlined : Icons.notifications_none, color: scheme.primary),
                    title: Text(r.title),
                    subtitle: Text(r.body, maxLines: 1, overflow: TextOverflow.ellipsis),
                    trailing: Text(DateFormat.MMMd().add_jm().format(r.at), style: const TextStyle(fontSize: 12)),
                  ),
              ],
              const SizedBox(height: 12),
              Text(l.adhanOnNotification, style: TextStyle(fontSize: 12, color: scheme.outline, height: 1.4)),
            ],
          ),
        ),
      ),
    );
  }
}
