// Builds assets/data/hadith_books.json (book list + section names/ranges + available
// languages) from the fawazahmed0/hadith-api CDN. Usage: node tool/gen_hadith_meta.mjs
import { writeFileSync } from 'node:fs';

const CDN = 'https://cdn.jsdelivr.net/gh/fawazahmed0/hadith-api@1';
const BOOKS = [
  ['bukhari', 'Sahih al-Bukhari', 'صحيح البخاري'],
  ['muslim', 'Sahih Muslim', 'صحيح مسلم'],
  ['nasai', "Sunan an-Nasa'i", 'سنن النسائي'],
  ['abudawud', 'Sunan Abi Dawud', 'سنن أبي داود'],
  ['tirmidhi', "Jami' at-Tirmidhi", 'جامع الترمذي'],
  ['ibnmajah', 'Sunan Ibn Majah', 'سنن ابن ماجه'],
  ['malik', 'Muwatta Malik', 'موطأ مالك'],
  ['nawawi', "An-Nawawi's 40 Hadith", 'الأربعون النووية'],
  ['qudsi', '40 Hadith Qudsi', 'الأحاديث القدسية'],
  ['dehlawi', '40 Hadith of Shah Waliullah Dehlawi', 'الأربعون الدهلوية'],
];

const editions = await (await fetch(`${CDN}/editions.json`)).json();
const out = [];
for (const [id, name, arabic] of BOOKS) {
  const langs = (editions[id]?.collection ?? [])
    .map((c) => c.name.split('-')[0])
    .filter((l, i, a) => a.indexOf(l) === i && !/\d$/.test(l));
  const res = await fetch(`${CDN}/editions/eng-${id}.min.json`);
  if (!res.ok) throw new Error(`${id}: ${res.status}`);
  const j = await res.json();
  const sections = Object.entries(j.metadata.sections)
    .filter(([n, title]) => n !== '0' && title)
    .map(([n, title]) => ({
      n: Number(n),
      name: title.trim(),
      first: j.metadata.section_details[n]?.hadithnumber_first ?? 0,
      last: j.metadata.section_details[n]?.hadithnumber_last ?? 0,
    }));
  out.push({ id, name, arabic, languages: langs, hadiths: j.hadiths.length, sections });
  console.log(`${id}: ${sections.length} sections, ${j.hadiths.length} hadiths, langs ${langs.join(',')}`);
}
writeFileSync(new URL('../assets/data/hadith_books.json', import.meta.url), JSON.stringify(out));
