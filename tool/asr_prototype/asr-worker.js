// Web Worker: loads a Whisper ONNX model with transformers.js and transcribes 16 kHz mono audio.
// Messages in: {type:'load', model, device, dtype} | {type:'transcribe', id, audio: Float32Array}
// Messages out: {type:'progress', ...} | {type:'loaded', ms, files} | {type:'result', id, text, chunks, ms} | {type:'error', message}
import { pipeline, env } from 'https://cdn.jsdelivr.net/npm/@huggingface/transformers@4.3.1/dist/transformers.min.js';

env.allowLocalModels = false;

let asr = null;
let loadedKey = '';
let extra = {}; // generation-config fields patched in at load time

self.onmessage = async (e) => {
  const msg = e.data;
  try {
    if (msg.type === 'load') {
      const key = JSON.stringify([msg.model, msg.device, msg.dtype]);
      if (asr && loadedKey === key) { self.postMessage({ type: 'loaded', ms: 0, files: {} }); return; }
      asr = null;
      const t0 = performance.now();
      const files = {};
      asr = await pipeline('automatic-speech-recognition', msg.model, {
        device: msg.device,
        dtype: msg.dtype,
        progress_callback: (p) => {
          if (p.status === 'progress' && p.file) files[p.file] = { loaded: p.loaded, total: p.total };
          if (p.status === 'done' && p.file && files[p.file]) files[p.file].loaded = files[p.file].total;
          self.postMessage({ type: 'progress', status: p.status, file: p.file, loaded: p.loaded, total: p.total, files });
        },
      });
      loadedKey = key;
      // Some conversions (e.g. eventhorizon0) ship a generation_config.json without the
      // multilingual token map, so transformers.js treats the model as English-only and the
      // decoder is never prompted with <|ar|><|transcribe|>. Borrow those fields from the
      // reference whisper-base config (same 51865-token vocabulary) when they are missing.
      extra = {};
      const gc = asr.model.generation_config ?? {};
      if (!gc.lang_to_id) {
        const ref = await (await fetch('https://huggingface.co/onnx-community/whisper-base/raw/main/generation_config.json')).json();
        for (const k of ['is_multilingual', 'lang_to_id', 'task_to_id', 'no_timestamps_token_id', 'prev_sot_token_id', 'max_initial_timestamp_index', 'suppress_tokens', 'max_length']) extra[k] = ref[k];
        self.postMessage({ type: 'progress', status: 'generation config patched with multilingual token map', files });
      }
      self.postMessage({ type: 'loaded', ms: performance.now() - t0, files, patched: Object.keys(extra) });
    } else if (msg.type === 'transcribe') {
      if (!asr) throw new Error('model not loaded');
      const t0 = performance.now();
      // Fine-tunes often ship a generation_config without the multilingual language map (so
      // `language`/`task` are refused) or without timestamp support; fall back step by step.
      const attempts = [
        { language: 'arabic', task: 'transcribe', return_timestamps: true, chunk_length_s: 30 },
        { return_timestamps: true, chunk_length_s: 30 },
        {},
      ];
      let out = null, errors = [];
      for (const opts of attempts) {
        try { out = await asr(msg.audio, { ...extra, ...opts }); out.opts = opts; break; } catch (err) { errors.push(String(err).split('\n')[0]); }
      }
      if (!out) throw new Error(errors.join(' | '));
      self.postMessage({ type: 'result', id: msg.id, text: out.text, chunks: out.chunks ?? null, opts: out.opts, fallbacks: errors, ms: performance.now() - t0 });
    }
  } catch (err) {
    self.postMessage({ type: 'error', id: msg.id, message: String(err && err.stack || err) });
  }
};
