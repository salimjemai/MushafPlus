// Generates the synthetic test clips (correct ayat and single-vowel mistakes) with Microsoft Edge
// neural Arabic voices. Usage, from any scratch folder:
//   npm init -y && npm i msedge-tts@2 && node <repo>/tool/asr_prototype/testdata/gen_tts.mjs <outdir>
// Then download real recitation for comparison: node <repo>/tool/asr_prototype/testdata/fetch_everyayah.mjs <outdir>
import { MsEdgeTTS, OUTPUT_FORMAT } from 'msedge-tts';
import fs from 'node:fs';
import { TEST_SET } from '../fatiha.js';

const out = process.argv[2] ?? '.';
const voices = { voice_a: 'ar-SA-HamedNeural', voice_b: 'ar-EG-SalmaNeural' };
for (const [prefix, v] of Object.entries(voices)) {
  const tts = new MsEdgeTTS();
  await tts.setMetadata(v, OUTPUT_FORMAT.AUDIO_24KHZ_48KBITRATE_MONO_MP3);
  for (const [id, t] of Object.entries(TEST_SET)) {
    const file = `${out}/${prefix}_${id}.mp3`;
    const { audioStream } = tts.toStream(t.spoken, { rate: '-30%' });
    const chunks = [];
    for await (const c of audioStream) chunks.push(c);
    fs.writeFileSync(file, Buffer.concat(chunks));
    console.log(file);
  }
  tts.close();
}
