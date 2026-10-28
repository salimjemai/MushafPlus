import { comparePassage, isVocalised, normalizeVocalised } from './harakat.js';
import { FATIHA, TEST_SET, describeFile } from './fatiha.js';

const $ = (id) => document.getElementById(id);
const log = (s) => { $('log').textContent = `${new Date().toISOString().slice(11, 19)} ${s}\n` + $('log').textContent; console.log(s); };

const worker = new Worker('./asr-worker.js', { type: 'module' });
const pending = new Map();
let nextId = 1;
let loaded = false;
const results = [];
window.__results = results; // for scripted inspection

FATIHA.forEach((t, i) => { const o = document.createElement('option'); o.value = String(i + 1); o.textContent = `1:${i + 1}`; $('ayah').appendChild(o); });
$('model').onchange = () => { $('customModel').style.display = $('model').value === 'custom' ? '' : 'none'; };

worker.onmessage = (e) => {
  const m = e.data;
  if (m.type === 'progress') {
    const files = Object.values(m.files);
    const loadedB = files.reduce((a, f) => a + (f.loaded || 0), 0), total = files.reduce((a, f) => a + (f.total || 0), 0);
    $('loadBar').style.display = '';
    $('loadBar').value = total ? loadedB / total : 0;
    $('loadStatus').textContent = `${m.status} ${m.file ?? ''} ${(loadedB / 1e6).toFixed(0)}/${(total / 1e6).toFixed(0)} MB`;
    window.__files = m.files;
  } else if (m.type === 'loaded') {
    loaded = true;
    const files = Object.entries(m.files).filter(([, f]) => f.total);
    const total = files.reduce((a, [, f]) => a + f.total, 0);
    $('loadStatus').textContent = `loaded in ${(m.ms / 1000).toFixed(1)} s, ${(total / 1e6).toFixed(1)} MB fetched (cached by the browser afterwards)`;
    $('fileSizes').textContent = files.map(([n, f]) => `${n.split('/').pop()} ${(f.total / 1e6).toFixed(1)} MB`).join(' · ');
    window.__loadInfo = { ms: m.ms, files: m.files, model: currentModel(), device: $('device').value, dtype: currentDtype() };
    for (const id of ['rec', 'files', 'run', 'runServer']) $(id).disabled = false;
    log(`model loaded (${(m.ms / 1000).toFixed(1)} s)${m.patched?.length ? `; generation config patched: ${m.patched.join(', ')}` : ''}`);
  } else if (m.type === 'result') {
    pending.get(m.id)?.resolve(m); pending.delete(m.id);
  } else if (m.type === 'error') {
    log(`worker error: ${m.message}`);
    if (m.id && pending.has(m.id)) { pending.get(m.id).reject(new Error(m.message)); pending.delete(m.id); }
    else $('loadStatus').textContent = `error: ${m.message.split('\n')[0]}`;
  }
};

const currentModel = () => $('model').value === 'custom' ? $('customModel').value.trim() : $('model').value;
const currentDtype = () => ({ encoder_model: $('encDtype').value, decoder_model_merged: $('decDtype').value });

$('load').onclick = () => {
  loaded = false;
  $('loadStatus').textContent = 'loading…';
  log(`loading ${currentModel()} on ${$('device').value} dtype ${JSON.stringify(currentDtype())}`);
  worker.postMessage({ type: 'load', model: currentModel(), device: $('device').value, dtype: currentDtype() });
};

function transcribe(audio) {
  const id = nextId++;
  return new Promise((resolve, reject) => {
    pending.set(id, { resolve, reject });
    worker.postMessage({ type: 'transcribe', id, audio }, [audio.buffer]);
  });
}

/** Decodes any browser-supported audio blob to 16 kHz mono Float32Array. */
async function decodeTo16k(blob) {
  const ctx = new (window.AudioContext || window.webkitAudioContext)();
  const buf = await ctx.decodeAudioData(await blob.arrayBuffer());
  await ctx.close();
  const len = Math.ceil(buf.duration * 16000);
  const off = new OfflineAudioContext(1, len, 16000);
  const src = off.createBufferSource();
  src.buffer = buf; src.connect(off.destination); src.start();
  const out = await off.startRendering();
  return { pcm: out.getChannelData(0).slice(), seconds: buf.duration };
}

function renderWords(graded) {
  return graded.words.map((w) => {
    const title = w.vowelErrors.map((v) => `${v.letter}: expected ${v.expectedName}, heard ${v.heardName}`).join('; ') || w.status;
    return `<span class="w ${w.status}" title="${title}">${w.heard ?? w.expected}</span>`;
  }).join(' ') + (graded.extras.length ? ` <span class="muted">+${graded.extras.join(' ')}</span>` : '');
}

/** Grades one transcript for one ayah; truth (from TEST_SET) decides TP/FN/FP. */
function grade(file, ayahIndex, text, seconds, ms, chunks) {
  const expectedWords = FATIHA[ayahIndex - 1].split(' ');
  const graded = comparePassage(expectedWords, text);
  const info = describeFile(file);
  const truth = info.id ? TEST_SET[info.id] : null;
  const flaggedVowel = graded.words.map((w, i) => (w.status === 'vowel' ? i : -1)).filter((i) => i >= 0);
  const flaggedLetter = graded.words.map((w, i) => (w.status === 'letter' || w.status === 'missed' ? i : -1)).filter((i) => i >= 0);
  let verdict = '';
  if (truth) {
    if (truth.mutated === null) verdict = flaggedVowel.length === 0 && flaggedLetter.length === 0 ? 'TN' : flaggedVowel.length ? 'FP' : 'FP-letter';
    else {
      const hit = flaggedVowel.includes(truth.mutated) || (info.id === 'bad_5b' && flaggedVowel.includes(2));
      const others = flaggedVowel.filter((i) => i !== truth.mutated && !(info.id === 'bad_5b' && i === 2));
      verdict = hit ? (others.length ? 'TP+FP' : 'TP') : flaggedLetter.includes(truth.mutated) ? 'FN(letter)' : 'FN';
    }
  }
  const r = {
    file, ayah: ayahIndex, seconds: +seconds.toFixed(2), ms: Math.round(ms), rtf: +(ms / 1000 / seconds).toFixed(2),
    transcript: text.trim(), vocalised: isVocalised(normalizeVocalised(text)),
    words: graded.words.map((w) => ({ expected: w.expected, heard: w.heard, status: w.status, vowelErrors: w.vowelErrors.map((v) => `${v.letter}:${v.expectedName}>${v.heardName}`) })),
    extras: graded.extras, flaggedVowel, flaggedLetter, truth: truth ? { mutated: truth.mutated, note: truth.note ?? '', spoken: truth.spoken } : null, verdict, chunks,
  };
  results.push(r);
  const tr = document.createElement('tr');
  const flags = graded.words.flatMap((w, i) => w.vowelErrors.map((v) => `w${i} ${v.letter}: ${v.expectedName}→${v.heardName}`)).join('<br>')
    + (flaggedLetter.length ? `<br>letter: w${flaggedLetter.join(',w')}` : '');
  tr.innerHTML = `<td>${file}</td><td>1:${ayahIndex}</td><td>${r.seconds}</td><td>${r.ms}</td><td>${r.rtf}</td>`
    + `<td class="ar">${r.transcript}</td><td class="ar">${renderWords(graded)}</td><td>${flags}${truth?.note ? `<br><span class="muted">truth: ${truth.note}</span>` : ''}</td>`
    + `<td class="${verdict.startsWith('TP') || verdict === 'TN' ? 'tp' : verdict.startsWith('FN') ? 'fn' : 'fp'}">${verdict}</td>`;
  $('results').tBodies[0].appendChild(tr);
  $('exportBtn').disabled = false;
  updateSummary();
  return r;
}

function updateSummary() {
  const n = results.length;
  const synth = results.filter((r) => r.truth);
  const bad = synth.filter((r) => r.truth.mutated !== null), ok = synth.filter((r) => r.truth.mutated === null);
  const tp = bad.filter((r) => r.verdict.startsWith('TP')).length;
  const tn = ok.filter((r) => r.verdict === 'TN').length;
  const vocal = results.filter((r) => r.vocalised).length;
  const rtf = n ? (results.reduce((a, r) => a + r.rtf, 0) / n).toFixed(2) : '-';
  $('summary').style.display = '';
  $('summary').innerHTML = `<b>${n}</b> clips · vocalised output ${vocal}/${n} · mean RTF ${rtf} · `
    + `mistake clips detected <b>${tp}/${bad.length}</b> · correct clips clean <b>${tn}/${ok.length}</b>`;
  window.__summary = { n, vocal, rtf, tp, bad: bad.length, tn, ok: ok.length };
}

async function runBlob(name, blob) {
  const { pcm, seconds } = await decodeTo16k(blob);
  const sel = Number($('ayah').value);
  const ayah = sel || describeFile(name).ayah || 1;
  $('runStatus').textContent = `transcribing ${name} (${seconds.toFixed(1)} s)…`;
  const res = await transcribe(pcm);
  log(`${name}: "${res.text.trim()}" ${res.ms.toFixed(0)} ms${res.fallbacks?.length ? ` (fell back to ${JSON.stringify(res.opts)}: ${res.fallbacks.join(' | ')})` : ''}`);
  window.__lastOpts = res.opts;
  return grade(name, ayah, res.text, seconds, res.ms, res.chunks);
}

$('run').onclick = async () => {
  const files = [...$('files').files];
  if (!files.length) return;
  $('run').disabled = true;
  for (const f of files) {
    try { await runBlob(f.name, f); } catch (err) { log(`${f.name}: ${err.message}`); }
  }
  $('runStatus').textContent = 'done';
  $('run').disabled = false;
  window.__done = true;
};

// The same test set served from testdata/audio/ (generated locally, not committed), so a scripted
// run needs no file picker. Missing files are skipped.
$('runServer').onclick = async () => {
  const names = [
    ...['hamed', 'salma'].flatMap((v) => Object.keys(TEST_SET).map((id) => `${v}_${id}.mp3`)),
    ...[1, 2, 3, 4, 5, 6, 7].map((a) => `alafasy_00100${a}.mp3`),
  ];
  const only = new URLSearchParams(location.search).get('only');
  $('runServer').disabled = true;
  window.__done = false;
  for (const name of names) {
    if (only && !name.includes(only)) continue;
    try {
      const res = await fetch(`./testdata/audio/${name}`);
      if (!res.ok) continue;
      await runBlob(name, await res.blob());
    } catch (err) { log(`${name}: ${err.message}`); }
  }
  $('runStatus').textContent = 'done';
  $('runServer').disabled = false;
  window.__done = true;
};

// Microphone: MediaRecorder -> decode -> 16 kHz.
let recorder = null, chunks = [];
$('rec').onclick = async () => {
  if (recorder) { recorder.stop(); return; }
  const stream = await navigator.mediaDevices.getUserMedia({ audio: { channelCount: 1, echoCancellation: true, noiseSuppression: true } });
  chunks = [];
  recorder = new MediaRecorder(stream);
  recorder.ondataavailable = (e) => chunks.push(e.data);
  recorder.onstop = async () => {
    stream.getTracks().forEach((t) => t.stop());
    const blob = new Blob(chunks, { type: recorder.mimeType });
    recorder = null;
    $('rec').textContent = '● Record';
    $('recStatus').textContent = '';
    try { await runBlob(`mic_${Date.now()}.webm`, blob); $('runStatus').textContent = 'done'; } catch (err) { log(`mic: ${err.message}`); }
  };
  recorder.start();
  $('rec').textContent = '■ Stop';
  $('recStatus').textContent = 'recording… pick the ayah above, recite, then stop';
};

$('exportBtn').onclick = async () => {
  const json = JSON.stringify({ load: window.__loadInfo, summary: window.__summary, results }, null, 1);
  try { await navigator.clipboard.writeText(json); $('runStatus').textContent = 'copied'; } catch { console.log(json); }
};

log(`WebGPU ${navigator.gpu ? 'available' : 'not available'}; hardware threads ${navigator.hardwareConcurrency}`);
