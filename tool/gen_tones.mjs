// Generates the short feedback tones in assets/sounds (16-bit mono WAV).
// Usage: node tool/gen_tones.mjs
import { mkdirSync, writeFileSync } from 'node:fs';

const rate = 22050;
function wav(samples) {
  const data = Buffer.alloc(samples.length * 2);
  samples.forEach((s, i) => data.writeInt16LE(Math.max(-1, Math.min(1, s)) * 32767, i * 2));
  const h = Buffer.alloc(44);
  h.write('RIFF', 0);
  h.writeUInt32LE(36 + data.length, 4);
  h.write('WAVE', 8);
  h.write('fmt ', 12);
  h.writeUInt32LE(16, 16);
  h.writeUInt16LE(1, 20);
  h.writeUInt16LE(1, 22);
  h.writeUInt32LE(rate, 24);
  h.writeUInt32LE(rate * 2, 28);
  h.writeUInt16LE(2, 32);
  h.writeUInt16LE(16, 34);
  h.write('data', 36);
  h.writeUInt32LE(data.length, 40);
  return Buffer.concat([h, data]);
}
function tone(freq, seconds, shape, gain) {
  const n = Math.round(rate * seconds);
  return Array.from({ length: n }, (_, i) => {
    const t = i / rate;
    const env = Math.min(1, i / 200) * Math.exp(-4 * t / seconds);
    const v = shape === 'square' ? Math.sign(Math.sin(2 * Math.PI * freq * t)) : Math.sin(2 * Math.PI * freq * t);
    return v * env * gain;
  });
}
const dir = new URL('../assets/sounds/', import.meta.url);
mkdirSync(dir, { recursive: true });
writeFileSync(new URL('wrong.wav', dir), wav(tone(180, 0.25, 'square', 0.35)));
writeFileSync(new URL('success.wav', dir), wav(tone(880, 0.14, 'sine', 0.5)));
console.log('wrote assets/sounds/wrong.wav and success.wav');
