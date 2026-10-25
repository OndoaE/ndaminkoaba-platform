import {
  buildCorpus,
  extractCandidates,
  findUnverified,
  normalizeToken,
  stripMarks,
} from './invention-check';

describe('invention-check', () => {
  const corpus = buildCorpus([
    'mbolo = hello',
    'ɔ́kɔ̀ŋ — the book',
    'Say hello to your friend',
  ]);

  it('normalises composed and decomposed forms to the same token', () => {
    expect(normalizeToken('fufólo')).toBe(normalizeToken('fufólo'));
    expect(stripMarks('ɔ́kɔ̀ŋ')).toBe('ɔkɔŋ');
  });

  it('extracts bold, quoted and Ewondo-lettered bare words', () => {
    const found = extractCandidates('Say **mbolo** or "abui", also ŋgɔn is a word.');
    expect(found).toEqual([
      { text: 'mbolo', kind: 'bold' },
      { text: 'abui', kind: 'quote' },
      { text: 'ŋgɔn', kind: 'bare' },
    ]);
  });

  it('passes words that exist in the corpus', () => {
    expect(findUnverified('Say **mbolo** to a friend.', corpus)).toEqual([]);
  });

  it('flags an Ewondo-looking word missing from the corpus as high', () => {
    const f = findUnverified('The word is **ŋgɛlɛ**.', corpus);
    expect(f).toHaveLength(1);
    expect(f[0]).toMatchObject({ word: 'ŋgɛlɛ', severity: 'high' });
  });

  it('flags a plain highlighted word missing from the corpus as review', () => {
    const f = findUnverified('Say **zorbakulu**.', corpus);
    expect(f[0]).toMatchObject({ word: 'zorbakulu', severity: 'review' });
  });

  it('reports a tone-mark mismatch as medium, not high', () => {
    const f = findUnverified('Use **ɔkɔŋ**.', corpus);
    expect(f[0]).toMatchObject({ severity: 'medium' });
  });

  it('does not flag words the learner typed themselves', () => {
    expect(findUnverified('You asked about **zorbakulu**.', corpus, 'what is zorbakulu')).toEqual([]);
  });

  it('ignores digits and French accents on ordinary words', () => {
    expect(findUnverified('Il y a **3** mots, c’est **mbolo**.', corpus)).toEqual([]);
  });
});
