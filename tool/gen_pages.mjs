// Builds assets/data/pages.json: the line layout of the 604 pages of the
// Madani Mushaf (15 lines a page, 8 on the two opening pages) from the
// quran.com content API, which gives every word of a page with its line
// number. Only word positions are stored; the text itself comes from
// assets/data/quran_uthmani.json (Tanzil), which must stay verbatim.
//
// Word positions count "visual" words: Tanzil writes pause marks (ۖ ۗ ۚ …)
// as separate space-delimited tokens, the printed Mushaf (and quran.com)
// keep them with the word before. lib/data/mushaf_layout.dart merges them
// the same way. Index k == number of visual words stands for the ayah-end
// marker.
//
// Output, per page (array index = page - 1):
//   { "l": [ line, … ], "e": [ayah, word] }
//   line = [ayah, word]  text line starting at that token (global ayah number,
//                        visual word index, or the end marker)
//        = ["h", surah]  surah header
//        = ["b"]         basmala line
//   "e" = the last token on the page (pages may end mid-ayah)
// A text line ends just before the next text line starts (or at "e").
//
// Usage: node tool/gen_pages.mjs            (fetches all 604 pages)
//        node tool/gen_pages.mjs 1 2 50     (checks the given pages, no write)
import { readFileSync, writeFileSync } from 'node:fs';

const quran = JSON.parse(readFileSync(new URL('../assets/data/quran_uthmani.json', import.meta.url), 'utf8'));
const byKey = new Map();
for (const a of quran) byKey.set(`${a.s}:${a.a}`, a);

// Tokens the Mushaf prints attached to the preceding word (pause marks, the
// sajdah sign) or to the following one (the rub' al-hizb star).
const AFTER = /^[\u06D6-\u06DC\u06E9]$/;
const BEFORE = /^\u06DE$/;
// Tanzil writes the basmala inside the first ayah of a few surahs (95, 97);
// the Mushaf prints it on its own line, so it is not a word of the ayah.
const BASMALA = new RegExp("^" + byKey.get("1:1").t.replace(/^ب[ِّ]+/, "ب[ِّ]{1,2}") + " ");
export function visualWords(text, { firstAyahOfSurah = false } = {}) {
  if (firstAyahOfSurah) text = text.replace(BASMALA, '');
  const out = [];
  let prefix = '';
  for (const t of text.split(' ')) {
    if (BEFORE.test(t)) prefix += t + ' ';
    else if (AFTER.test(t) && out.length) out[out.length - 1] += ' ' + t;
    // 37:130: the Mushaf prints إِلْ يَاسِينَ as one word.
    else if (out.length && out[out.length - 1] === 'إِلْ') out[out.length - 1] += ' ' + t;
    else {
      out.push(prefix + t);
      prefix = '';
    }
  }
  return out;
}

const marks = new Set();
for (const a of quran) for (const t of a.t.split(' ')) if ([...t].length === 1) marks.add(t);
console.log('standalone single-char tokens in Tanzil:', [...marks].map((c) => c + ' U+' + c.codePointAt(0).toString(16).toUpperCase()).join(', '));

async function fetchPage(p) {
  const url = `https://api.quran.com/api/v4/verses/by_page/${p}?words=true&word_fields=text_uthmani,line_number&per_page=50`;
  for (let attempt = 0; attempt < 5; attempt++) {
    try {
      const res = await fetch(url);
      if (!res.ok) throw new Error(`HTTP ${res.status}`);
      const j = await res.json();
      if (j.pagination.total_pages !== 1) throw new Error('pagination');
      return j.verses;
    } catch (e) {
      if (attempt === 4) throw new Error(`page ${p}: ${e.message}`);
      await new Promise((r) => setTimeout(r, 1500 * (attempt + 1)));
    }
  }
}

const problems = [];
function layout(p, verses) {
  const lines = new Map(); // line number -> [[n, w], ...]
  const firstWord = new Map(); // surah -> line of its first word
  let last;
  for (const v of verses) {
    const a = byKey.get(v.verse_key);
    const vis = visualWords(a.t, { firstAyahOfSurah: a.a === 1 && a.s !== 1 });
    const words = v.words.filter((w) => w.char_type_name === 'word');
    if (words.length !== vis.length) {
      problems.push(`page ${p} ${v.verse_key}: api ${words.length} words, tanzil ${vis.length}`);
    }
    let k = 0;
    for (const w of v.words) {
      const idx = w.char_type_name === 'end' ? vis.length : k++;
      if (w.char_type_name !== 'word' && w.char_type_name !== 'end') continue;
      if (!lines.has(w.line_number)) lines.set(w.line_number, []);
      lines.get(w.line_number).push([a.n, idx]);
      if (idx === 0 && a.a === 1) firstWord.set(a.s, w.line_number);
      last = [a.n, idx];
    }
  }
  const max = p <= 2 ? 8 : 15;
  const out = [];
  const seen = new Set();
  for (let ln = 1; ln <= max; ln++) {
    const toks = lines.get(ln);
    if (toks) {
      out.push(toks[0]);
      continue;
    }
    // An empty line is a surah header or a basmala, placed just above the
    // first word of the surah. Al-Fatiha's basmala is its first ayah and
    // At-Tawbah has none, so those get only a header.
    let kind = null;
    for (const [s, l] of firstWord) {
      const basmala = s !== 1 && s !== 9;
      if (basmala && ln === l - 1) kind = ['b'];
      else if (ln === l - (basmala ? 2 : 1)) kind = ['h', s];
    }
    if (!kind) {
      // A surah that ends on line 14 leaves the last line blank when the next
      // surah's header opens the following page; the renderer leaves the
      // slot empty.
      if (ln === max) break;
      problems.push(`page ${p}: line ${ln} is empty and is neither header nor basmala`);
      continue;
    }
    seen.add(ln);
    out.push(kind);
  }
  for (const ln of lines.keys()) if (ln > max) problems.push(`page ${p}: words on line ${ln}`);
  return { l: out, e: last };
}

const args = process.argv.slice(2).map(Number);
if (args.length) {
  for (const p of args) {
    const lay = layout(p, await fetchPage(p));
    console.log(p, JSON.stringify(lay));
  }
  console.log(problems.join('\n') || 'no problems');
  process.exit(0);
}

const pages = new Array(604);
let next = 1;
async function worker() {
  while (next <= 604) {
    const p = next++;
    pages[p - 1] = layout(p, await fetchPage(p));
    if (p % 50 === 0) console.log(`…${p}`);
  }
}
await Promise.all([worker(), worker(), worker(), worker()]);
if (problems.length) {
  console.error(problems.join('\n'));
  throw new Error(`${problems.length} problems`);
}
writeFileSync(new URL('../assets/data/pages.json', import.meta.url), JSON.stringify(pages));
const lines = pages.reduce((s, p) => s + p.l.length, 0);
console.log(`wrote 604 pages, ${lines} lines`);
