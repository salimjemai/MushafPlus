// Harakat-aware comparison of a vocalised transcript against Uthmani text.
//
// Pure ES module (no DOM) so it runs in the browser prototype and in node
// tests, and so it can be ported line by line to lib/core/recitation_matcher.dart.
//
// Vocabulary: a "unit" is one base letter plus the combining marks that follow
// it. Words are aligned unit by unit on their base letters; for each aligned
// pair with the same base letter the vowel marks are compared. That yields
// three separate error classes: letter (consonant/skeleton) errors, vowel
// (haraka) errors, and "unvocalised" (the recogniser gave no marks, so no
// vowel verdict is possible).

export const MARK = {
  FATHATAN: 'ً', DAMMATAN: 'ٌ', KASRATAN: 'ٍ',
  FATHA: 'َ', DAMMA: 'ُ', KASRA: 'ِ',
  SHADDA: 'ّ', SUKUN: 'ْ', DAGGER_ALEF: 'ٰ',
};

const VOWELS = new Set([MARK.FATHATAN, MARK.DAMMATAN, MARK.KASRATAN, MARK.FATHA, MARK.DAMMA, MARK.KASRA, MARK.SUKUN]);

// Marks we keep for comparison (after normalisation) and marks we drop.
// Uthmani annotation (pause signs, small letters, silent-letter zeros, iqlab
// meem, madda, subscript alef) is dropped: recognisers never emit it and it
// carries no vowel information we can grade yet.
const DROP = /[ؐ-ؚٕٖٓٔٗ٘ٙٚ-ٟۖ-ۭـٴ]/g;

export function normalizeVocalised(s) {
  return s
    .replace(/ۡ/g, MARK.SUKUN) // Uthmani small high dotless head of khah = sukun
    .replace(DROP, '')
    .replace(/ٱ/g, 'ا') // alef wasla -> alef
    .replace(/[آأإ]/g, 'ا') // آ أ إ -> ا (hamza seats are letter errors we tolerate like the app does)
    .replace(/ى/g, 'ي') // ى -> ي
    .replace(/ة/g, 'ه') // ة -> ه
    .replace(/ؤ/g, 'و') // ؤ -> و
    .replace(/ئ/g, 'ي') // ئ -> ي
    .replace(/ء/g, '') // standalone hamza
    .replace(/[^ء-يً-ْٰ ]/g, ' ')
    .replace(/\s+/g, ' ')
    .trim();
}

const isMark = (c) => (c >= 'ً' && c <= 'ْ') || c === MARK.DAGGER_ALEF;

/** Splits a normalised word into units: [{base, marks: Set, raw}]. Leading marks attach to a '' base. */
export function units(word) {
  const out = [];
  for (const c of word) {
    if (isMark(c)) {
      if (out.length === 0) out.push({ base: '', marks: new Set(), raw: '' });
      out[out.length - 1].marks.add(c);
      out[out.length - 1].raw += c;
    } else {
      out.push({ base: c, marks: new Set(), raw: c });
    }
  }
  return out;
}

export const skeleton = (word) => units(word).map((u) => u.base).join('');

/** Vowel mark of a unit (one of VOWELS) or null. Tanween counts as its own vowel. */
export function vowelOf(u) {
  for (const m of u.marks) if (VOWELS.has(m)) return m;
  return null;
}

export const hasShadda = (u) => u.marks.has(MARK.SHADDA);
export const isVocalised = (word) => units(word).some((u) => u.marks.size > 0);

const MARK_NAME = {
  [MARK.FATHATAN]: 'fathatan', [MARK.DAMMATAN]: 'dammatan', [MARK.KASRATAN]: 'kasratan',
  [MARK.FATHA]: 'fatha', [MARK.DAMMA]: 'damma', [MARK.KASRA]: 'kasra', [MARK.SUKUN]: 'sukun',
  [MARK.SHADDA]: 'shadda',
};
export const markName = (m) => (m ? MARK_NAME[m] ?? m : 'none');

/** Levenshtein alignment of two unit arrays on their base letters. Alef insert/delete is cheap
 *  (Uthmani ٱلْعَٰلَمِينَ vs العالمين). Returns [[i|null, j|null], ...]. */
function alignUnits(a, b) {
  const n = a.length, m = b.length;
  const gap = (u) => (u.base === 'ا' ? 0.3 : 1);
  const D = Array.from({ length: n + 1 }, () => new Float64Array(m + 1));
  const P = Array.from({ length: n + 1 }, () => new Int8Array(m + 1)); // 0 diag, 1 up (del a), 2 left (ins b)
  for (let i = 1; i <= n; i++) { D[i][0] = D[i - 1][0] + gap(a[i - 1]); P[i][0] = 1; }
  for (let j = 1; j <= m; j++) { D[0][j] = D[0][j - 1] + gap(b[j - 1]); P[0][j] = 2; }
  for (let i = 1; i <= n; i++) {
    for (let j = 1; j <= m; j++) {
      const sub = D[i - 1][j - 1] + (a[i - 1].base === b[j - 1].base ? 0 : 1);
      const del = D[i - 1][j] + gap(a[i - 1]);
      const ins = D[i][j - 1] + gap(b[j - 1]);
      if (sub <= del && sub <= ins) { D[i][j] = sub; P[i][j] = 0; }
      else if (del <= ins) { D[i][j] = del; P[i][j] = 1; }
      else { D[i][j] = ins; P[i][j] = 2; }
    }
  }
  const pairs = [];
  let i = n, j = m;
  while (i > 0 || j > 0) {
    const p = i === 0 ? 2 : j === 0 ? 1 : P[i][j];
    if (p === 0) { pairs.push([i - 1, j - 1]); i--; j--; }
    else if (p === 1) { pairs.push([i - 1, null]); i--; }
    else { pairs.push([null, j - 1]); j--; }
  }
  return pairs.reverse();
}

/**
 * Compares one expected (Uthmani) word with one heard (vocalised) word.
 * Options: finalWord (waqf: a dropped/sukun final vowel is not an error).
 * Returns { status: 'ok'|'vowel'|'letter'|'unvocalised', letterErrors, vowelErrors: [...], detail }.
 */
export function compareWord(expectedRaw, heardRaw, { finalWord = false } = {}) {
  const exp = units(normalizeVocalised(expectedRaw));
  const hrd = units(normalizeVocalised(heardRaw));
  const heardVocalised = hrd.some((u) => u.marks.size > 0);
  const pairs = alignUnits(exp, hrd);
  let letterErrors = 0;
  const vowelErrors = [];
  const detail = [];
  let lastExpIndex = exp.length - 1;
  // Expected trailing alef after fathatan (e.g. غَفُورًا) has no vowel; treat the unit before it as final.
  while (lastExpIndex > 0 && exp[lastExpIndex].base === 'ا' && exp[lastExpIndex].marks.size === 0) lastExpIndex--;
  for (const [i, j] of pairs) {
    if (i === null) { if (hrd[j].base !== 'ا') letterErrors++; detail.push({ kind: 'extra', heard: hrd[j].raw }); continue; }
    if (j === null) { if (exp[i].base !== 'ا') letterErrors++; detail.push({ kind: 'missing', expected: exp[i].raw }); continue; }
    const e = exp[i], h = hrd[j];
    if (e.base !== h.base) { letterErrors++; detail.push({ kind: 'letter', expected: e.raw, heard: h.raw }); continue; }
    if (!heardVocalised) { detail.push({ kind: 'unvocalised', expected: e.raw, heard: h.raw }); continue; }
    const ev = vowelOf(e), hv = vowelOf(h);
    const es = hasShadda(e), hs = hasShadda(h);
    let kind = 'same';
    if (ev !== hv) {
      const isFinal = finalWord && i === lastExpIndex;
      if (hv === null || hv === MARK.SUKUN) {
        // The recogniser gave no vowel (or sukun) here. At the end of a stopped-on word that is waqf,
        // not a mistake; elsewhere an expected sukun that is simply omitted is fine too.
        kind = isFinal ? 'waqf' : ev === MARK.SUKUN ? 'same' : 'unmarked';
      } else if (ev === null) {
        // Expected no mark (e.g. long-vowel letter) but heard one: the model is adding a vowel where
        // the rasm has a bare letter; tolerate (long vowels are written without marks).
        kind = 'unmarked';
      } else if (isFinal && (ev === MARK.FATHATAN && hv === MARK.FATHA)) {
        kind = 'waqf'; // tanween fath stopped on becomes alif of madd
      } else {
        kind = 'vowel';
        vowelErrors.push({ index: i, letter: e.base, expected: ev, heard: hv, expectedName: markName(ev), heardName: markName(hv) });
      }
    }
    if (kind === 'same' && es !== hs && hv !== null) {
      // Shadda present/absent with vowels otherwise equal: gemination error (counted as a vowel-class error).
      kind = 'vowel';
      vowelErrors.push({ index: i, letter: e.base, expected: es ? MARK.SHADDA : null, heard: hs ? MARK.SHADDA : null, expectedName: es ? 'shadda' : 'no shadda', heardName: hs ? 'shadda' : 'no shadda' });
    }
    detail.push({ kind, expected: e.raw, heard: h.raw });
  }
  let status = 'ok';
  if (letterErrors > 0) status = 'letter';
  else if (vowelErrors.length > 0) status = 'vowel';
  else if (!heardVocalised && hrd.length > 0) status = 'unvocalised';
  return { status, letterErrors, vowelErrors, detail, expected: expectedRaw, heard: heardRaw };
}

/** Word-level similarity on skeletons (0..1), for aligning the two word sequences. */
function skeletonSimilarity(a, b) {
  const x = skeleton(a).replace(/ا/g, ''), y = skeleton(b).replace(/ا/g, '');
  if (x === y) return 1;
  if (!x.length || !y.length) return 0;
  const n = x.length, m = y.length;
  let prev = Array.from({ length: m + 1 }, (_, j) => j), cur = new Array(m + 1).fill(0);
  for (let i = 1; i <= n; i++) {
    cur[0] = i;
    for (let j = 1; j <= m; j++) cur[j] = Math.min(cur[j - 1] + 1, prev[j] + 1, prev[j - 1] + (x[i - 1] === y[j - 1] ? 0 : 1));
    [prev, cur] = [cur, prev];
  }
  return 1 - prev[m] / Math.max(n, m);
}

/**
 * Aligns the heard words to the expected words (Needleman-Wunsch on skeletons, same scores as the
 * Dart matcher) and grades each expected word. Returns { words: [{expected, heard, ...compareWord}], extras }.
 */
export function comparePassage(expectedWords, heardText) {
  const heard = normalizeVocalised(heardText).split(' ').filter(Boolean);
  const exp = expectedWords.map((w) => normalizeVocalised(w)).filter(Boolean);
  const n = exp.length, m = heard.length;
  const S = Array.from({ length: n + 1 }, () => new Float64Array(m + 1));
  const M = Array.from({ length: n + 1 }, () => new Int8Array(m + 1));
  for (let i = 1; i <= n; i++) { S[i][0] = -i; M[i][0] = 1; }
  for (let j = 1; j <= m; j++) { S[0][j] = -j; M[0][j] = 2; }
  const sims = exp.map((e) => heard.map((h) => skeletonSimilarity(e, h)));
  for (let i = 1; i <= n; i++) {
    for (let j = 1; j <= m; j++) {
      const sim = sims[i - 1][j - 1];
      const diag = S[i - 1][j - 1] + (sim >= 0.99 ? 3 : sim >= 0.4 ? 1 : -2);
      const up = S[i - 1][j] - 1, left = S[i][j - 1] - 1;
      if (diag >= up && diag >= left) { S[i][j] = diag; M[i][j] = 0; }
      else if (up >= left) { S[i][j] = up; M[i][j] = 1; }
      else { S[i][j] = left; M[i][j] = 2; }
    }
  }
  const words = exp.map((e, k) => ({ expected: expectedWords[k], heard: null, status: 'missed', letterErrors: 0, vowelErrors: [], detail: [] }));
  const extras = [];
  let i = n, j = m;
  while (i > 0 || j > 0) {
    const mv = i === 0 ? 2 : j === 0 ? 1 : M[i][j];
    if (mv === 0) {
      if (sims[i - 1][j - 1] >= 0.4) {
        words[i - 1] = { ...compareWord(exp[i - 1], heard[j - 1], { finalWord: i === n }), expected: expectedWords[i - 1], heard: heard[j - 1] };
      } else { extras.push(heard[j - 1]); }
      i--; j--;
    } else if (mv === 1) { i--; } else { extras.push(heard[j - 1]); j--; }
  }
  return { words, extras: extras.reverse() };
}
