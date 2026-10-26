// Builds assets/data/adhkar.json from hisnmuslim.com's open API (Hisn
// al-Muslim, "Fortress of the Muslim", by Sa'id al-Qahtani): 132 chapters
// with Arabic text, English translation and transliteration, repeat counts
// and per-dhikr audio. The API exists only in Arabic and English.
// Usage: node tool/gen_adhkar.mjs
import { writeFileSync } from 'node:fs';

const BASE = 'https://www.hisnmuslim.com/api';
const strip = (s) => s.replace(/^﻿/, '');
async function getJson(url) {
  const res = await fetch(url);
  if (!res.ok) throw new Error(`${url}: ${res.status}`);
  // The feed contains raw tabs and line breaks inside strings (JSON forbids
  // them) and a few chapter files have a broken outer key, so only the
  // inner array is parsed.
  const text = strip(await res.text()).replace(/[\u0000-\u001F]+/g, ' ');
  const i = text.indexOf('[');
  const j = text.lastIndexOf(']');
  return JSON.parse(text.slice(i, j + 1));
}
const first = (arr) => arr;
// English prose has stopwords; a transliteration does not.
const STOP = /\b(the|of|and|to|in|you|is|for|from|my|me|your|has|have|with|who|that|all|be|not|except|upon|his|him|he|i|o|allah)\b/gi;
const englishness = (s) => (s.match(STOP) || []).length / Math.max(1, s.split(/\s+/).length);
function splitEnglish(a, b) {
  // returns [translation, transliteration]
  a = clean(a);
  b = clean(b);
  if (!a) return [b, ''];
  if (!b) return [a, ''];
  return englishness(a) >= englishness(b) ? [a, b] : [b, a];
}
const clean = (s) => (s ?? '').toString().replace(/\s+/g, ' ').trim();
const sleep = (ms) => new Promise((r) => setTimeout(r, ms));

const ar = first(await getJson(`${BASE}/ar/husn_ar.json`));
const en = first(await getJson(`${BASE}/en/husn_en.json`));
const enById = new Map(en.map((c) => [c.ID, c]));

const out = [];
for (const cat of ar) {
  const e = enById.get(cat.ID);
  const itemsAr = first(await getJson(`${BASE}/ar/${cat.ID}.json`));
  await sleep(120);
  const itemsEn = e ? first(await getJson(`${BASE}/en/${cat.ID}.json`)) : [];
  await sleep(120);
  const enItems = new Map(itemsEn.map((i) => [i.ID, i]));
  out.push({
    id: cat.ID,
    ar: clean(cat.TITLE),
    en: clean(e?.TITLE ?? ''),
    audio: (cat.AUDIO_URL || '').replace(/^http:/, 'https:'),
    items: itemsAr.map((i) => {
      const t = enItems.get(i.ID);
      // The English feed puts the meaning and the romanised reading in
      // LANGUAGE_ARABIC_TRANSLATED_TEXT / TRANSLATED_TEXT in either order.
      const [en, tr] = splitEnglish(t?.LANGUAGE_ARABIC_TRANSLATED_TEXT ?? '', t?.TRANSLATED_TEXT ?? '');
      return {
        id: i.ID,
        arabic: clean(i.ARABIC_TEXT),
        en,
        tr,
        repeat: Number(i.REPEAT) || 1,
        audio: (i.AUDIO || '').replace(/^http:/, 'https:'),
      };
    }),
  });
  process.stdout.write(`\r${out.length}/${ar.length} ${cat.TITLE}            `);
}
console.log();
const total = out.reduce((n, c) => n + c.items.length, 0);
writeFileSync(new URL('../assets/data/adhkar.json', import.meta.url), JSON.stringify(out));
console.log(`wrote ${out.length} chapters, ${total} adhkar`);
