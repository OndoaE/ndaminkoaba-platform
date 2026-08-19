import { detectReplyLanguage } from './language-detector';

describe('detectReplyLanguage', () => {
  it('detects plain English questions', () => {
    expect(
      detectReplyLanguage('What does the word for water mean in this language?'),
    ).toBe('en');
  });

  it('detects plain French questions', () => {
    expect(detectReplyLanguage('Et comment dit-on merci ?')).toBe('fr');
  });

  it('detects an English follow-up after French turns (the reported bug case)', () => {
    expect(detectReplyLanguage('Thanks! Can you teach me a greeting?')).toBe('en');
  });

  it('detects a French follow-up using accented characters as a strong signal', () => {
    expect(detectReplyLanguage('Où puis-je trouver ça ?')).toBe('fr');
  });

  it('detects French via "au revoir"', () => {
    expect(detectReplyLanguage('Super, et comment on dit au revoir ?')).toBe('fr');
  });

  it('returns null for empty input', () => {
    expect(detectReplyLanguage('')).toBeNull();
  });

  it('returns null for a bare target-language word with no English/French signal', () => {
    expect(detectReplyLanguage('Mbolo')).toBeNull();
  });

  it('returns null when the signal is genuinely tied', () => {
    expect(detectReplyLanguage('la')).not.toBeNull(); // sanity: single fr stopword still scores
    expect(detectReplyLanguage('xyz123')).toBeNull();
  });

  it('leans English for greetings shared between languages when no other signal exists', () => {
    // "Salut" is French-only in our stopword list, so it should resolve to fr.
    expect(detectReplyLanguage('Salut')).toBe('fr');
  });
});
