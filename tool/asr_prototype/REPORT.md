# Quran ASR prototype: can a Quran-specific recogniser catch harakat mistakes?

Date: 2026-10-28. Everything here ran in the browser on one Windows 11 laptop (6 threads, integrated GPU). Nothing was wired into the app.

## Short answer

Yes, for the model that matters. Tarteel's `whisper-base-ar-quran` emits **fully vocalised** Arabic (every fatha, damma, kasra, sukun and shadda), transcribed all seven ayat of Al-Fatiha recited by Mishary Alafasy **letter- and vowel-perfect** against the app's Uthmani text, and runs at **0.25 to 0.3 x real time on WebGPU** in Chrome after a one-time 150 to 170 MB download. The general Whisper base model, by contrast, outputs no harakat at all and garbles half of the words of the same recitation.

On synthetic clips with one deliberate vowel mistake, the harakat-aware comparison flagged the mutated word in **13 of 18** clips, with two misses caused by the model "snapping" to the memorised correct text and three by the TTS voice being transcribed as different letters. Correct synthetic clips were clean only 5 of 14 times, but every false alarm came from TTS pronunciation artefacts that a real reciter does not produce (see the caveat below). So: promising enough to design the integration, not yet proven on learners' voices. The missing step is a small corpus of real learner recordings with known mistakes.

## 1. Candidate models

| Model | Type | Output | Size quantised | Licence | Browser (transformers.js) | Mobile |
|---|---|---|---|---|---|---|
| **tarteel-ai/whisper-base-ar-quran** (via ONNX mirrors `eventhorizon0/...`, `YunusZJ/whisper-base-ar-quran-ONNX`) | Whisper base seq2seq, 74 M params, WER 5.75 on its eval set | **Vocalised Arabic** (trained on tarteel-ai/everyayah, whose text is fully vocalised Tanzil) | encoder q8 23 MB + decoder q4 123 MB (146 MB); encoder fp16 41 MB for WebGPU; a proper int8 export would be ~77 MB | Apache-2.0 | Yes, tested here | Yes: PyTorch weights exist; export to sherpa-onnx (whisper tiny/base supported) or whisper.cpp ggml; ~80 MB int8 |
| tarteel-ai/whisper-tiny-ar-quran | Whisper tiny, 39 M | Vocalised (same data) | ~40 MB int8 once exported (no ONNX mirror today) | Apache-2.0 | Needs an export | Same as above, smaller/faster, lower accuracy |
| MaddoggProduction/whisper-l-v3-turbo-quran-lora-dataset-mix, naazimsnh02/whisper-large-v3-turbo-ar-quran (`Aymencca/whisper-turbo-coran-onnx` is its browser export) | Whisper large-v3-turbo, 0.8 B | Vocalised (card says "with tashkeel"); 12.7 % WER | encoder fp16 1.27 GB or q4 425 MB + decoder q4 334 MB | Apache-2.0 | Only WebGPU, 0.8 to 1.6 GB download: not for this app | No |
| Muno459/fastconformer-quran | NVIDIA FastConformer CTC, 115 M | Vocalised (demo: مَالِكِ يَوْمِ الدِّينِ); 5.4 % WER, 0.9 % on unseen EveryAyah reciters | ONNX fp16 219 MB, q8 ~110 MB; CoreML offline and streaming builds | **NPL-1.1 no-profit**, gated, no ads or paid tiers; base model CC-BY-4.0 | Possible with onnxruntime-web (not transformers.js), needs own feature extraction | iOS CoreML provided; Android via onnxruntime |
| Quran-Lab/zipformer_p-arabic-v3 | Streaming Zipformer2 CTC, 65 M | **Phonemes** (251-symbol tajweed alphabet: madd length, ghunna, qalqalah, emphatics); PER 1.4 % studio, 3.7 % phone recordings | int8 ONNX; CoreML 63 MB (float8) | **NPL-1.2 no-profit**, gated, must show a "can be wrong, not a teacher" disclaimer | sherpa-onnx WASM build possible | sherpa-onnx streaming CTC (Android/iOS), CoreML for ANE |
| IqraEval/Iqra_wav2vec2_base (+ `kahk-group/dhor-recitation` CoreML) | wav2vec2 CTC, 95 M | Phonemes (68-phoneme set, geminates doubled) | ~95 MB int8 | Apache-2.0 | Raw checkpoint only (`.ckpt`), needs export | CoreML conversion exists |
| TBOGamer22/wav2vec2-quran-phonetics | wav2vec2 CTC, 94 M | Latin phonetic string per single word (e.g. `tālik`) | ~95 MB int8 | Apache-2.0 | Needs export; single-word training data | Needs export |

Findings worth keeping:

- The Tarteel Whisper fine-tunes are the only vocalised-text models that are Apache-licensed, small, and already in transformers.js format. The ONNX mirrors on Hugging Face were made with the generic conversion Space; their `decoder_model_merged_int8` files are not actually quantised (208 MB), so the usable combos are q8/fp16 encoder with **q4** or fp16 decoder. A clean export with `optimum` plus `quantize_dynamic` (what onnx-community does for `whisper-base`: 23 + 54 MB) would halve the download.
- `eventhorizon0`'s `generation_config.json` lacks the multilingual token map, so transformers.js refused `language: 'arabic'` and decoded garbage (`eng!engeng!eng`). The worker patches in the fields from `onnx-community/whisper-base` (same 51 865-token vocabulary). `YunusZJ`'s config is complete but its decoder is 140 MB because the output embedding was exported untied.
- A 2026 comparative study (arXiv 2606.19747) on 870 h of Quran audio found wav2vec2-XLSR fine-tunes score best **without** diacritics in the labels, which is why most CTC Quran models are either unvocalised or phonemic. Phoneme models (IqraEval, Quran-Lab) are the research community's answer to mispronunciation detection, but their licences (no-profit, gated) or packaging (raw checkpoints) make them a second phase.
- transformers.js 4.3.x (ESM from jsdelivr) handles Whisper on both `wasm` and `webgpu`; the model files are fetched from huggingface.co with CORS and cached by the browser Cache API, so the second load took 2.4 to 6 s.

## 2. The prototype

`tool/asr_prototype/` is a static page (no build step):

- `index.html` + `app.js`: model/device/dtype pickers, microphone recording (MediaRecorder, decoded and resampled to 16 kHz), multi-file upload, a "run server test clips" batch mode, a results table and JSON export.
- `asr-worker.js`: module Web Worker that loads the pipeline from `@huggingface/transformers@4.3.1` and transcribes; falls back from `language+timestamps` to plain decoding when a config lacks support.
- `harakat.js`: the harakat-aware comparison (pure functions, documented below) with `harakat.test.mjs` (`node tool/asr_prototype/harakat.test.mjs`).
- `fatiha.js`: Al-Fatiha from `assets/data/quran_uthmani.json` and the synthetic test set.
- `testdata/gen_tts.mjs`, `testdata/fetch_everyayah.mjs`: regenerate the clips into `testdata/audio/` (git-ignored).
- `results/*.json`: raw numbers from the runs below.

Run it with the `asr-prototype` entry in `.claude/launch.json` (`node tool/serve.mjs 8090 tool/asr_prototype`) and open http://localhost:8090/.

## 3. Test material

Real human recordings with deliberate mistakes were not available in this session (no microphone on the agent side), so two sources were used:

- **Real recitation**: Mishary Alafasy, Al-Fatiha 1:1 to 1:7 from everyayah.com (studio, tajweed, 4.6 to 13.2 s per ayah).
- **Synthetic**: Microsoft Edge neural TTS (ar-SA Hamed, ar-EG Salma) reading each ayah fully vocalised, once correct and once with a single haraka changed (الحمدَ, ربُّ, مالكُ, يومَ, نعبدَ, إياكِ, الصراطُ, أنعمتُ, غيرَ). TTS is not recitation: it reads MSA prose rhythm, drops some shadda, and the Egyptian voice mangles ص and ض. It is useful for "does the model copy what it hears or what it knows", not as a measure of the false-alarm rate on learners.

## 4. Results

### Accuracy (Tarteel whisper-base-ar-quran, wasm q8+q4 and WebGPU fp16+q4 gave identical text)

| Set | Clips | Vocalised output | Word-exact vs Uthmani | Vowel mistake flagged on the right word | Clean on correct clips |
|---|---|---|---|---|---|
| Alafasy (real) | 7 | 7/7 | 7/7 ayat, 29/29 words | n/a | 7/7 |
| Hamed TTS | 16 (7 correct, 9 mistakes) | 16/16 | | 7/9 | 4/7 |
| Salma TTS | 16 (7 correct, 9 mistakes) | 16/16 | | 6/9 | 1/7 |

What the synthetic failures were:

- **Snapping to the memorised text** (2 misses, both voices): غَيْرَ was transcribed as the correct غَيْرِ. The model is a language model over the Quran as much as an acoustic model, so an error in a weakly stressed final vowel mid-ayah can be "autocorrected". This is the fundamental limit of a seq2seq model trained only on correct recitation (Quran-Lab's card says the same about its phoneme model).
- **Letter garbage instead of a vowel verdict** (3 misses): إِيَّاكِ with a feminine kasra pushed the decoder off the rails (إِيَّكِنْ عَبُدُ ...); the Salma voice's الصِّرَاطُ came out as السِّرَاطُ. The comparison correctly reports these as letter errors, which the app already handles, so the user still sees the word marked red; it just cannot say "vowel".
- **False alarms on correct TTS** (9): Hamed's ٱلصِّرَٰطَ was heard as الصَّرَاطَ (ص kasra → fatha) in both ayah 6 clips; أَنْعَمْتَ lost its hamza and was heard as نَعَمْتَ in every ayah-7 clip; Salma's shadda is weak so إِيَّاكَ came back as إِيَكَ, and لِلَّهِ as لِلَّهُ. None of these occurred on the real recitation.
- Every detected mistake was reported with the right letter and marks, e.g. `د: expected damma, heard fatha` for الحمدَ, `ت: expected fatha, heard damma` for أنعمتُ (the meaning-changing one).

### Baseline: general `onnx-community/whisper-base` on the same real recitation

No harakat on any word, and 4 of 7 ayat contain consonant errors (مالك يا مدين, إيا كان عمل, الصراق, المرضو بعليهم ولبالين). This is roughly what the Web Speech API gives today and confirms that the Quran fine-tune, not the comparison code, is what makes vowel grading possible.

### Latency and size

| Backend | Download (one-time, cached) | Cold load | Inference per ayah | Real-time factor |
|---|---|---|---|---|
| wasm (6 threads), encoder q8 + decoder q4 | 150 MB | 17.5 s | 6.3 to 11 s | 1.2 to 1.9 (mean 1.59) |
| WebGPU, encoder fp16 + decoder q4 | 168 MB | 6.3 s (cached files) | 1.1 to 3.8 s (first call 4.2 s, shader compile) | **0.24 to 0.32** |
| baseline whisper-base, WebGPU | 168 MB | 18.6 s | 0.7 to 2.3 s | 0.09 to 0.38 |

Whisper pads every input to 30 s, so the encoder cost is flat per call; the decoder cost grows with the number of tokens (vocalised Arabic is ~2 to 3 tokens per letter, hence the 11 s for ayah 7 on wasm). Chunks of 3 to 5 s with a sliding window will keep the per-call latency near the floor (about 1 s on WebGPU, about 6 s on wasm).

## 5. Harakat-aware comparison (prototype of the Dart change)

`harakat.js` works on **units**: one base letter plus the combining marks after it.

1. `normalizeVocalised`: map Uthmani sukun (U+06E1) to U+0652, drop pause marks, small letters, silent-letter zeros, iqlab meem, madda and subscript alef; fold alef wasla and hamza seats to alef (same policy as `normalizeForMatch`), ى→ي, ة→ه, ؤ→و, ئ→ي. Keep only letters, the seven vowel marks, shadda and dagger alef.
2. Word alignment: the existing Needleman-Wunsch over skeletons (same +3/+1/-1 scores as `RecitationMatcher`), so the Dart class keeps its cursor and pending logic.
3. Unit alignment inside a word pair: Levenshtein on base letters with cheap alef insert/delete (ٱلْعَٰلَمِينَ vs الْعَالَمِينَ).
4. Per aligned unit with the same base letter: compare the vowel (one of fatha, damma, kasra, sukun, three tanween) and shadda. Rules that avoid false alarms:
   - heard word has no marks at all → status `unvocalised` (no verdict, today's engines);
   - heard has no mark or sukun where a vowel was expected → `unmarked`, not an error (recognisers skip marks; expected sukun omitted is fine);
   - **final unit of a stopped-on word** heard with sukun/no mark, or fathatan heard as fatha → `waqf`, not an error;
   - dagger alef and other length marks are ignored (madd length is not graded yet).
5. Word status: `letter` if any base letter differs or is missing (existing red), else `vowel` if any vowel/shadda differs (new amber), else `ok`; the vowel error carries the letter, expected mark and heard mark.

All 16 synthetic texts, compared as text, flag exactly the mutated word and nothing else (`harakat.test.mjs`).

## 6. Integration plan (not implemented)

### Web `SpeechEngine` backed by the Quran model

- New `lib/data/speech_engine_whisper_web.dart` implementing `SpeechEngine`, selected by a user setting ("Recognition engine: Browser (fast, letters only) / Quran model (download, vowels)"), falling back to `_WebSpeechEngine` when WebGPU and WASM SIMD are both unavailable or the download is declined.
- Transport: the same module worker as the prototype, shipped in `web/asr/` (worker + pinned transformers.js, 0.6 MB) and driven through `dart:js_interop`: `postMessage({type:'load'})`, `{type:'transcribe', audio}`. Audio capture with an `AudioWorklet` at 16 kHz into a ring buffer; every 3 s (or on 0.6 s of silence) send the last 8 s window; emit `onText(finalText, partialText)` where the overlapping prefix that matched the previous window becomes final. `shortSessions` = false, `description` = "Quran Whisper (WebGPU|wasm, q4)".
- Model files: fetched from huggingface.co (CORS works; cached by the browser's Cache API across visits; `env.useBrowserCache`), with a first-use dialog "Download the Quran recognition model (150 MB, once)?" and a progress bar from `progress_callback`. Option to mirror the two ONNX files under the GitHub Pages site later (keeps us independent of Hugging Face and lets us ship the re-quantised 77 MB build).
- Device choice: `navigator.gpu` present → WebGPU with `{encoder_model:'fp16', decoder_model_merged:'q4'}` (168 MB); else wasm with `{encoder_model:'q8', decoder_model_merged:'q4'}` (146 MB) and a notice that results will lag 5 to 10 s. Safari/iOS web: WebGPU shipped in Safari 26 but ONNX Runtime support there is immature; treat as wasm.
- Estimated sizes: app bundle +0.7 MB (worker, transformers.js); model 146 to 168 MB cached per device (77 MB after a clean int8 export); peak memory ~600 MB on wasm, ~450 MB on WebGPU.

### `RecitationMatcher` changes

- Keep `WordStatus.matched/wrong/missed/pending`, add `WordStatus.vowel` and a `VowelError {int letterIndex; String letter; String expectedMark; String heardMark}` list on `WordMatch`.
- Tokenise heard text twice: skeleton (current `tokenize`) for alignment, and vocalised units for grading; `isMatch` stays as is for the alignment pass, then a `gradeVowels(expectedUthmani, heardVocalised, isFinal)` pass sets `vowel`. Port `harakat.js` one function at a time; the JS tests become `test/recitation_matcher_test.dart` cases.
- `MatchResult.accuracy` counts `vowel` as not matched; add `vowelErrors` count for the summary. When the heard words are unvocalised (Web Speech API engine) nothing changes.

### UI wording (`recite_screen.dart`)

- Word colours: green matched, red letter error (existing), **amber** "vowel" with the mark names in the tap sheet: "Heard fatha on د, expected damma: ٱلْحَمْدُ". Mark names in Arabic in the Arabic UI (فتحة، ضمة، كسرة، سكون، شدة).
- Summary line: "12 correct · 1 vowel slip · 0 letter errors".
- Settings copy: "Quran recognition model: downloads 150 MB once and runs on this device. Marks vowel (harakat) mistakes, not only letters. Needs a recent Chrome, Edge or Safari." Diagnostics show the engine description and real-time factor.
- Disclaimer in the sheet, as Quran-Lab requires for its models and as is honest for ours: "Automatic feedback can be wrong; it does not replace a teacher."

### Native (Android, iOS)

- Same model through `sherpa_onnx` (pub.dev 2.0.x, Android/iOS/macOS/Windows/web) once exported with sherpa-onnx's `scripts/whisper/export-onnx.py`, which loads any openai-whisper `.pt`; the Tarteel checkpoint needs a one-time HF→openai weight conversion. Expect ~80 MB int8 and about 0.3 to 0.5 x real time on a recent phone. Alternatively whisper.cpp ggml-base-q5 (~60 MB). This is a separate task; the `SpeechEngine` interface already isolates it.

## 7. Open questions before building

1. **Learner audio.** Record 20 to 30 Al-Fatiha clips from real learners (phone mic, some with deliberate vowel errors) and re-run the batch page; the TTS numbers above cannot stand in for the false-alarm rate.
2. **Snapping.** Measure how often the model autocorrects a wrong vowel on real voices. If it is common, options are beam search with the candidate word forced (compare log-probs of expected vs heard variant), or moving to a phoneme/CTC model for grading while keeping Whisper for alignment.
3. **Clean export.** Re-export `tarteel-ai/whisper-base-ar-quran` (and `-tiny`) with optimum and dynamic int8 quantisation so the decoder is ~54 MB rather than 123 MB, and host it on the Pages site.
4. **Licence note.** Tarteel's weights are Apache-2.0; everyayah audio is free for non-commercial use. No change to the app's licence posture.
