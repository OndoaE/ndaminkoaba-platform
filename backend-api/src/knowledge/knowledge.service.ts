import { Injectable } from '@nestjs/common';
import { Prisma } from '@prisma/client';
import { PrismaService } from '../prisma/prisma.service';
import {
  clip,
  detectSyllabaryIntent,
  extractLetterCandidates,
  hasRealText,
} from './knowledge-helpers';

/// Upper bound on how many vocabulary rows are listed in full in every tutor
/// request. The pilot holds 1,272 entries, so the earlier cap of 500 hid more
/// than half of them from the "complete" list the model is told to trust.
const FULL_VOCABULARY_LIMIT = 2500;

interface WeightedField {
  value: string | null | undefined;
  weight: number;
}

interface DetectedPassage {
  canonicalBook: string;
  chapter: number;
  verseStart?: number;
  verseEnd?: number;
}

// Phrasings that ask for a specific target-language translation, in English
// and French. Detecting these lets the AI layer treat "we have zero real
// matches for this" as a hard stop rather than a soft hint — small models
// reliably invent a plausible-looking word rather than admit ignorance when
// they're merely asked to be careful, so ungrounded translation requests
// need a different, translation-forbidding task framing entirely (see
// AiService.generateTutorResponse), not just a stronger warning.
const TRANSLATION_INTENT_PATTERNS = [
  /how\s+(do|would|can|might)\s+(you|i|we)\s+say\b/i,
  /how\s+to\s+say\b/i,
  /what('?s|\s+is)\s+the\s+word\s+for\b/i,
  /\btranslate\b/i,
  /\btranslation\s+of\b/i,
  /comment\s+(dit-on|dire|dis-tu|dis-je)\b/i,
  /comment\s+(peut-on|peux-tu|puis-je)\s+dire\b/i,
  /\btraduis\b/i,
  /\btraduction\s+de\b/i,
  /quel\s+est\s+le\s+mot\s+pour\b/i,
  // Asking for a run of target-language words (counting) is a translation in
  // disguise: the invention check caught the tutor making up the numbers 1-10.
  /\bcount(ing)?\b/i,
  /\bcompter\b/i,
];

@Injectable()
export class KnowledgeService {
  constructor(private readonly prisma: PrismaService) {}

  private detectsTranslationIntent(prompt: string): boolean {
    return TRANSLATION_INTENT_PATTERNS.some((pattern) => pattern.test(prompt));
  }

  // Mirrors the alias list the Flutter learner app uses to recognize Gospel
  // books saved under different free-text spellings (admins upload USFM
  // whose \h header can read "Matthew", "Mateus", etc.) — kept here too so
  // "give me Matthew chapter 5" resolves correctly regardless of which
  // spelling the content was saved under.
  private readonly bookAliases: Record<string, string[]> = {
    matthew: ['matthew', 'mathew', 'matt', 'mt', 'matthieu', 'mateus'],
    mark: ['mark', 'mrk', 'mk', 'marc', 'markus'],
    luke: ['luke', 'luk', 'lk', 'luc', 'lukas'],
    john: ['john', 'jhn', 'jn', 'jean', 'yoannes', 'yoane'],
  };

  private normalizeBookAlias(word: string): string | null {
    const normalized = word.toLowerCase().replace(/[^a-z]/g, '');
    for (const [canonical, aliases] of Object.entries(this.bookAliases)) {
      if (aliases.includes(normalized)) return canonical;
    }
    return null;
  }

  private cleanPrompt(prompt: string): string {
    return prompt
      .replace(/[?.,!"“”«»]/g, ' ')
      .replace(/\s+/g, ' ')
      .trim();
  }

  // The target language's own name (and generic platform/domain words) show
  // up in almost every learner question and in almost every lesson/course
  // title ("Discover the Ewondo Language", "Welcome to NdaMinkoaba") —
  // without excluding them, a question about literally anything scores a
  // false "strong match" against unrelated content just because both happen
  // to mention "Ewondo", which was tricking the AI into treating an
  // unrelated lesson as grounding and then inventing the actual answer.
  private extractKeywords(prompt: string, languageName?: string): string[] {
    const dynamicStopWords = languageName
      ? languageName.toLowerCase().split(/\s+/)
      : [];

    // "count" never appears in a lesson titled "The Numbers from 1 to 9", so
    // counting questions also search for the words the content actually uses.
    const synonyms = /\b(count(ing)?|compter)\b/i.test(prompt)
      ? ['number', 'numbers', 'nombre', 'nombres']
      : [];

    const base = this.cleanPrompt(prompt)
      .toLowerCase()
      .split(' ')
      .filter((word) => word.length > 2)
      .filter(
        (word) =>
          ![
            // English
            'explain', 'teacher', 'like', 'what', 'does', 'mean', 'means',
            'please', 'tell', 'about', 'word', 'the', 'and', 'for', 'you',
            'how', 'can', 'are', 'this', 'that', 'with', 'language',
            'languages', 'learn', 'learning', 'speak', 'translate',
            'translation', 'say', 'ndaminkoaba', 'nnanga', 'platform',
            'lesson', 'lessons', 'book', 'books', 'have', 'called',
            // Generic question/command words: they appear in thousands of verses and
            // lesson texts, so as keywords they bury the one distinctive term (a name,
            // a rare word) under irrelevant substring hits.
            'which', 'verse', 'verses', 'mention', 'mentions', 'mentioned', 'show', 'give',
            'list', 'example', 'examples', 'words', 'syllable', 'syllables', 'letter',
            'letters', 'know', 'find', 'there', 'their', 'where', 'when', 'who', 'whom',
            'your', 'from', 'was', 'were', 'will', 'would', 'could', 'should', 'into',
            'than', 'then', 'them', 'they', 'these', 'those', 'also', 'some', 'any',
            'each', 'most', 'more', 'many', 'much', 'very', 'just', 'only', 'over',
            'such', 'here', 'contain', 'contains', 'does', 'having',
            // French
            'expliquer', 'professeur', 'comme', 'quoi', 'que', 'veut',
            'dire', 'signifie', 'sil', 'vous', 'plait', 'dis', 'moi',
            'sur', 'mot', 'les', 'des', 'une', 'pour', 'avec', 'comment',
            'peux', 'peut', 'langue', 'langues', 'apprendre', 'parler',
            'traduire', 'traduction', 'leçon', 'leçons', 'livre', 'livres',
            'quel', 'quelle', 'quels', 'quelles', 'dans', 'est', 'sont', 'mais', 'donc',
            'cette', 'ces', 'celui', 'montre', 'donne', 'liste', 'exemple', 'exemples',
            'mots', 'verset', 'versets', 'mentionne', 'lettre', 'lettres', 'syllabe',
            'syllabes', 'qui', 'quand', 'parle', 'parle-moi', 'contient',
            ...dynamicStopWords,
          ].includes(word),
      );

    return [...new Set([...base, ...synonyms])];
  }

  /// Recognizes requests for a specific Bible passage — "Matthew 5",
  /// "John 3:16", "Luke 2:1-20", "chapitre 5 de Matthieu" — so the whole
  /// chapter/verse range can be fetched and quoted verbatim instead of
  /// relying on fuzzy keyword search to happen to surface the right verses.
  private detectPassageRequest(prompt: string): DetectedPassage | null {
    const bookPattern = Object.values(this.bookAliases).flat().join('|');

    const bookFirst = new RegExp(
      `\\b(${bookPattern})\\.?\\s+(?:chapter|chapitre)?\\s*(\\d{1,3})(?:\\s*[:.]\\s*(\\d{1,3})(?:\\s*[-–]\\s*(\\d{1,3}))?)?`,
      'i',
    );
    const chapterFirst = new RegExp(
      `\\b(?:chapter|chapitre)\\s*(\\d{1,3})\\s+(?:of|de|from)\\s+(${bookPattern})\\b`,
      'i',
    );

    const m1 = prompt.match(bookFirst);
    if (m1) {
      const canonical = this.normalizeBookAlias(m1[1]);
      if (canonical) {
        return {
          canonicalBook: canonical,
          chapter: parseInt(m1[2], 10),
          verseStart: m1[3] ? parseInt(m1[3], 10) : undefined,
          verseEnd: m1[4] ? parseInt(m1[4], 10) : undefined,
        };
      }
    }

    const m2 = prompt.match(chapterFirst);
    if (m2) {
      const canonical = this.normalizeBookAlias(m2[2]);
      if (canonical) {
        return { canonicalBook: canonical, chapter: parseInt(m2[1], 10) };
      }
    }

    return null;
  }

  /// Different USFM uploads for the same Gospel can be saved under
  /// different book-name spellings (e.g. "Mathew" vs "Mateus") — among the
  /// spellings that actually have this chapter, picks whichever has the
  /// most verses for it, so a full-chapter request always gets the
  /// complete upload rather than a stray old test entry.
  private async resolveBookString(
    canonical: string,
    chapter: number,
    languageId?: string,
  ): Promise<string | null> {
    const rows = await this.prisma.bibleVerse.groupBy({
      by: ['book'],
      where: { chapter, languageId },
      _count: { _all: true },
    });

    const candidates = rows.filter((r) => this.normalizeBookAlias(r.book) === canonical);
    if (candidates.length === 0) return null;

    candidates.sort((a, b) => b._count._all - a._count._all);
    return candidates[0].book;
  }

  private async findBiblePassage(prompt: string, languageId?: string) {
    const detected = this.detectPassageRequest(prompt);
    if (!detected) return null;

    const resolvedBook = await this.resolveBookString(detected.canonicalBook, detected.chapter, languageId);
    if (!resolvedBook) return null;

    const where: Prisma.BibleVerseWhereInput = { book: resolvedBook, chapter: detected.chapter, languageId };
    if (detected.verseStart != null) {
      where.verse = detected.verseEnd != null
        ? { gte: detected.verseStart, lte: detected.verseEnd }
        : detected.verseStart;
    }

    const verses = await this.prisma.bibleVerse.findMany({ where, orderBy: { verse: 'asc' } });
    if (verses.length === 0) return null;

    return {
      book: resolvedBook,
      chapter: detected.chapter,
      verseStart: detected.verseStart,
      verseEnd: detected.verseEnd,
      verses,
    };
  }

  /// Scores how strongly a row matches the question. Fields carry a weight
  /// so a hit on a row's PRIMARY field (the target-language word itself, a lesson
  /// title) counts far more than an incidental hit in a secondary field
  /// (an example sentence) — this is what stops the AI from confidently
  /// citing the wrong vocabulary entry when several rows share a loose
  /// keyword. A full-phrase hit, or an exact whole-word match on a primary
  /// field, is weighted especially heavily.
  private scoreMatch(fields: WeightedField[], cleanedPrompt: string, keywords: string[]): number {
    const norm = (text: string) => text.normalize('NFC').toLowerCase();
    const lowerPrompt = norm(cleanedPrompt);
    const normKeywords = keywords.map(norm);
    let score = 0;

    for (const { value, weight } of fields) {
      if (!value) continue;
      const lower = norm(value);

      if (lowerPrompt.length > 2 && lower.includes(lowerPrompt)) {
        score += 5 * weight;
      }
      for (const keyword of normKeywords) {
        if (lower === keyword) {
          score += 8 * weight;
        } else if (keyword.length >= 4 && lower.includes(keyword)) {
          // 3-letter keywords (common short function words like the French
          // "est") are too likely to substring-match inside unrelated
          // longer words/content — only count them on an exact whole-field
          // match (handled above), not a loose substring hit.
          score += 1 * weight;
        }
      }
    }

    return score;
  }

  /// Pulls short windows of text around each keyword hit inside a book's
  /// (potentially very long) extracted content, instead of the AI service
  /// ever seeing the whole book — keeps the LLM context small while still
  /// letting Nnanga quote real passages.
  private extractExcerpts(content: string, keywords: string[], maxExcerpts = 2, radius = 300): string[] {
    const lower = content.toLowerCase();
    const excerpts: string[] = [];
    const usedRanges: Array<[number, number]> = [];

    for (const keyword of keywords) {
      if (excerpts.length >= maxExcerpts) break;
      const index = lower.indexOf(keyword.toLowerCase());
      if (index === -1) continue;

      const start = Math.max(0, index - radius);
      const end = Math.min(content.length, index + keyword.length + radius);
      if (usedRanges.some(([s, e]) => start < e && end > s)) continue;

      usedRanges.push([start, end]);
      const prefix = start > 0 ? '…' : '';
      const suffix = end < content.length ? '…' : '';
      excerpts.push(`${prefix}${content.slice(start, end).trim()}${suffix}`);
    }

    return excerpts;
  }

  private rankAndTake<T>(
    pool: T[],
    scorer: (row: T) => number,
    limit: number,
  ): { ranked: T[]; topScore: number } {
    const scored = pool
      .map((row) => ({ row, score: scorer(row) }))
      .filter((entry) => entry.score > 0)
      .sort((a, b) => b.score - a.score);

    return {
      ranked: scored.slice(0, limit).map((entry) => entry.row),
      topScore: scored[0]?.score ?? 0,
    };
  }

  async search(prompt: string, languageId?: string, languageName?: string) {
    const cleanedPrompt = this.cleanPrompt(prompt);
    const keywords = this.extractKeywords(prompt, languageName);
    const insensitive = Prisma.QueryMode.insensitive;
    const terms = [cleanedPrompt, ...keywords].filter((t) => t.length > 2);

    // The same accented letter can be stored as one code point (NFC, "ó") or as a
    // base letter plus a combining accent (NFD, "o" + U+0301). Words pasted from
    // different tools mix both, and a plain `contains` only matches the form it
    // was given, so every database search tries both forms.
    const withVariants = (list: string[]) => [
      ...new Set(list.flatMap((t) => [t, t.normalize('NFC'), t.normalize('NFD')])),
    ];
    const termsAll = withVariants(terms);
    const keywordsAll = withVariants(keywords);

    const biblePassage = await this.findBiblePassage(prompt, languageId);

    const vocabularyPool = terms.length
      ? await this.prisma.vocabulary.findMany({
          where: {
            languageId,
            OR: termsAll.flatMap((term) => [
              { word: { contains: term, mode: insensitive } },
              { frenchMeaning: { contains: term, mode: insensitive } },
              { englishMeaning: { contains: term, mode: insensitive } },
              { exampleSentence: { contains: term, mode: insensitive } },
            ]),
          },
          take: 150,
          include: { pronunciations: true, category: true, lesson: true },
        })
      : [];

    const { ranked: vocabulary, topScore: vocabularyTopScore } = this.rankAndTake(
      vocabularyPool,
      (v) => this.scoreMatch(
        [
          { value: v.word, weight: 3 },
          { value: v.englishMeaning, weight: 2 },
          { value: v.frenchMeaning, weight: 2 },
          { value: v.exampleSentence, weight: 1 },
        ],
        cleanedPrompt,
        keywords,
      ),
      12,
    );

    const textsPool = terms.length
      ? await this.prisma.knowledgeText.findMany({
          where: {
            languageId,
            OR: termsAll.flatMap((term) => [
              { text: { contains: term, mode: insensitive } },
              { translation: { contains: term, mode: insensitive } },
            ]),
          },
          take: 100,
        })
      : [];

    const { ranked: texts, topScore: textsTopScore } = this.rankAndTake(
      textsPool,
      (t) => this.scoreMatch(
        [{ value: t.text, weight: 2 }, { value: t.translation, weight: 2 }],
        cleanedPrompt,
        keywords,
      ),
      8,
    );

    const versesPool = terms.length
      ? await this.prisma.bibleVerse.findMany({
          where: {
            languageId,
            OR: termsAll.flatMap((term) => [
              { text: { contains: term, mode: insensitive } },
              { englishText: { contains: term, mode: insensitive } },
              { frenchText: { contains: term, mode: insensitive } },
            ]),
          },
          take: 100,
        })
      : [];

    const { ranked: verses, topScore: versesTopScore } = this.rankAndTake(
      versesPool,
      (v) => this.scoreMatch(
        [
          { value: v.text, weight: 2 },
          { value: v.englishText, weight: 1 },
          { value: v.frenchText, weight: 1 },
        ],
        cleanedPrompt,
        keywords,
      ),
      8,
    );

    const lessonsPool = keywords.length
      ? await this.prisma.lesson.findMany({
          where: {
            module: languageId ? { course: { languageId } } : undefined,
            OR: keywordsAll.flatMap((keyword) => [
              { title: { contains: keyword, mode: insensitive } },
              { summary: { contains: keyword, mode: insensitive } },
              { content: { contains: keyword, mode: insensitive } },
              // Without these, a French-phrased question's keywords never
              // appear in the English/Ewondo title/summary/content, so
              // lessons silently never matched for French speakers — they'd
              // get grounded answers in English but not in French for the
              // exact same underlying lesson.
              { frenchTitle: { contains: keyword, mode: insensitive } },
              { frenchSummary: { contains: keyword, mode: insensitive } },
              { frenchContent: { contains: keyword, mode: insensitive } },
            ]),
          },
          take: 100,
          include: {
            module: { include: { course: { include: { language: true } } } },
          },
        })
      : [];

    // Draft lessons whose body is only a placeholder (a single run of letters
    // typed while the draft was being created) must never be handed to the
    // model as lesson content: it would describe the lesson anyway and invent
    // words to fill the gap. They are listed separately as "no content yet".
    const realLessonsPool = lessonsPool.filter((l) => hasRealText(l.content) || hasRealText(l.frenchContent));
    const emptyLessonsPool = lessonsPool.filter((l) => !(hasRealText(l.content) || hasRealText(l.frenchContent)));
    const { ranked: emptyLessons, topScore: emptyLessonsTopScore } = this.rankAndTake(
      emptyLessonsPool,
      (l) => this.scoreMatch(
        [
          { value: l.title, weight: 3 },
          { value: l.frenchTitle, weight: 3 },
        ],
        cleanedPrompt,
        keywords,
      ),
      3,
    );

    const { ranked: lessons, topScore: lessonsTopScore } = this.rankAndTake(
      realLessonsPool,
      (l) => this.scoreMatch(
        [
          { value: l.title, weight: 3 },
          { value: l.summary, weight: 2 },
          { value: l.content, weight: 1 },
          { value: l.frenchTitle, weight: 3 },
          { value: l.frenchSummary, weight: 2 },
          { value: l.frenchContent, weight: 1 },
        ],
        cleanedPrompt,
        keywords,
      ),
      8,
    );

    // Question TEXT only — never choices/isCorrect. That's the same
    // security boundary QuizAttempt scoring already enforces (the answer
    // key is never sent to the client); grounding Nnanga in quiz questions
    // just lets it discuss/explain what a quiz covers, not grade it.
    const quizzesPool = keywords.length
      ? await this.prisma.quiz.findMany({
          where: {
            lesson: {
              module: languageId ? { course: { languageId } } : undefined,
            },
            OR: keywordsAll.flatMap((keyword) => [
              { title: { contains: keyword, mode: insensitive } },
              { description: { contains: keyword, mode: insensitive } },
              { frenchTitle: { contains: keyword, mode: insensitive } },
              { frenchDescription: { contains: keyword, mode: insensitive } },
              {
                questions: {
                  some: {
                    OR: [
                      { questionText: { contains: keyword, mode: insensitive } },
                      { frenchQuestionText: { contains: keyword, mode: insensitive } },
                    ],
                  },
                },
              },
            ]),
          },
          take: 50,
          include: {
            lesson: { select: { title: true, frenchTitle: true } },
            questions: { select: { questionText: true, frenchQuestionText: true } },
          },
        })
      : [];

    const { ranked: quizzes, topScore: quizzesTopScore } = this.rankAndTake(
      quizzesPool,
      (q) => this.scoreMatch(
        [
          { value: q.title, weight: 2 },
          { value: q.description, weight: 1 },
          { value: q.frenchTitle, weight: 2 },
          { value: q.frenchDescription, weight: 1 },
          ...q.questions.flatMap((question) => [
            { value: question.questionText, weight: 2 },
            { value: question.frenchQuestionText, weight: 2 },
          ]),
        ],
        cleanedPrompt,
        keywords,
      ),
      5,
    );

    const coursesPool = keywords.length
      ? await this.prisma.course.findMany({
          where: {
            languageId,
            OR: keywordsAll.flatMap((keyword) => [
              { title: { contains: keyword, mode: insensitive } },
              { description: { contains: keyword, mode: insensitive } },
              { frenchTitle: { contains: keyword, mode: insensitive } },
              { frenchDescription: { contains: keyword, mode: insensitive } },
            ]),
          },
          take: 30,
          include: { language: true },
        })
      : [];

    const { ranked: courses } = this.rankAndTake(
      coursesPool,
      (c) => this.scoreMatch(
        [
          { value: c.title, weight: 2 },
          { value: c.description, weight: 1 },
          { value: c.frenchTitle, weight: 2 },
          { value: c.frenchDescription, weight: 1 },
        ],
        cleanedPrompt,
        keywords,
      ),
      3,
    );

    const booksPool = terms.length
      ? await this.prisma.book.findMany({
          where: {
            languageId,
            OR: [
              ...termsAll.flatMap((term) => [
                { title: { contains: term, mode: insensitive } },
                { author: { contains: term, mode: insensitive } },
                { description: { contains: term, mode: insensitive } },
              ]),
              ...keywordsAll.map((keyword) => ({
                content: { contains: keyword, mode: insensitive },
              })),
            ],
          },
          take: 30,
        })
      : [];

    const { ranked: books, topScore: booksTopScore } = this.rankAndTake(
      booksPool,
      (b) => this.scoreMatch(
        [
          { value: b.title, weight: 3 },
          { value: b.author, weight: 1 },
          { value: b.description, weight: 2 },
          // A content hit is real signal (the book actually discusses this),
          // but weighted low relative to title/description so one incidental
          // word inside a huge book doesn't outrank a title match.
          { value: b.content, weight: 1 },
        ],
        cleanedPrompt,
        keywords,
      ),
      3,
    );

    const booksWithExcerpts = books.map((book) => ({
      ...book,
      excerpts: book.content ? this.extractExcerpts(book.content, keywordsAll) : [],
    }));

    // ---- Syllabary (literacy chart): consonant + vowel = syllable, with an
    // example word and sentence. Asked about by letter ("the letter H"), by
    // syllable ("ba") or via an example word/translation.
    const syllabaryAsked = detectSyllabaryIntent(prompt);
    let syllabaryLetters: string[] = [];
    let syllabaryRequestedLetters: string[] = [];
    if (languageId && (syllabaryAsked || terms.length > 0)) {
      const letterRows = await this.prisma.syllabaryEntry.findMany({
        where: { languageId },
        distinct: ['consonant', 'vowel'],
        select: { consonant: true, vowel: true },
      });
      const letterSet = new Set<string>();
      for (const r of letterRows) letterSet.add(r.consonant ?? r.vowel);
      syllabaryLetters = [...letterSet].sort((a, b) => a.localeCompare(b));
      // A bare one-to-three character token only counts as a letter request
      // when the question is clearly about the alphabet/syllabary.
      if (syllabaryAsked) {
        syllabaryRequestedLetters = extractLetterCandidates(prompt, syllabaryLetters);
      }
    }

    const syllabaryPool = languageId && (syllabaryRequestedLetters.length > 0 || terms.length > 0)
      ? await this.prisma.syllabaryEntry.findMany({
          where: {
            languageId,
            OR: [
              ...syllabaryRequestedLetters.flatMap((letter) => [
                { consonant: { equals: letter, mode: insensitive } },
                { consonant: null, vowel: { equals: letter, mode: insensitive } },
              ]),
              ...termsAll
                .filter((term) => term.length > 2)
                .flatMap((term) => [
                  { syllable: { contains: term, mode: insensitive } },
                  { exampleWord: { contains: term, mode: insensitive } },
                  { englishTranslation: { contains: term, mode: insensitive } },
                  { frenchTranslation: { contains: term, mode: insensitive } },
                  { exampleSentence: { contains: term, mode: insensitive } },
                ]),
            ],
          },
          orderBy: [{ consonant: 'asc' }, { orderNumber: 'asc' }],
          take: 80,
        })
      : [];

    const requestedLower = new Set(syllabaryRequestedLetters.map((l) => l.toLowerCase()));
    const { ranked: syllabary, topScore: syllabaryTopScoreRaw } = this.rankAndTake(
      syllabaryPool,
      (s) => {
        const letterHit = requestedLower.has((s.consonant ?? s.vowel).toLowerCase()) ? 10 : 0;
        return letterHit + this.scoreMatch(
          [
            { value: s.syllable, weight: 3 },
            { value: s.exampleWord, weight: 3 },
            { value: s.englishTranslation, weight: 2 },
            { value: s.frenchTranslation, weight: 2 },
            { value: s.exampleSentence, weight: 1 },
          ],
          cleanedPrompt,
          keywords,
        );
      },
      requestedLower.size > 0 ? 24 : 8,
    );
    // Keep a requested letter's rows in the chart's own vowel order.
    if (requestedLower.size > 0) {
      syllabary.sort((a, b) => {
        const ka = (a.consonant ?? a.vowel).toLowerCase();
        const kb = (b.consonant ?? b.vowel).toLowerCase();
        return ka === kb ? a.orderNumber - b.orderNumber : ka.localeCompare(kb);
      });
    }

    // ---- Authored (illustrated) book pages: the Ewondo/English/French text of
    // each page is stored per page, not in Book.content.
    const bookPagesPool = languageId && terms.length > 0
      ? await this.prisma.bookPage.findMany({
          where: {
            book: { languageId },
            OR: termsAll.flatMap((term) => [
              { ewondoText: { contains: term, mode: insensitive } },
              { englishText: { contains: term, mode: insensitive } },
              { frenchText: { contains: term, mode: insensitive } },
            ]),
          },
          take: 40,
          include: { book: { select: { title: true } } },
        })
      : [];

    const { ranked: bookPages, topScore: bookPagesTopScore } = this.rankAndTake(
      bookPagesPool,
      (p) => this.scoreMatch(
        [
          { value: p.ewondoText, weight: 2 },
          { value: p.englishText, weight: 1 },
          { value: p.frenchText, weight: 1 },
        ],
        cleanedPrompt,
        keywords,
      ),
      4,
    );

    // ---- Lesson image gallery: each image carries the word it illustrates.
    const lessonImagesPool = languageId && terms.length > 0
      ? await this.prisma.lessonImage.findMany({
          where: {
            lesson: { module: { course: { languageId } } },
            OR: termsAll.flatMap((term) => [
              { word: { contains: term, mode: insensitive } },
              { caption: { contains: term, mode: insensitive } },
            ]),
          },
          take: 40,
          include: { lesson: { select: { title: true } } },
        })
      : [];

    const { ranked: lessonImages, topScore: lessonImagesTopScore } = this.rankAndTake(
      lessonImagesPool,
      (i) => this.scoreMatch(
        [{ value: i.word, weight: 3 }, { value: i.caption, weight: 1 }],
        cleanedPrompt,
        keywords,
      ),
      6,
    );

    // The whole real vocabulary is small enough to hand to the model in
    // full every time (a few hundred words at most, one line each) — this
    // is what makes vocabulary un-inventable: instead of hoping fuzzy
    // keyword search happens to surface the right word, the AI can always
    // see the complete, exhaustive list and simply won't find a word that
    // isn't there, rather than confidently fabricating one.
    const fullVocabulary = languageId
      ? await this.prisma.vocabulary.findMany({
          where: { languageId },
          orderBy: { word: 'asc' },
          select: { word: true, englishMeaning: true, frenchMeaning: true },
          take: FULL_VOCABULARY_LIMIT,
        })
      : [];

    // True only when we can PROVE no real translation exists anywhere in
    // the platform's content. Deliberately checks only vocabulary/texts/a
    // resolved full-passage request — categories that are actual word- or
    // phrase-level translation pairs. Loosely-matched `verses` are excluded
    // on purpose: a Bible verse that happens to mention "love" thematically
    // (e.g. "God so loved the world...") is not a translation of "I love
    // you" and must not be treated as grounding — that gap is exactly what
    // let the model fall through to inventing a word the first time this
    // was tested. Same reasoning excludes lessons/courses/books.
    const isUngroundedTranslationRequest =
      this.detectsTranslationIntent(prompt) &&
      !biblePassage &&
      vocabulary.length === 0 &&
      texts.length === 0 &&
      // A syllabary example word, an illustrated word or an authored book page can
      // ground a translation too, but only on a real match (an exact word, a requested
      // letter, or the whole phrase) — a loose keyword hit must not switch the safeguard off.
      syllabaryTopScoreRaw < 8 &&
      lessonImagesTopScore < 8 &&
      bookPagesTopScore < 5;

    // When we're about to tell the model "don't translate, suggest
    // alternatives instead", the alternatives themselves must be real —
    // letting the model freely pick which words to mention invites it to
    // invent plausible-looking ones under the guise of a "suggestion"
    // rather than a "translation" (observed in testing). Pre-selecting
    // real rows here and handing them to the model verbatim removes that
    // loophole entirely: the model's only job becomes writing prose around
    // words it did not choose and cannot alter.
    let suggestedVocabulary: typeof fullVocabulary = [];
    if (isUngroundedTranslationRequest && fullVocabulary.length > 0) {
      const looselyRelated = fullVocabulary.filter((v) =>
        keywords.some(
          (k) =>
            v.englishMeaning?.toLowerCase().includes(k) ||
            v.frenchMeaning?.toLowerCase().includes(k),
        ),
      );
      const pool = looselyRelated.length > 0 ? looselyRelated : fullVocabulary;
      suggestedVocabulary = pool.slice(0, 3);
    }

    return {
      prompt,
      cleanedPrompt,
      keywords,
      biblePassage,
      vocabulary,
      texts,
      verses,
      lessons,
      emptyLessons,
      // Set when the question is about a lesson that exists but was never written,
      // so the tutor is told to say so instead of describing it from its title.
      emptyLessonAsked:
        emptyLessons.length > 0 && emptyLessonsTopScore >= 3 && emptyLessonsTopScore >= lessonsTopScore
          ? emptyLessons[0].title
          : null,
      quizzes,
      courses,
      books: booksWithExcerpts,
      bookPages,
      lessonImages,
      syllabary,
      syllabaryLetters,
      syllabaryAsked,
      syllabaryRequestedLetters,
      fullVocabulary,
      fullVocabularyTruncated: fullVocabulary.length >= FULL_VOCABULARY_LIMIT,
      isUngroundedTranslationRequest,
      suggestedVocabulary,
      hasResults:
        biblePassage != null ||
        vocabulary.length > 0 ||
        texts.length > 0 ||
        verses.length > 0 ||
        lessons.length > 0 ||
        emptyLessons.length > 0 ||
        quizzes.length > 0 ||
        courses.length > 0 ||
        books.length > 0 ||
        bookPages.length > 0 ||
        lessonImages.length > 0 ||
        syllabary.length > 0,
      // A "5" score means some row matched the full cleaned phrase, not just
      // a loose keyword — that's the bar for "confidently grounded".
      hasExactVocabularyMatch: vocabularyTopScore >= 5,
      // Highest relevance score across every content category (courses are
      // deliberately excluded — a course titled "Ewondo Beginner Course"
      // would otherwise match the keyword "ewondo" on virtually every
      // question). Used to decide whether the AI may speak confidently;
      // stripping the language's own name out of the keyword list above is
      // what actually stops incidental "Ewondo" mentions in lesson content
      // from falsely inflating this.
      maxScore: Math.max(
        vocabularyTopScore,
        textsTopScore,
        versesTopScore,
        lessonsTopScore,
        quizzesTopScore,
        booksTopScore,
        syllabaryTopScoreRaw,
        bookPagesTopScore,
        lessonImagesTopScore,
        biblePassage ? 100 : 0,
      ),
    };
  }

  buildTeachingContext(
    results: Awaited<ReturnType<KnowledgeService['search']>>,
    languageName = 'the target language',
  ) {
    let context = `OFFICIAL NDAMINKOABA LOCAL KNOWLEDGE\n\n`;

    context += `Original learner question: ${results.prompt}\n`;
    context += `Cleaned question: ${results.cleanedPrompt}\n`;
    context += `Search keywords: ${results.keywords.join(', ') || 'none'}\n\n`;

    if (results.biblePassage) {
      const { book, chapter, verseStart, verseEnd, verses } = results.biblePassage;
      const range = verseStart
        ? `:${verseStart}${verseEnd && verseEnd !== verseStart ? `-${verseEnd}` : ''}`
        : '';

      context += `FULL BIBLE PASSAGE REQUESTED — ${book} ${chapter}${range} (reproduce every verse below verbatim, in order; do not summarize, shorten, or skip verses):\n`;

      for (const verse of verses) {
        context += `
v${verse.verse} — ${languageName}: ${verse.text}
  English: ${verse.englishText ?? 'Not provided'}
  French: ${verse.frenchText ?? 'Not provided'}
`;
      }
      context += '\n';
    }

    if (results.vocabulary.length > 0) {
      context += `VOCABULARY FOUND (closely matches this question):\n`;

      for (const word of results.vocabulary) {
        context += `
- ${languageName} word: ${word.word}
  English meaning: ${word.englishMeaning ?? 'Not provided'}
  French meaning: ${word.frenchMeaning ?? 'Not provided'}
  Part of speech: ${word.partOfSpeech ?? 'Not provided'}
  Example sentence: ${word.exampleSentence ?? 'Not provided'}
  Difficulty: ${word.difficulty}
`;
      }
      context += '\n';
    }

    if (results.fullVocabulary.length > 0) {
      context += results.fullVocabularyTruncated
        ? `VOCABULARY LIST — the first ${results.fullVocabulary.length} ${languageName} words in NdaMinkoaba in alphabetical order (the list is long, so words further down may be missing here; rely on VOCABULARY FOUND for those) (word = English / French):\n`
        : `FULL VOCABULARY LIST — every single ${languageName} word currently in NdaMinkoaba, complete and exhaustive (word = English / French):\n`;
      for (const word of results.fullVocabulary) {
        context += `${word.word} = ${word.englishMeaning ?? '?'} / ${word.frenchMeaning ?? '?'}\n`;
      }
      context += `(If the word or phrase the learner needs is not in this list and not quoted anywhere else in this context, it simply is not in the platform yet — see the CRITICAL ACCURACY RULE.)\n\n`;
    }

    if (results.texts.length > 0) {
      context += `\nTEXTS FOUND:\n`;

      for (const item of results.texts) {
        context += `
- ${languageName} text: ${item.text}
  Translation: ${item.translation ?? 'Not provided'}
`;
      }
    }

    if (results.syllabary.length > 0 || results.syllabaryAsked) {
      context += `\nSYLLABARY (the literacy chart \u2014 consonant + vowel = syllable, each with an example word):\n`;
      if (results.syllabaryLetters.length > 0) {
        context += `Letters available in the ${languageName} syllabary: ${results.syllabaryLetters.join(', ')}\n`;
      }
      if (results.syllabaryAsked && results.syllabaryRequestedLetters.length === 0) {
        context += `(The learner did not name a specific letter, or it is not in the chart: describe what the syllabary is and list the letters above; do not invent letters.)\n`;
      }
      for (const row of results.syllabary) {
        const letter = row.consonant ?? row.vowel;
        const extras = [
          row.exampleWord ? `example word: ${row.exampleWord}` : null,
          row.englishTranslation ? `English: ${row.englishTranslation}` : null,
          row.frenchTranslation ? `French: ${row.frenchTranslation}` : null,
          row.exampleSentence ? `example sentence: ${row.exampleSentence}` : null,
        ]
          .filter(Boolean)
          .join('; ');
        context += `- Letter ${letter}: syllable ${row.syllable}${extras ? ` \u2014 ${extras}` : ''}\n`;
      }
    }

    if (results.verses.length > 0) {
      context += `\nBIBLE VERSES FOUND (loosely related, not a full-chapter request):\n`;

      for (const verse of results.verses) {
        context += `
- Reference: ${verse.book} ${verse.chapter}:${verse.verse} (${verse.version})
  ${languageName}: ${verse.text}
  English: ${verse.englishText ?? 'Not provided'}
  French: ${verse.frenchText ?? 'Not provided'}
`;
      }
    }

    if (results.lessons.length > 0) {
      context += `\nRELATED LESSONS:\n`;

      for (const lesson of results.lessons) {
        context += `
- Lesson title: ${lesson.title}${lesson.frenchTitle ? ` (French: ${lesson.frenchTitle})` : ''}
  Summary: ${lesson.summary ?? 'Not provided'}
  Content: ${lesson.content}`;

        if (lesson.frenchContent) {
          context += `\n  French summary: ${lesson.frenchSummary ?? 'Not provided'}\n  French content: ${lesson.frenchContent}`;
        }
        context += '\n';
      }
    }

    if (results.emptyLessons.length > 0) {
      context += `\nLESSONS THAT EXIST BUT HAVE NO CONTENT YET (the author has not written them; say so plainly and do NOT describe or guess what they teach):\n`;
      for (const lesson of results.emptyLessons) {
        context += `- ${lesson.title}${lesson.frenchTitle ? ` (French: ${lesson.frenchTitle})` : ''}\n`;
      }
    }

    if (results.lessonImages.length > 0) {
      context += `\nILLUSTRATED WORDS (from lesson image galleries):\n`;
      for (const image of results.lessonImages) {
        context += `- ${image.word}${image.caption ? ` \u2014 ${image.caption}` : ''} (lesson: ${image.lesson.title})\n`;
      }
    }

    if (results.quizzes.length > 0) {
      context += `\nQUIZ QUESTIONS FOUND (question text only — never reveal or guess which choice is correct; if asked, tell the learner to take the quiz in the app to find out):\n`;

      for (const quiz of results.quizzes) {
        context += `
- Quiz: ${quiz.title}${quiz.frenchTitle ? ` (French: ${quiz.frenchTitle})` : ''} — from lesson "${quiz.lesson.title}"
`;
        for (const question of quiz.questions) {
          context += `  Q: ${question.questionText}${question.frenchQuestionText ? ` (French: ${question.frenchQuestionText})` : ''}\n`;
        }
      }
    }

    if (results.books.length > 0) {
      context += `\nBOOKS FOUND:\n`;

      for (const book of results.books) {
        context += `
- Book title: ${book.title}${book.author ? ` by ${book.author}` : ''}
  Description: ${book.description ?? 'Not provided'}`;

        if (book.excerpts.length > 0) {
          context += `\n  Relevant excerpt(s):`;
          for (const excerpt of book.excerpts) {
            context += `\n    "${excerpt}"`;
          }
        } else if (!book.content) {
          context += `\n  (Full text not yet indexed for this book — you may only mention its title/description.)`;
        }
        context += '\n';
      }
    }

    if (results.bookPages.length > 0) {
      context += `\nILLUSTRATED BOOK PAGES FOUND (text of authored book pages):\n`;
      for (const page of results.bookPages) {
        context += `- Book "${page.book.title}", page ${page.orderNumber}\n  ${languageName}: ${clip(page.ewondoText)}`;
        if (page.englishText) context += `\n  English: ${clip(page.englishText)}`;
        if (page.frenchText) context += `\n  French: ${clip(page.frenchText)}`;
        context += '\n';
      }
    }

    if (results.courses.length > 0) {
      context += `\nRELATED COURSES:\n`;

      for (const course of results.courses) {
        context += `
- Course title: ${course.title}${course.frenchTitle ? ` (French: ${course.frenchTitle})` : ''}
  Description: ${course.description ?? 'Not provided'}${course.frenchDescription ? `\n  French description: ${course.frenchDescription}` : ''}
  Level: ${course.level}
`;
      }
    }

    if (!results.hasResults) {
      context += `No reliable local content was found for this question.`;
    }

    context += `

CRITICAL ACCURACY RULE (absolute, overrides everything else):
- You may ONLY state a specific ${languageName} word, phrase, or sentence if it appears verbatim, exact spelling, somewhere above (FULL VOCABULARY LIST, VOCABULARY FOUND, TEXTS FOUND, a BIBLE VERSE/PASSAGE, a SYLLABARY row, an ILLUSTRATED WORD, an ILLUSTRATED BOOK PAGE, or a book excerpt).
- If the learner asks you to translate something, or asks "how do you say X in ${languageName}", and that word/phrase does NOT appear above (check the FULL VOCABULARY LIST — it is exhaustive), say plainly that it is not yet in NdaMinkoaba's content. Do NOT guess, reconstruct, or invent a plausible-looking ${languageName} word — even one that "seems right" from patterns you know. A wrong invented word actively misteaches the learner, which is worse than admitting you don't have it yet.
- You may still freely explain grammar patterns, pronunciation rules, culture, history, and general language-learning advice from your own knowledge — the restriction is only on stating specific ${languageName} vocabulary/phrases that aren't grounded in the context above.

TUTORING RULES:
- Treat everything above as the source of truth for NdaMinkoaba's own content. If a vocabulary item, verse, or lesson is found, never invent a different meaning or contradict it.
- If a FULL BIBLE PASSAGE section is present above, the learner asked for a specific chapter or verse range — reproduce it verbatim, verse by verse (${languageName} plus the language you are replying in), in the order given. Do not paraphrase, summarize, or invent Scripture text yourself.
- If nothing relevant was found above, say so plainly, then still help using your own general knowledge of ${languageName}/Bantu languages, French, English, the Bible, and language pedagogy — do not refuse to answer.
- Teach like a patient, encouraging language teacher. Keep answers focused and useful for the learner's level.
`;

    return context;
  }

  hasStrongLocalKnowledge(results: Awaited<ReturnType<KnowledgeService['search']>>) {
    // A score of 2+ means either a full-phrase match (worth 5), a resolved
    // Bible passage (worth 100), or at least two separate keyword hits — a
    // single incidental keyword (e.g. the word "lesson" appearing in the
    // question itself) shouldn't count as "answered from official content".
    return results.maxScore >= 2;
  }
}
