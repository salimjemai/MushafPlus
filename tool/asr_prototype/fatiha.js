// Al-Fatiha in the app's Uthmani text (assets/data/quran_uthmani.json) and the
// synthetic test set: the same ayat with one deliberate vowel mistake each.
// testdata/gen_tts.mjs turns `spoken` into audio; the prototype grades the
// transcript against `ayah` and checks that the mutated word is the one flagged.

export const FATIHA = [
  'بِسْمِ ٱللَّهِ ٱلرَّحْمَٰنِ ٱلرَّحِيمِ',
  'ٱلْحَمْدُ لِلَّهِ رَبِّ ٱلْعَٰلَمِينَ',
  'ٱلرَّحْمَٰنِ ٱلرَّحِيمِ',
  'مَٰلِكِ يَوْمِ ٱلدِّينِ',
  'إِيَّاكَ نَعْبُدُ وَإِيَّاكَ نَسْتَعِينُ',
  'ٱهْدِنَا ٱلصِّرَٰطَ ٱلْمُسْتَقِيمَ',
  'صِرَٰطَ ٱلَّذِينَ أَنْعَمْتَ عَلَيْهِمْ غَيْرِ ٱلْمَغْضُوبِ عَلَيْهِمْ وَلَا ٱلضَّآلِّينَ',
];

// id -> { ayah (1-based), spoken (what the TTS says), mutated (0-based word index with the wrong vowel, or null) }
export const TEST_SET = {
  ok_1: { ayah: 1, spoken: 'بِسْمِ اللَّهِ الرَّحْمَٰنِ الرَّحِيمِ', mutated: null },
  ok_2: { ayah: 2, spoken: 'الْحَمْدُ لِلَّهِ رَبِّ الْعَالَمِينَ', mutated: null },
  ok_3: { ayah: 3, spoken: 'الرَّحْمَٰنِ الرَّحِيمِ', mutated: null },
  ok_4: { ayah: 4, spoken: 'مَالِكِ يَوْمِ الدِّينِ', mutated: null },
  ok_5: { ayah: 5, spoken: 'إِيَّاكَ نَعْبُدُ وَإِيَّاكَ نَسْتَعِينُ', mutated: null },
  ok_6: { ayah: 6, spoken: 'اهْدِنَا الصِّرَاطَ الْمُسْتَقِيمَ', mutated: null },
  ok_7: { ayah: 7, spoken: 'صِرَاطَ الَّذِينَ أَنْعَمْتَ عَلَيْهِمْ غَيْرِ الْمَغْضُوبِ عَلَيْهِمْ وَلَا الضَّالِّينَ', mutated: null },
  bad_2a: { ayah: 2, spoken: 'الْحَمْدَ لِلَّهِ رَبِّ الْعَالَمِينَ', mutated: 0, note: 'الحمدَ: fatha for damma' },
  bad_2b: { ayah: 2, spoken: 'الْحَمْدُ لِلَّهِ رَبُّ الْعَالَمِينَ', mutated: 2, note: 'ربُّ: damma for kasra' },
  bad_4a: { ayah: 4, spoken: 'مَالِكُ يَوْمِ الدِّينِ', mutated: 0, note: 'مالكُ: damma for kasra' },
  bad_4b: { ayah: 4, spoken: 'مَالِكِ يَوْمَ الدِّينِ', mutated: 1, note: 'يومَ: fatha for kasra' },
  bad_5a: { ayah: 5, spoken: 'إِيَّاكَ نَعْبُدَ وَإِيَّاكَ نَسْتَعِينُ', mutated: 1, note: 'نعبدَ: fatha for damma' },
  bad_5b: { ayah: 5, spoken: 'إِيَّاكِ نَعْبُدُ وَإِيَّاكِ نَسْتَعِينُ', mutated: 0, note: 'إياكِ: kasra for fatha (also word 2)' },
  bad_6a: { ayah: 6, spoken: 'اهْدِنَا الصِّرَاطُ الْمُسْتَقِيمَ', mutated: 1, note: 'الصراطُ: damma for fatha' },
  bad_7a: { ayah: 7, spoken: 'صِرَاطَ الَّذِينَ أَنْعَمْتُ عَلَيْهِمْ غَيْرِ الْمَغْضُوبِ عَلَيْهِمْ وَلَا الضَّالِّينَ', mutated: 2, note: 'أنعمتُ: damma for fatha (changes meaning)' },
  bad_7b: { ayah: 7, spoken: 'صِرَاطَ الَّذِينَ أَنْعَمْتَ عَلَيْهِمْ غَيْرَ الْمَغْضُوبِ عَلَيْهِمْ وَلَا الضَّالِّينَ', mutated: 4, note: 'غيرَ: fatha for kasra' },
};

/** Guesses the ayah and test id from a file name like voice_a_bad_2a.mp3 or recitation_001004.mp3. */
export function describeFile(name) {
  const base = name.replace(/\.[a-z0-9]+$/i, '');
  const t = base.match(/(ok_\d|bad_\d[a-z])$/);
  if (t) return { id: t[1], ayah: TEST_SET[t[1]].ayah, synthetic: true };
  const a = base.match(/001(\d{3})$/);
  if (a) return { id: null, ayah: Number(a[1]), synthetic: false };
  return { id: null, ayah: null, synthetic: false };
}
