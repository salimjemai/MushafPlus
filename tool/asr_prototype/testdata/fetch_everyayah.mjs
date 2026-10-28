// Downloads Al-Fatiha (Mishary Alafasy, 128 kbps) from everyayah.com for the real-recitation test.
import fs from 'node:fs';
const out = process.argv[2] ?? '.';
for (let a = 1; a <= 7; a++) {
  const url = `https://everyayah.com/data/Alafasy_128kbps/00100${a}.mp3`;
  const buf = Buffer.from(await (await fetch(url)).arrayBuffer());
  fs.writeFileSync(`${out}/alafasy_00100${a}.mp3`, buf);
  console.log(url, buf.length);
}
