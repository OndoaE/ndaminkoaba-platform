/**
 * Detects whether a learner's chat message is in English or French, so
 * Nnanga can be told explicitly which language to reply in on every turn.
 *
 * A system-prompt instruction alone ("reply in the learner's language")
 * turned out unreliable in practice: gpt-4o-mini tends to anchor to
 * whichever language dominates the recent conversation history and ignore
 * a language switch in the newest message (observed: after a couple of
 * French turns, a plain English follow-up still got answered in French).
 * Detecting the language in code and injecting an explicit per-message
 * directive right next to the content — rather than relying on the model
 * to infer it from a static system-prompt rule — is far more reliable for
 * small models.
 *
 * Deliberately dependency-free: a stopword/character heuristic is more
 * than enough to tell English from French on short chat messages, and
 * avoids pulling in a full language-ID library for a two-way decision.
 */

const FRENCH_STOPWORDS = new Set([
  'le', 'la', 'les', 'un', 'une', 'des', 'du', 'de', 'et', 'ou', 'est', 'es',
  'suis', 'sont', 'avec', 'pour', 'sur', 'dans', 'comment', 'dit', 'dis',
  'tu', 'vous', 'je', 'nous', 'ca', 'quoi', 'ou', 'pourquoi', 'merci',
  'bonjour', 'salut', 'au', 'revoir', 'sil', 'etre', 'avoir', 'fait',
  'peux', 'peut', 'veux', 'veut', 'mon', 'ma', 'mes', 'ton', 'ta', 'tes',
  'que', 'qui', 'pas', 'plus', 'tres', 'bien', 'oui', 'non', 'aussi',
  'apprendre', 'apprends', 'expression', 'mot', 'phrase', 'langue',
]);

const ENGLISH_STOPWORDS = new Set([
  'the', 'is', 'are', 'and', 'or', 'how', 'do', 'does', 'you', 'i', 'we',
  'what', 'where', 'why', 'thanks', 'thank', 'hello', 'hi', 'can', 'could',
  'would', 'teach', 'please', 'that', 'this', 'with', 'for', 'on', 'in',
  'my', 'your', 'me', 'to', 'a', 'of', 'word', 'mean', 'means', 'greeting',
  'word', 'language', 'learn', 'want', 'yes', 'no', 'also', 'very', 'good',
]);

const FRENCH_ACCENT_PATTERN = /[àâäéèêëïîôöùûüçœ]/i;

export function detectReplyLanguage(text: string): 'en' | 'fr' | null {
  const words = text.toLowerCase().match(/[a-zàâäéèêëïîôöùûüçœ]+/gi) ?? [];
  if (words.length === 0) return null;

  let frenchScore = 0;
  let englishScore = 0;

  for (const word of words) {
    if (FRENCH_STOPWORDS.has(word)) frenchScore++;
    if (ENGLISH_STOPWORDS.has(word)) englishScore++;
  }

  // Accented characters (é, à, ç, ...) are near-exclusive to French among
  // the two candidates and a strong signal even in short messages that
  // don't happen to contain a listed stopword.
  if (FRENCH_ACCENT_PATTERN.test(text)) frenchScore += 2;

  if (frenchScore === 0 && englishScore === 0) return null;
  if (frenchScore === englishScore) return null;

  return frenchScore > englishScore ? 'fr' : 'en';
}
