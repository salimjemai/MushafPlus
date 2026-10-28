// node tool/asr_prototype/harakat.test.mjs
import assert from 'node:assert/strict';
import { compareWord, comparePassage, normalizeVocalised, isVocalised } from './harakat.js';
import { FATIHA, TEST_SET } from './fatiha.js';

// Uthmani and simple vocalised spellings of the same word compare clean.
assert.equal(compareWord('ٱلْعَٰلَمِينَ', 'الْعَالَمِينَ').status, 'ok');
assert.equal(compareWord('ٱلرَّحْمَٰنِ', 'الرَّحْمَٰنِ').status, 'ok');
assert.equal(compareWord('ٱلرَّحْمَٰنِ', 'الرَّحْمَنِ').status, 'ok');
assert.equal(compareWord('ٱلضَّآلِّينَ', 'الضَّالِّينَ').status, 'ok');
assert.equal(compareWord('إِيَّاكَ', 'إِيَّاكَ').status, 'ok');

// A vowel slip on the same skeleton is a vowel error, naming the letter and marks.
let r = compareWord('ٱلْحَمْدُ', 'الْحَمْدَ');
assert.equal(r.status, 'vowel');
assert.deepEqual(r.vowelErrors.map((v) => [v.letter, v.expectedName, v.heardName]), [['د', 'damma', 'fatha']]);
r = compareWord('رَبِّ', 'رَبُّ');
assert.equal(r.status, 'vowel');
assert.equal(r.vowelErrors[0].heardName, 'damma');

// Missing shadda is a vowel-class error; a letter change is a letter error.
assert.equal(compareWord('رَبِّ', 'رَبِ').status, 'vowel');
assert.equal(compareWord('نَعْبُدُ', 'نَعْبُتُ').status, 'letter');

// Unvocalised output (today's recognisers) gives no verdict rather than a false error.
assert.equal(compareWord('ٱلْحَمْدُ', 'الحمد').status, 'unvocalised');
assert.equal(isVocalised(normalizeVocalised('الحمد لله')), false);

// Waqf: a stopped-on final word may drop its last vowel.
assert.equal(compareWord('ٱلرَّحِيمِ', 'الرَّحِيمْ', { finalWord: true }).status, 'ok');
assert.equal(compareWord('ٱلرَّحِيمِ', 'الرَّحِيم', { finalWord: true }).status, 'ok');
assert.equal(compareWord('ٱلرَّحِيمِ', 'الرَّحِيمُ', { finalWord: true }).status, 'vowel');

// Passage level: every synthetic test case flags exactly its mutated word (and nothing else).
for (const [id, t] of Object.entries(TEST_SET)) {
  const g = comparePassage(FATIHA[t.ayah - 1].split(' '), t.spoken);
  const flagged = g.words.map((w, i) => (w.status === 'vowel' ? i : -1)).filter((i) => i >= 0);
  const letter = g.words.filter((w) => w.status === 'letter' || w.status === 'missed').length;
  assert.equal(letter, 0, `${id}: letter errors ${JSON.stringify(g.words)}`);
  if (t.mutated === null) assert.deepEqual(flagged, [], `${id}: ${JSON.stringify(g.words)}`);
  else if (id === 'bad_5b') assert.deepEqual(flagged, [0, 2], id);
  else assert.deepEqual(flagged, [t.mutated], `${id}: flagged ${flagged} ${JSON.stringify(g.words.map((w) => [w.status, w.vowelErrors]))}`);
}
console.log('harakat.test.mjs: all assertions passed');
