/**
 * Small pure helpers used by KnowledgeService (kept separate so they can be
 * unit-tested without a database).
 */

/**
 * True when a lesson/page text looks like real prose rather than a placeholder
 * typed while a draft was being created (e.g. "bjkbcvljbnlwcbljknbljwkcv").
 * Real lessons in the pilot have a median of a few hundred characters; the
 * placeholders are a single run of letters. Six separate words is a deliberately
 * low bar: it only rejects text that cannot teach anything.
 */
export function hasRealText(text: string | null | undefined): boolean {
  if (!text) return false;
  const words = text.trim().split(/\s+/).filter((w) => w.length > 0);
  return words.length >= 6;
}

const SYLLABARY_INTENT =
  /\b(syllab\w*|alphabet\w*|letters?|lettres?|consonn?ants?|consonnes?|vowels?|voyelles?|literacy|alphab\w*)\b/i;

/** True when the learner is asking about the syllabary / alphabet / a letter. */
export function detectSyllabaryIntent(prompt: string): boolean {
  return SYLLABARY_INTENT.test(prompt);
}

/**
 * Finds which known syllabary letters (consonants, or vowels for vowel-only
 * letters) the prompt names. Matching is whole-token and case-insensitive so a
 * request like "the letter H" or "la lettre dz" resolves to the stored letter.
 */
export function extractLetterCandidates(prompt: string, knownLetters: string[]): string[] {
  const tokens = prompt
    .split(/[\s"“”'‘’.,;:!?()\[\]{}\/\\-]+/)
    .map((t) => t.trim().toLowerCase())
    .filter((t) => t.length > 0 && t.length <= 3);
  const found = new Set<string>();
  for (const letter of knownLetters) {
    if (!letter) continue;
    if (tokens.includes(letter.toLowerCase())) found.add(letter);
  }
  return [...found];
}

/** Shortens long free text so a handful of pages cannot flood the model context. */
export function clip(text: string | null | undefined, max = 600): string {
  if (!text) return '';
  const t = text.trim();
  return t.length <= max ? t : `${t.slice(0, max).trimEnd()}…`;
}
