# Mushaf+ 📖

A beautiful, practical, cross-platform Quran app built with Flutter.
Runs on **Android, iOS, Web, Windows, macOS and Linux** from one codebase.

## Features

### Reading
- **Complete Quran** – all 114 surahs in the Uthmani script, bundled offline (Amiri Quran font).
- **Mushaf book** – the 604 printed pages as framed paper pages: single page scrolling down, single page flip, or a two-page spread you flip right-to-left like a real Mushaf.
- **Word-by-word transliteration & meaning** – every word with its Latin transliteration and translation (English, Urdu, Indonesian, Bengali, Turkish, Persian, Russian, Hindi, German, Tamil). Tap a word for a detail view.
- **Ayah transliteration** – full Latin-script pronunciation under each ayah (bundled offline).
- **120+ translations in 48 languages** – show up to four at once. Three English editions ship inside the app; the rest download once per surah and are cached offline.
- **Tafsir** – 20 commentaries (Ibn Kathir, Ma'arif al-Qur'an, Tabari, Qurtubi, Sa'di and more) in English, Arabic, Urdu, Bengali, Russian and Kurdish.
- **Audio recitation** – 31 reciters streamed verse by verse (Alafasy, Sudais, Husary, Minshawi, Abdul Basit, Warsh riwayah, English and Urdu), auto-advance, follow-along highlighting, mini player on every screen.
- **Search** – Arabic (diacritic-insensitive), transliteration, or English.
- **Bookmarks, continue-reading, verse of the day, Juz and page navigation.**

### Learning
- **Memorization trainer** – hide an ayah, reveal it word by word, loop a range with each ayah repeated 1–10×, track memorized ayahs.
- **Reading plans** – daily ayah goal with progress ring, streaks, 7-day chart, and a khatm plan (30–365 days) with per-day targets.
- **Offline packs** – one tap to pre-download translations and word-by-word data for the whole Quran.

### Hadith
- Sahih al-Bukhari, Sahih Muslim, Sunan an-Nasa'i, Abu Dawud, Tirmidhi, Ibn Majah, Muwatta Malik and three forty-hadith collections, with Arabic plus eight translation languages. Chapters cache offline.

### Prayer times for masjids
- Enter a masjid's **full address or ZIP code**: it is geocoded to precise coordinates (OpenStreetMap Nominatim / Zippopotam) and its IANA time zone (Open-Meteo), or use the device GPS.
- Astronomical calculation ported from [DeenTime](https://github.com/salimjemai/DeenTime) with 14 methods (ISNA, MWL, Egyptian, Karachi, Umm al-Qura, Gulf, Kuwait, Qatar, Singapore, Diyanet, UOIF, Russia, Tehran, Jafari), Shafi'i/Hanafi Asr, Dhuhr/Maghrib offsets and per-prayer adjustments. DST is handled per date via the timezone database.
- Today's times with next-prayer countdown, Hijri date and Qibla bearing; **iqama rules** (fixed time or minutes after adhan); up to four **Jumu'ah** services; **monthly timetable** with CSV copy and text share. Multiple masjids supported.

### App
- Interface in **English, Arabic, French, Urdu, Indonesian and Turkish** (RTL layouts for Arabic and Urdu).
- Adaptive layout: bottom navigation on phones, navigation rail and side panes on tablets, desktop and web.
- Light / dark themes, adjustable Arabic and translation sizes, two Arabic fonts, native splash screens and app icons on every platform.

## Getting started

```bash
flutter pub get
flutter run -d chrome        # web
flutter run -d windows       # desktop (needs Visual Studio C++ workload + Developer Mode)
flutter run                  # connected Android/iOS device
```

Build release artefacts with `flutter build web`, `flutter build apk`, `flutter build windows`, etc. Before a web build, run `node tool/vendor_asr.mjs` once: it fetches the pinned transformers.js build (SHA-256 checked) that the on-device voice model worker in `web/asr/` imports; the file is git-ignored.

### Android release signing

Copy `android/key.properties.example` to `android/key.properties` and point it at your upload keystore. Without it, release builds are signed with the debug key.

### CI and web deployment

- `.github/workflows/ci.yml` analyzes, tests, and builds the Android APK and Windows desktop app on every push and pull request.
- `.github/workflows/deploy-pages.yml` builds the web app and publishes it to GitHub Pages on every push to `main`. Enable **Settings → Pages → Source: GitHub Actions** in the repository once.

## Project layout

```
assets/data/            Bundled JSON: Arabic text, surah metadata, transliteration, editions, 3 English translations, hadith book index
assets/fonts/           Amiri & Amiri Quran (OFL)
assets/icon/            Rendered icon, adaptive foreground and splash artwork
lib/core/               Theme, Arabic text helpers, localization helpers
lib/data/               Models, repository, translation / word-by-word / tafsir / hadith / geocoding services, prayer-time engine, Hive storage
lib/state/              Riverpod providers: settings, bookmarks, reading stats, audio controller, masjids
lib/features/           home, reader, mushaf, search, bookmarks, memorize, plan, hadith, prayer, settings
lib/l10n/               ARB translations and generated localizations
lib/widgets/            Star badge, pattern panel, mini player
tool/gen_assets.mjs     Regenerates assets/data from the quran.db SQLite file + alquran.cloud
tool/gen_hadith_meta.mjs Regenerates the hadith book/chapter index from the hadith CDN
tool/render_icon.dart   Renders the icon artwork with Flutter (flutter test tool/render_icon.dart)
```

## Data sources & credits

- Arabic text (Tanzil Uthmani), ayah transliteration and translations: [Al Quran Cloud API](https://alquran.cloud/api)
- Word-by-word transliteration, meanings and tafsir: [Quran.com API v4](https://api-docs.quran.com)
- Verse-by-verse recitation audio: [EveryAyah.com](https://everyayah.com)
- Hadith: [fawazahmed0/hadith-api](https://github.com/fawazahmed0/hadith-api)
- Geocoding: [OpenStreetMap Nominatim](https://nominatim.org), [Zippopotam.us](https://zippopotam.us); time zones: [Open-Meteo](https://open-meteo.com)
- Prayer-time calculation: ported from [DeenTime](https://github.com/salimjemai/DeenTime)
- Fonts: [Amiri](https://github.com/aliftype/amiri) by Khaled Hosny (SIL Open Font License)

Regenerate the bundled data (requires Node 22+):

```bash
node --experimental-sqlite tool/gen_assets.mjs path/to/quran.db assets/data
```

```bash
node tool/gen_hadith_meta.mjs
```
