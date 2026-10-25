import {
  clip,
  detectSyllabaryIntent,
  extractLetterCandidates,
  hasRealText,
} from './knowledge-helpers';

describe('hasRealText', () => {
  it('rejects empty and placeholder text', () => {
    expect(hasRealText(null)).toBe(false);
    expect(hasRealText('')).toBe(false);
    expect(hasRealText('   ')).toBe(false);
    expect(hasRealText('bjkbcvljbnlwcbljknbljwkcv')).toBe(false);
    expect(hasRealText('Short vowels')).toBe(false);
  });

  it('accepts a real sentence', () => {
    expect(hasRealText('In this lesson you will learn how to greet your elders politely.')).toBe(true);
  });
});

describe('detectSyllabaryIntent', () => {
  it('recognises English and French questions about the alphabet', () => {
    expect(detectSyllabaryIntent('What are the syllables for the letter H?')).toBe(true);
    expect(detectSyllabaryIntent('Quelle est la lettre dz dans le syllabaire ?')).toBe(true);
    expect(detectSyllabaryIntent('Teach me the vowels')).toBe(true);
  });

  it('ignores unrelated questions', () => {
    expect(detectSyllabaryIntent('How do you say papaya in Ewondo?')).toBe(false);
  });
});

describe('extractLetterCandidates', () => {
  const known = ['B', 'D', 'dz', 'gb', 'H', 'ŋ', 'a'];

  it('finds a single named letter, case-insensitively', () => {
    expect(extractLetterCandidates('Show me the letter h please', known)).toEqual(['H']);
  });

  it('finds digraph letters', () => {
    expect(extractLetterCandidates('la lettre "dz" en ewondo', known)).toEqual(['dz']);
  });

  it('returns nothing when no known letter is named', () => {
    expect(extractLetterCandidates('What is the syllabary?', known)).toEqual([]);
  });
});

describe('clip', () => {
  it('keeps short text and shortens long text', () => {
    expect(clip('abc', 10)).toBe('abc');
    expect(clip('a'.repeat(50), 10)).toBe('a'.repeat(10) + '…');
    expect(clip(null)).toBe('');
  });
});
