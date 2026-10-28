// Downloads a professional studio recitation of Al-Fatiha from everyayah.com for the real-recitation
// test. Local test material only: it is git-ignored and must never be shipped with the app.
import fs from 'node:fs';
const out = process.argv[2] ?? '.';
for (let a = 1; a <= 7; a++) {
  const url = `https://everyayah.com/data/Alafasy_128kbps/00100${a}.mp3`;
  const buf = Buffer.from(await (await fetch(url)).arrayBuffer());
  fs.writeFileSync(`${out}/recitation_00100${a}.mp3`, buf);
  console.log(url, buf.length);
}
