// Mushaf+ voice model worker: loads the on-device Quran recognition model (an
// Apache-2.0 Whisper fine-tune, see LICENSE-transformers.txt and the app's
// credits) with the vendored transformers.js and transcribes 16 kHz mono
// audio sent from lib/data/speech_engine_whisper_web.dart.
//
// Messages in:
//   {type:'probe', model, remoteHost, remotePathTemplate, dtype}
//       -> {type:'probe', cached}            whether the model files are already in the browser cache
//   {type:'load', model, remoteHost, remotePathTemplate, device, dtype, wasmPaths?}
//       -> {type:'progress', stage, loaded, total, file} ... {type:'loaded', ms, bytes}
//   {type:'transcribe', id, audio: Float32Array}
//       -> {type:'result', id, text, ms}
//   {type:'unload'}
// Any failure answers {type:'error', id?, message}.
import { pipeline, env } from './transformers.min.js';

env.allowLocalModels = false;
env.useBrowserCache = true;

const CACHE_NAME = 'transformers-cache';

let asr = null;
let loadedKey = '';
let extra = {}; // generation-config fields patched in at load time

const post = (m) => self.postMessage(m);

function configure(msg) {
  if (msg.remoteHost) env.remoteHost = msg.remoteHost;
  if (msg.remotePathTemplate) env.remotePathTemplate = msg.remotePathTemplate;
  if (msg.wasmPaths) env.backends.onnx.wasm.wasmPaths = msg.wasmPaths;
}

function fileUrl(model, file) {
  return env.remoteHost + env.remotePathTemplate.replace('{model}', model).replace('{revision}', 'main') + file;
}

// File suffix transformers.js uses for a dtype (q8 is stored as "_quantized").
const dtypeSuffix = (d) => (!d || d === 'fp32' ? '' : d === 'q8' ? '_quantized' : `_${d}`);

function modelFiles(model, dtype) {
  return [
    fileUrl(model, `onnx/encoder_model${dtypeSuffix(dtype.encoder_model)}.onnx`),
    fileUrl(model, `onnx/decoder_model_merged${dtypeSuffix(dtype.decoder_model_merged)}.onnx`),
  ];
}

async function probe(msg) {
  configure(msg);
  try {
    if (!('caches' in self)) return false;
    const cache = await caches.open(CACHE_NAME);
    const hits = await Promise.all(modelFiles(msg.model, msg.dtype).map((u) => cache.match(u)));
    return hits.every(Boolean);
  } catch {
    return false;
  }
}

async function load(msg) {
  configure(msg);
  const key = JSON.stringify([msg.model, msg.device, msg.dtype, env.remoteHost]);
  if (asr && loadedKey === key) return { ms: 0, bytes: 0 };
  if (asr) {
    try { await asr.dispose(); } catch { /* ignore */ }
    asr = null;
  }
  const t0 = performance.now();
  const files = {};
  const report = (stage, file) => {
    let loaded = 0, total = 0;
    for (const f of Object.values(files)) { loaded += f.loaded || 0; total += f.total || 0; }
    post({ type: 'progress', stage, loaded, total, file: file ?? '' });
  };
  let threads = 0;
  if (msg.device === 'wasm') {
    threads = self.crossOriginIsolated ? Math.min(4, Math.ceil((navigator.hardwareConcurrency || 1) / 2)) : 1;
    env.backends.onnx.wasm.numThreads = threads;
    console.log(`[asr] wasm threads: ${threads} (crossOriginIsolated=${self.crossOriginIsolated}, cores=${navigator.hardwareConcurrency})`);
  }
  asr = await pipeline('automatic-speech-recognition', msg.model, {
    device: msg.device,
    dtype: msg.dtype,
    progress_callback: (p) => {
      if (p.file && p.status === 'progress') files[p.file] = { loaded: p.loaded, total: p.total };
      if (p.file && p.status === 'done' && files[p.file]) files[p.file].loaded = files[p.file].total;
      report(p.status === 'ready' ? 'init' : 'download', p.file);
    },
  });
  loadedKey = key;
  // Some conversions ship a generation_config.json without the multilingual
  // token map, so the decoder would never be prompted with <|ar|><|transcribe|>.
  // Patch the fields in from the reference Whisper configuration (same vocabulary).
  extra = {};
  const gc = asr.model.generation_config ?? {};
  if (!gc.lang_to_id) {
    const patch = await (await fetch(new URL('./generation_config_patch.json', import.meta.url))).json();
    delete patch._comment;
    extra = patch;
    Object.assign(gc, patch);
  }
  report('init');
  // Warm up: the first call compiles shaders (WebGPU) or initialises the wasm
  // threads, which would otherwise delay the first real result by seconds.
  // The warm-up takes about as long as a real pass (Whisper always encodes a
  // 30 s window), so its time tells the app how slow this device is.
  const w0 = performance.now();
  try { await transcribe(new Float32Array(16000)); } catch { /* reported on the real call */ }
  const warmMs = performance.now() - w0;
  let bytes = 0;
  for (const f of Object.values(files)) bytes += f.total || 0;
  return { ms: performance.now() - t0, bytes, threads, warmMs };
}

async function transcribe(audio) {
  if (!asr) throw new Error('model not loaded');
  const attempts = [
    { language: 'arabic', task: 'transcribe', return_timestamps: false },
    { return_timestamps: false },
  ];
  const errors = [];
  for (const opts of attempts) {
    try {
      const out = await asr(audio, { ...extra, ...opts });
      return (out.text ?? '').trim();
    } catch (err) {
      errors.push(String(err).split('\n')[0]);
    }
  }
  throw new Error(errors.join(' | '));
}

self.onmessage = async (e) => {
  const msg = e.data;
  try {
    if (msg.type === 'probe') {
      post({ type: 'probe', cached: await probe(msg) });
    } else if (msg.type === 'load') {
      const r = await load(msg);
      post({ type: 'loaded', ms: r.ms, bytes: r.bytes, threads: r.threads, warmMs: r.warmMs });
    } else if (msg.type === 'transcribe') {
      const t0 = performance.now();
      const text = await transcribe(msg.audio);
      post({ type: 'result', id: msg.id, text, ms: performance.now() - t0 });
    } else if (msg.type === 'unload') {
      if (asr) { try { await asr.dispose(); } catch { /* ignore */ } }
      asr = null;
      loadedKey = '';
      post({ type: 'unloaded' });
    }
  } catch (err) {
    post({ type: 'error', id: msg.id, message: String((err && err.message) || err) });
  }
};
