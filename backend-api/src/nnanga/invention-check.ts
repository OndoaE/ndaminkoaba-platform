/**
 * Pure helpers for the tutor "invention check" (scripts/tutor-invention-check.ts):
 * find the Ewondo-looking words in a tutor reply and test them against the
 * platform's own content. Kept free of I/O so it can be unit-tested.
 */

const WORD_RE = /[\p{L}\p{M}]+(?:['’\-][\p{L}\p{M}]+)*/gu;

// Letters that exist in Ewondo orthography but not in English/French.
const EWONDO_LETTERS = /[ɛɔŋəɓɑɲʉɩ]/u;
// Caron, macron, tilde and dot-below are tone/vowel marks used by Ewondo; French
// and English never use them.
const EWONDO_MARKS = /[̣̌̄̃]/u;

export type CandidateKind = 'bold' | 'quote' | 'bare';

export interface Candidate {
  text: string;
  kind: CandidateKind;
}

export type Severity = 'high' | 'medium' | 'review';

export interface Finding {
  word: string;
  span: string;
  kind: CandidateKind;
  severity: Severity;
  note: string;
}

export interface Corpus {
  /** NFC + lower-cased tokens exactly as stored. */
  strict: Set<string>;
  /** Same tokens with every combining mark removed. */
  loose: Set<string>;
}

export function normalizeToken(word: string): string {
  return word.normalize('NFC').toLowerCase();
}

export function stripMarks(word: string): string {
  return word.normalize('NFD').replace(/\p{M}/gu, '').toLowerCase();
}

export function tokenize(text: string | null | undefined): string[] {
  if (!text) return [];
  return text.normalize('NFC').match(WORD_RE) ?? [];
}

export function buildCorpus(texts: Iterable<string | null | undefined>): Corpus {
  const strict = new Set<string>();
  const loose = new Set<string>();
  for (const text of texts) {
    for (const word of tokenize(text)) {
      strict.add(normalizeToken(word));
      loose.add(stripMarks(word));
    }
  }
  return { strict, loose };
}

function hasEwondoSigns(word: string): boolean {
  const nfd = word.normalize('NFD');
  return EWONDO_LETTERS.test(nfd) || EWONDO_MARKS.test(nfd);
}

/**
 * Pulls out the stretches of a reply that are presented as target-language
 * material: **bold**, *italic*, "quoted" or «quoted» spans, plus any bare word
 * that carries Ewondo-only letters or tone marks.
 */
export function extractCandidates(reply: string): Candidate[] {
  const out: Candidate[] = [];
  const text = reply.normalize('NFC');
  const spanRe = /\*\*([^*\n]+)\*\*|\*([^*\n]+)\*|“([^”\n]+)”|"([^"\n]+)"|«([^»\n]+)»/g;
  let remainder = text;
  for (const m of text.matchAll(spanRe)) {
    const bold = m[1];
    const body = bold ?? m[2] ?? m[3] ?? m[4] ?? m[5];
    if (body && body.trim()) out.push({ text: body.trim(), kind: bold ? 'bold' : 'quote' });
    remainder = remainder.replace(m[0], ' ');
  }
  for (const word of tokenize(remainder)) {
    if (hasEwondoSigns(word)) out.push({ text: word, kind: 'bare' });
  }
  return out;
}

/**
 * Returns every word of the reply's candidate spans that cannot be found in
 * the corpus (or in the learner's own question, which the tutor may echo).
 */
export function findUnverified(
  reply: string,
  corpus: Corpus,
  promptText = '',
): Finding[] {
  const promptTokens = new Set(tokenize(promptText).map(normalizeToken));
  const findings: Finding[] = [];
  const seen = new Set<string>();

  for (const candidate of extractCandidates(reply)) {
    for (const word of tokenize(candidate.text)) {
      const key = normalizeToken(word);
      if (seen.has(key)) continue;
      seen.add(key);
      if (/^\d+$/.test(key)) continue;
      if (corpus.strict.has(key) || promptTokens.has(key)) continue;

      const ewondoLike = hasEwondoSigns(word);
      if (corpus.loose.has(stripMarks(word))) {
        // Known letters, different tone marks: only matters for Ewondo-looking words.
        if (ewondoLike) {
          findings.push({
            word,
            span: candidate.text,
            kind: candidate.kind,
            severity: 'medium',
            note: 'exists in the corpus but with different tone marks/diacritics',
          });
        }
        continue;
      }
      findings.push({
        word,
        span: candidate.text,
        kind: candidate.kind,
        severity: ewondoLike ? 'high' : 'review',
        note: ewondoLike
          ? 'Ewondo-looking word that appears nowhere in the platform content'
          : 'highlighted word not found in the platform content (may be plain English/French)',
      });
    }
  }
  return findings;
}
