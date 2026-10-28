# Third-party content, APIs and their terms

Rule for this project: nothing ships unless its terms allow it, and every
required credit is shown in the app (Settings → About → Data sources &
licences) and in `web/privacy.html`. This file records the audit of
2026-10-28 and what to do when a source changes.

| Source | Used for | Terms | Status / what we do |
|---|---|---|---|
| Tanzil Project | Uthmani Quran text (bundled) | Verbatim copies allowed; must name Tanzil and link to tanzil.net | OK — credited with link |
| Al Quran Cloud (Islamic Network) | Tajweed edition (bundled), translations, transliteration | Free key-less API; non-commercial reproduction free; credit translators by name | OK — translator names shown; app is free with voluntary tips |
| Quran.com / Quran Foundation API | Word-by-word, tafsir, word audio; page line layout (generated once by `tool/gen_pages.mjs` into `assets/data/pages.json`: word positions only, no text) | Public content API | OK — credited. No separate terms page found; re-check before store launch |
| EveryAyah.com | Verse recitation audio (streamed, cached per ayah) | No terms published on the site; long-standing free source used by many free apps; copyright stays with reciters | ACCEPTED WITH NOTE — credited; keep non-commercial; remove a reciter on request |
| fawazahmed0/hadith-api | Hadith text and English section names (jsDelivr) | The Unlicense (public domain) | OK |
| AhmedBaset/hadith-json | Arabic chapter titles (generated once into `assets/data/hadith_books.json`) | No licence file; data scraped from sunnah.com; the titles themselves are classical, public-domain text | LOW RISK — credited; regenerate from another source if asked |
| hisnmuslim.com API | Hisn al-Muslim text (bundled) and audio (streamed) | Public API offered by the site | OK — credited |
| Wikimedia Commons + Internet Archive | Adhan recordings (17): live/field recordings and muezzins' own uploads under CC0, Public Domain Mark or CC BY-SA; all copies hosted in `web/audio/adhan/` on the app site (Ogg/WAV originals converted to mono MP3) | CC0 / PDM / CC BY-SA 4.0 | OK — author, licence and source link on every row of the Adhan screen and in Credits. Deliberately excluded: third-party re-uploads of studio adhans (Alafasy, al-Qatami, Harak…) even when marked public domain, and NC/ND items |
| ~~archive.org adhan items~~ | former adhan list | No licence metadata on the items (uploader-only) | REMOVED 2026-10-28 |
| ~~Hadith.to~~ | recorded hadith recitations | No licence or terms published anywhere | DISABLED (`hadithRecordingsEnabled = false` in `lib/data/hadith_audio.dart`) until written permission; device voice used instead |
| OpenStreetMap Nominatim | Address → coordinates | Usage policy: identify the app (User-Agent set), ≤1 request/s, show "© OpenStreetMap contributors" | OK — attribution under the address forms |
| Open-Meteo geocoding | City lookup fallback | Free for non-commercial use, CC BY 4.0 attribution | OK — attributed |
| Zippopotam | Postal code lookup | Free | OK |
| timeapi.io | Time zone for coordinates | Free | OK |
| GeoJS | Country guess from IP (flag, defaults) | Free; abuse may be throttled | OK |
| ~~ipwho.is~~ | former country-guess fallback | Non-commercial use only | REMOVED 2026-10-28 to avoid ambiguity |
| tarteel-ai/whisper-base-ar-quran | On-device recitation model (optional 150 MB download) | Apache-2.0 | OK — credited |
| transformers.js, ONNX Runtime | Run the model in the browser | Apache-2.0 / MIT (licence file vendored in `web/asr/`) | OK |
| Amiri, Amiri Quran | Arabic fonts (bundled) | SIL OFL 1.1 (`assets/fonts/OFL-Amiri.txt`) | OK |
| DigitalKhatt Madina font (Amine Anane, Tarteel Inc.) | Madani Mushaf script for the Mushaf pages (bundled, `assets/fonts/DigitalKhatt-Madina.otf`) | SIL OFL 1.1 (`assets/fonts/OFL-DigitalKhatt.txt`, source https://github.com/DigitalKhatt/madinafont) | OK — credited under Mushaf script |
| ~~KFGQPC Uthmanic Script HAFS, QCF page fonts~~ | the King Fahd Complex's own Mushaf fonts | Licence file: "This Font is the property of King Fahd Glorious Quran Printing Complex … may not be reproduced, modified without the express written approval" | NOT USED 2026-10-28 — bundling is reproduction; usable only with the Complex's written approval |
| Flutter / pub packages | App framework | BSD/MIT/Apache | OK — Flutter's licence page is reachable from Data sources |
| QuranFlash, Madani Mushaf scans | — | Copyrighted page images | NOT USED. Our pages are rendered from the Tanzil text, line by line after the quran.com page data, in the OFL DigitalKhatt Madina font |

## Adding a source

1. Find its licence or terms page and note the URL here.
2. If it needs attribution, add it to `lib/features/settings/licenses_screen.dart` and, where the content appears, next to it.
3. If the site contacts a new host, add it to `web/privacy.html` and to the iOS/Android store privacy answers.
4. Nothing with "all rights reserved", no licence file, or "non-commercial only" when the terms are ambiguous.

## Hadith.to permission request (to send before enabling the recordings)

> Subject: Permission to stream Hadith.to recitations in Mushaf+
>
> Assalamu alaikum,
>
> I build Mushaf+, a free, ad-free Quran and hadith app (https://salimjemai.github.io/MushafPlus/, source on GitHub). I would like to stream your hadith recitations for Sahih al-Bukhari, Sahih Muslim, Sunan an-Nasa'i, Sunan Abi Dawud, Jami' at-Tirmidhi, Sunan Ibn Majah and Muwatta Malik directly from cdn.hadith.to, with "Hadith recitations: Hadith.to" shown in the app's credits and a link back to your site. Users would play one hadith at a time; the installed app would keep a local copy of recordings already played.
>
> Could you confirm that this use is allowed, and under which licence or conditions? I am happy to add any credit, rate limit or attribution you prefer.
>
> Jazakum Allahu khairan,
> Salim Jemai
