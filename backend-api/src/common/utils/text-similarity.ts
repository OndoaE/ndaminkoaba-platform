/// Normalizes text for phonetic-closeness comparison: lowercase, strip
/// accents/diacritics (ASR output frequently drops the diacritics Ewondo
/// text uses) and non-letter punctuation, collapse whitespace.
function normalize(text: string): string {
  return text
    .toLowerCase()
    .normalize('NFD')
    .replace(/[̀-ͯ]/g, '')
    .replace(/[^\p{L}\s]/gu, '')
    .trim()
    .replace(/\s+/g, ' ');
}

function levenshteinDistance(a: string, b: string): number {
  const rows = a.length + 1;
  const cols = b.length + 1;
  const distances: number[][] = Array.from({ length: rows }, () => new Array(cols).fill(0));

  for (let i = 0; i < rows; i++) distances[i][0] = i;
  for (let j = 0; j < cols; j++) distances[0][j] = j;

  for (let i = 1; i < rows; i++) {
    for (let j = 1; j < cols; j++) {
      const cost = a[i - 1] === b[j - 1] ? 0 : 1;
      distances[i][j] = Math.min(
        distances[i - 1][j] + 1,
        distances[i][j - 1] + 1,
        distances[i - 1][j - 1] + cost,
      );
    }
  }

  return distances[rows - 1][cols - 1];
}

/// Scores how close `transcript` is to `targetText`, 0-100, via a
/// normalized Levenshtein edit-distance ratio. Deterministic and free —
/// deliberately not LLM-judged, so the number is stable and explainable.
export function scorePronunciation(transcript: string, targetText: string): number {
  const a = normalize(transcript);
  const b = normalize(targetText);

  if (a.length === 0 && b.length === 0) return 100;
  if (a.length === 0 || b.length === 0) return 0;

  const distance = levenshteinDistance(a, b);
  const maxLength = Math.max(a.length, b.length);
  const ratio = 1 - distance / maxLength;

  return Math.max(0, Math.round(ratio * 100));
}
