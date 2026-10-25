// Adds Arabic chapter names to assets/data/hadith_books.json from the open
// AhmedBaset/hadith-json dataset (sunnah.com chapter titles), matching each
// fawazahmed0 section to a chapter by its English title.
// Usage: node tool/gen_hadith_arabic_names.mjs   (run after gen_hadith_meta.mjs)
import { readFileSync, writeFileSync } from 'node:fs';

const BASE = 'https://raw.githubusercontent.com/AhmedBaset/hadith-json/main/db/by_book/';
const FILES = {
  bukhari: 'the_9_books/bukhari.json',
  muslim: 'the_9_books/muslim.json',
  nasai: 'the_9_books/nasai.json',
  abudawud: 'the_9_books/abudawud.json',
  tirmidhi: 'the_9_books/tirmidhi.json',
  ibnmajah: 'the_9_books/ibnmajah.json',
  malik: 'the_9_books/malik.json',
  nawawi: 'forties/nawawi40.json',
  qudsi: 'forties/qudsi40.json',
  dehlawi: 'forties/shahwaliullah40.json',
};

const norm = (s) =>
  s
    .toLowerCase()
    .replace(/\(.*?\)/g, ' ')
    .replace(/\b(the|book|of|on|kitab|al|chapters?|and|its|about|regarding|concerning)\b/g, ' ')
    .replace(/[^a-z\s]/g, ' ')
    .split(/\s+/)
    .filter(Boolean);

function similarity(a, b) {
  const A = new Set(norm(a));
  const B = new Set(norm(b));
  if (A.size === 0 || B.size === 0) return 0;
  let common = 0;
  for (const w of A) if (B.has(w)) common++;
  return common / Math.max(A.size, B.size);
}

const file = new URL('../assets/data/hadith_books.json', import.meta.url);
const books = JSON.parse(readFileSync(file, 'utf8'));
for (const book of books) {
  const path = FILES[book.id];
  if (!path) continue;
  const res = await fetch(BASE + path);
  if (!res.ok) throw new Error(`${book.id}: ${res.status}`);
  const chapters = ((await res.json()).chapters ?? []).map((c) => ({ id: c.id, ar: (c.arabic ?? '').trim(), en: (c.english ?? '').trim() }));
  const used = new Set();
  let low = 0;
  for (const s of book.sections) {
    let best = null;
    let bestScore = -1;
    for (const c of chapters) {
      if (used.has(c.id) || !c.ar) continue;
      let score = similarity(s.name, c.en);
      if (c.en.toLowerCase() === s.name.toLowerCase()) score = 2;
      if (c.id === s.n) score += 0.15; // same position is a strong hint
      if (score > bestScore) {
        bestScore = score;
        best = c;
      }
    }
    if (best && bestScore >= 0.3) {
      s.arabic = best.ar;
      used.add(best.id);
      if (bestScore < 0.6) {
        low++;
        console.log(`  ? ${book.id} ${s.n}: "${s.name}" -> "${best.en}" (${best.ar}) score ${bestScore.toFixed(2)}`);
      }
    } else {
      console.log(`  ! ${book.id} ${s.n}: no match for "${s.name}"`);
    }
  }
  console.log(`${book.id}: ${book.sections.filter((s) => s.arabic).length}/${book.sections.length} Arabic names (${low} low-confidence)`);
}
writeFileSync(file, JSON.stringify(books));
