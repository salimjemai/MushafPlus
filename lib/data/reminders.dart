import 'dart:math';

import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../app.dart' show appRouter;
import '../core/l10n.dart';
import '../state/masjid_providers.dart';
import '../state/providers.dart';
import 'adhans.dart';
import 'adhkar.dart';
import 'audio_backend.dart';
import 'masjid.dart';
import 'notifications.dart';
import 'prayer_times.dart';
import 'quran_repository.dart';

String prayerName(AppLocalizations l, Prayer p) => switch (p) {
      Prayer.fajr => l.fajr,
      Prayer.sunrise => l.sunrise,
      Prayer.dhuhr => l.dhuhr,
      Prayer.asr => l.asr,
      Prayer.maghrib => l.maghrib,
      Prayer.isha => l.isha,
    };

/// Builds the next [days] of reminders from the active place and the
/// reminder settings. Ids are stable per day and kind so rescheduling
/// replaces rather than duplicates.
List<Reminder> buildReminders({
  required Masjid? place,
  required AppSettings s,
  required AppLocalizations l,
  required QuranRepository repo,
  AdhkarBook? adhkar,
  int days = 5,
  DateTime? now,
}) {
  final out = <Reminder>[];
  final today = now ?? DateTime.now();
  final rnd = Random(today.year * 400 + today.month * 31 + today.day);
  for (var d = 0; d < days; d++) {
    final date = DateTime(today.year, today.month, today.day + d);
    final base = d * 20;
    PrayerTimes? t;
    if (place != null) {
      try {
        t = prayerTimesFor(place, date);
      } catch (_) {}
    }
    if (t != null && s.remindPrayers) {
      var k = 0;
      for (final p in Prayer.values) {
        if (!p.isSalah) continue;
        final at = t[p].subtract(Duration(minutes: s.prayerReminderMinutes)).toLocal();
        out.add(Reminder(
          id: base + k++,
          at: DateTime(at.year, at.month, at.day, at.hour, at.minute),
          title: s.prayerReminderMinutes > 0 ? l.prayerInMinutes(prayerName(l, p), s.prayerReminderMinutes) : l.timeForPrayer(prayerName(l, p)),
          body: '${prayerName(l, p)} · ${place!.name}',
          route: '/prayer/adhan?play=1${p == Prayer.fajr ? '&fajr=1' : ''}',
          adhan: true,
        ));
      }
    }
    if (s.remindAdhkar) {
      DateTime morning, evening, sleep;
      if (t != null) {
        morning = t[Prayer.fajr].toLocal().add(const Duration(minutes: 30));
        evening = t[Prayer.asr].toLocal().add(const Duration(minutes: 30));
        sleep = t[Prayer.isha].toLocal().add(const Duration(hours: 1));
      } else {
        morning = DateTime(date.year, date.month, date.day, 6, 30);
        evening = DateTime(date.year, date.month, date.day, 17, 30);
        sleep = DateTime(date.year, date.month, date.day, 22, 0);
      }
      out.add(Reminder(id: base + 6, at: morning, title: l.timeAdhkarMorning, body: l.adhkarMorningBody, route: '/adhkar/27'));
      out.add(Reminder(id: base + 7, at: evening, title: l.timeAdhkarEvening, body: l.adhkarEveningBody, route: '/adhkar/27'));
      out.add(Reminder(id: base + 8, at: sleep, title: l.timeAdhkarSleep, body: l.adhkarSleepBody, route: '/adhkar/28'));
    }
    if (s.dailyReminder) {
      final at = DateTime(date.year, date.month, date.day, s.dailyReminderHour, 0);
      final useDhikr = adhkar != null && rnd.nextBool();
      if (useDhikr) {
        final chapters = adhkar.chapters.where((c) => c.items.isNotEmpty).toList();
        final c = chapters[rnd.nextInt(chapters.length)];
        final item = c.items[rnd.nextInt(c.items.length)];
        out.add(Reminder(id: base + 9, at: at, title: l.dhikrOfTheDay, body: _short(item.arabic), route: '/adhkar/${c.id}'));
      } else {
        final n = rnd.nextInt(QuranRepository.totalAyahs) + 1;
        final a = repo.ayah(n);
        out.add(Reminder(
          id: base + 9,
          at: at,
          title: '${l.ayahOfTheDayNotif} · ${repo.surah(a.surah).englishName} ${a.key}',
          body: _short(a.text),
          route: '/surah/${a.surah}?ayah=${a.numberInSurah}',
        ));
      }
    }
  }
  out.sort((a, b) => a.at.compareTo(b.at));
  return out;
}

String _short(String s) => s.length <= 160 ? s : '${s.substring(0, 157).trimRight()}…';

bool remindersEnabled(AppSettings s) => s.remindPrayers || s.remindAdhkar || s.dailyReminder;

/// Recomputes and schedules every reminder. Safe to call often.
Future<void> rescheduleReminders(WidgetRef ref, AppLocalizations l) async {
  final s = ref.read(settingsProvider);
  if (!remindersEnabled(s)) {
    await Notifications.cancelAll();
    return;
  }
  final repo = ref.read(repositoryProvider).asData?.value;
  if (repo == null) return;
  final place = ref.read(activePlaceProvider);
  final adhkar = ref.read(adhkarProvider).asData?.value;
  final items = buildReminders(place: place, s: s, l: l, repo: repo, adhkar: adhkar);
  await Notifications.schedule(items);
}

AyahPlayer? _adhanPlayer;

/// App start: wire taps to routes, play the adhan when a web reminder
/// fires, honour a reminder that launched the app, and schedule ahead.
Future<void> bootstrapReminders(BuildContext context, WidgetRef ref) async {
  final l = context.l10n;
  await Notifications.init((route) => appRouter.push(route));
  Notifications.onFire = (r) {
    if (!r.adhan) return;
    final settings = ref.read(settingsProvider);
    final adhan = adhanFor(settings.adhanId, fajr: r.route.contains('fajr=1'));
    _adhanPlayer ??= createAyahPlayer();
    try {
      _adhanPlayer!.play(adhan.url);
    } catch (_) {}
  };
  final launch = await Notifications.launchRoute();
  if (launch != null) appRouter.push(launch);
  await rescheduleReminders(ref, l);
}
