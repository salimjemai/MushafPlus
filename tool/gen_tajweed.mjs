// Builds assets/data/tajweed.json: the Uthmani text of every ayah with
// alquran.cloud's tajweed markup ("[code[text]"), as a JSON array of 6236
// strings in global ayah order. Source edition: quran-tajweed, see
// https://alquran.cloud/tajweed-guide (Tanzil Uthmani based, riwayat Hafs).
// Usage: node tool/gen_tajweed.mjs
import { writeFileSync } from 'node:fs';

const res = await fetch('https://api.alquran.cloud/v1/quran/quran-tajweed');
if (!res.ok) throw new Error(`alquran.cloud: ${res.status}`);
const j = await res.json();
const out = [];
for (const s of j.data.surahs) {
  for (const a of s.ayahs) {
    out.push(
      a.text
        // the index after the colon is an internal id with no meaning for display
        .replace(/\[([a-z]):\d+\[/g, '[$1[')
        // U+0672 stands for the superscript (dagger) alef, which Tanzil and our fonts encode as U+0670
        .replace(/ٲ/g, 'ٰ')
        // zero-width non-joiners before pause marks
        .replace(/‌/g, '')
        // a stray literal bracket in the source (not part of a "[c[" opener)
        .replace(/(?<!\[[a-z])\[(?![a-z]\[)/g, ''),
    );
  }
}
if (out.length !== 6236) throw new Error(`expected 6236 ayahs, got ${out.length}`);
writeFileSync(new URL('../assets/data/tajweed.json', import.meta.url), JSON.stringify(out));
const codes = {};
for (const t of out) for (const m of t.matchAll(/\[([a-z])\[/g)) codes[m[1]] = (codes[m[1]] || 0) + 1;
console.log(`wrote ${out.length} ayahs; codes:`, codes);
