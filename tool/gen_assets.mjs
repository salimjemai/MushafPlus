import { DatabaseSync } from 'node:sqlite';
import { mkdirSync, writeFileSync } from 'node:fs';
import { join } from 'node:path';

const [,, dbPath, outDir] = process.argv;
const db = new DatabaseSync(dbPath, { readOnly: true });
mkdirSync(join(outDir, 'translations'), { recursive: true });


// --- Arabic text + ayah metadata ---
const ar = db.prepare(`SELECT a.number n, a.numberInSurah a, s.number s, a.text t, a.juz j, a.page p, a.hizbQuarter h, a.sajdaType sj
  FROM ayahs a JOIN surahs s ON s.id=a.surah_id WHERE a.edition_id=82 ORDER BY a.number`).all();
const BISMILLAH = ar[0].t.replace(/^﻿/, "").trim();
console.log("bismillah prefix:", BISMILLAH);
let stripped = 0;
const ayahs = ar.map(r => {
  let t = r.t.replace(/^\uFEFF/, '');
  if (r.a === 1 && r.s !== 1 && r.s !== 9) {
    const variants = [BISMILLAH, BISMILLAH.replace("بِسْمِ", "بِّسْمِ")];
    const v = variants.find(x => t.startsWith(x));
    const t2 = v ? t.slice(v.length).trimStart() : t;
    if (t2 !== t) { stripped++; t = t2; }
  }
  const o = { n: r.n, s: r.s, a: r.a, t, j: r.j, p: r.p, h: r.h };
  if (r.sj) o.sajda = true;
  return o;
});
console.log(`ayahs: ${ayahs.length}, bismillah stripped from ${stripped} surah openings (expect 112)`);
writeFileSync(join(outDir, 'quran_uthmani.json'), JSON.stringify(ayahs));

// --- Surah metadata (page/juz derived from first ayah) ---
const surahs = db.prepare(`SELECT number, name, englishName, englishNameTranslation, revelationType, numberOfAyahs FROM surahs ORDER BY number`).all()
  .map(s => {
    const first = ayahs.find(a => a.s === s.number && a.a === 1);
    return { number: s.number, name: s.name, englishName: s.englishName, englishNameTranslation: s.englishNameTranslation,
      revelationType: s.revelationType, numberOfAyahs: s.numberOfAyahs, startPage: first.p, startJuz: first.j, startAyah: first.n };
  });
writeFileSync(join(outDir, 'surahs.json'), JSON.stringify(surahs));
console.log(`surahs: ${surahs.length}`);

// --- Bundled English translation(s) as flat arrays indexed by global ayah number - 1 ---
for (const [id, ident] of [[20, 'en.sahih'], [18, 'en.pickthall'], [15, 'en.asad']]) {
  const rows = db.prepare(`SELECT text FROM ayahs WHERE edition_id=? ORDER BY number`).all(id);
  if (rows.length !== 6236) throw new Error(`${ident} has ${rows.length} rows`);
  writeFileSync(join(outDir, 'translations', `${ident}.json`), JSON.stringify(rows.map(r => r.text.replace(/^\uFEFF/, ''))));
  console.log(`translation ${ident}: ${rows.length}`);
}

// --- Ayah-level transliteration + editions list from alquran.cloud ---
async function getJson(url) {
  const r = await fetch(url); if (!r.ok) throw new Error(`${url} -> ${r.status}`); return r.json();
}
const tr = await getJson('https://api.alquran.cloud/v1/quran/en.transliteration');
const trArr = [];
for (const s of tr.data.surahs) for (const a of s.ayahs) trArr[a.number - 1] = a.text;
if (trArr.length !== 6236 || trArr.some(x => x == null)) throw new Error('transliteration incomplete');
writeFileSync(join(outDir, 'transliteration_en.json'), JSON.stringify(trArr));
console.log(`transliteration: ${trArr.length}; sample: ${trArr[0]}`);

const ed = await getJson('https://api.alquran.cloud/v1/edition?format=text');
const editions = ed.data.filter(e => e.type === 'translation' || e.type === 'transliteration' || e.type === 'tafsir')
  .map(e => ({ identifier: e.identifier, language: e.language, name: e.name, englishName: e.englishName, type: e.type, direction: e.direction }))
  .sort((a, b) => a.language.localeCompare(b.language) || a.englishName.localeCompare(b.englishName));
writeFileSync(join(outDir, 'editions.json'), JSON.stringify(editions));
console.log(`editions: ${editions.length}; languages: ${new Set(editions.map(e => e.language)).size}`);
