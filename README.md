# Quran+ 📖

A beautiful, practical, cross-platform Quran reader built with Flutter.
Runs on **Android, iOS, Web, Windows, macOS and Linux** from one codebase.

## Features

- **Complete Quran** – all 114 surahs in the Uthmani script, bundled offline (Amiri Quran font).
- **Word-by-word transliteration & meaning** – every word of every ayah with its Latin transliteration and translation (English, Urdu, Indonesian, Bengali, Turkish, Persian, Russian, Hindi, German, Tamil). Tap a word for a large detail view.
- **Ayah transliteration** – full Latin-script pronunciation under each ayah (bundled offline).
- **120+ translations in 48 languages** – show up to four at once. Three English editions (Saheeh International, Pickthall, Asad) ship inside the app; the rest download once per surah and are cached offline.
- **Two reading views** – a translation view (card per ayah) and a continuous **Mushaf view** (Arabic only, tap an ayah for details).
- **Search** – Arabic (diacritic-insensitive), transliteration, or English.
- **Bookmarks, continue-reading, verse of the day, Juz navigation.**
- **Adaptive layout** – bottom navigation on phones, navigation rail and a surah side-pane on tablets, desktop and web.
- Light / dark themes, adjustable Arabic & translation sizes, two Arabic fonts.

## Getting started

```bash
flutter pub get
flutter run -d chrome        # web
flutter run -d windows       # desktop (needs Visual Studio C++ workload + Developer Mode)
flutter run                  # connected Android/iOS device
```

Build release artefacts with `flutter build web`, `flutter build apk`, `flutter build windows`, etc.

## Project layout

```
assets/data/            Bundled JSON: Arabic text, surah metadata, transliteration, editions, 3 English translations
assets/fonts/           Amiri & Amiri Quran (OFL)
lib/core/               Theme, Arabic text helpers
lib/data/               Models, repository (bundled data), translation & word-by-word services, Hive storage
lib/state/              Riverpod providers: settings, bookmarks, last-read, async surah data
lib/features/           home (surah list), reader, search, bookmarks, settings
lib/widgets/            Eight-pointed star badge & geometric pattern panel
tool/gen_assets.mjs     Regenerates assets/data from the quran.db SQLite file + alquran.cloud
```

## Data sources & credits

- Arabic text (Tanzil Uthmani), ayah transliteration and translations: [Al Quran Cloud API](https://alquran.cloud/api)
- Word-by-word transliteration, meanings and tafsir: [Quran.com API v4](https://api-docs.quran.com)
- Verse-by-verse recitation audio: [EveryAyah.com](https://everyayah.com)
- Fonts: [Amiri](https://github.com/aliftype/amiri) by Khaled Hosny (SIL Open Font License)

Regenerate the bundled data (requires Node 22+):

```bash
node --experimental-sqlite tool/gen_assets.mjs path/to/quran.db assets/data
```
