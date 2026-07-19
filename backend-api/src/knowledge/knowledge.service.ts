import { Injectable } from '@nestjs/common';
import { Prisma } from '@prisma/client';
import { PrismaService } from '../prisma/prisma.service';

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

@Injectable()
export class KnowledgeService {
  constructor(private readonly prisma: PrismaService) {}

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
      .replace(/[?.,!]/g, ' ')
      .replace(/\s+/g, ' ')
      .trim();
  }

  private extractKeywords(prompt: string): string[] {
    return this.cleanPrompt(prompt)
      .toLowerCase()
      .split(' ')
      .filter((word) => word.length > 2)
      .filter(
        (word) =>
          ![
            // English
            'explain', 'teacher', 'like', 'what', 'does', 'mean', 'means',
            'please', 'tell', 'about', 'word', 'the', 'and', 'for', 'you',
            'how', 'can', 'are', 'this', 'that', 'with',
            // French
            'expliquer', 'professeur', 'comme', 'quoi', 'que', 'veut',
            'dire', 'signifie', 'sil', 'vous', 'plait', 'dis', 'moi',
            'sur', 'mot', 'les', 'des', 'une', 'pour', 'avec', 'comment',
            'peux', 'peut',
          ].includes(word),
      );
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
    const lowerPrompt = cleanedPrompt.toLowerCase();
    let score = 0;

    for (const { value, weight } of fields) {
      if (!value) continue;
      const lower = value.toLowerCase();

      if (lowerPrompt.length > 2 && lower.includes(lowerPrompt)) {
        score += 5 * weight;
      }
      for (const keyword of keywords) {
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

  async search(prompt: string, languageId?: string) {
    const cleanedPrompt = this.cleanPrompt(prompt);
    const keywords = this.extractKeywords(prompt);
    const insensitive = Prisma.QueryMode.insensitive;
    const terms = [cleanedPrompt, ...keywords].filter((t) => t.length > 2);

    const biblePassage = await this.findBiblePassage(prompt, languageId);

    const vocabularyPool = terms.length
      ? await this.prisma.vocabulary.findMany({
          where: {
            languageId,
            OR: terms.flatMap((term) => [
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
            OR: terms.flatMap((term) => [
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
            OR: terms.flatMap((term) => [
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
            OR: keywords.flatMap((keyword) => [
              { title: { contains: keyword, mode: insensitive } },
              { summary: { contains: keyword, mode: insensitive } },
              { content: { contains: keyword, mode: insensitive } },
            ]),
          },
          take: 100,
          include: {
            module: { include: { course: { include: { language: true } } } },
          },
        })
      : [];

    const { ranked: lessons, topScore: lessonsTopScore } = this.rankAndTake(
      lessonsPool,
      (l) => this.scoreMatch(
        [
          { value: l.title, weight: 3 },
          { value: l.summary, weight: 2 },
          { value: l.content, weight: 1 },
        ],
        cleanedPrompt,
        keywords,
      ),
      8,
    );

    const coursesPool = keywords.length
      ? await this.prisma.course.findMany({
          where: {
            languageId,
            OR: keywords.flatMap((keyword) => [
              { title: { contains: keyword, mode: insensitive } },
              { description: { contains: keyword, mode: insensitive } },
            ]),
          },
          take: 30,
          include: { language: true },
        })
      : [];

    const { ranked: courses } = this.rankAndTake(
      coursesPool,
      (c) => this.scoreMatch(
        [{ value: c.title, weight: 2 }, { value: c.description, weight: 1 }],
        cleanedPrompt,
        keywords,
      ),
      3,
    );

    return {
      prompt,
      cleanedPrompt,
      keywords,
      biblePassage,
      vocabulary,
      texts,
      verses,
      lessons,
      courses,
      hasResults:
        biblePassage != null ||
        vocabulary.length > 0 ||
        texts.length > 0 ||
        verses.length > 0 ||
        lessons.length > 0 ||
        courses.length > 0,
      // A "5" score means some row matched the full cleaned phrase, not just
      // a loose keyword — that's the bar for "confidently grounded".
      hasExactVocabularyMatch: vocabularyTopScore >= 5,
      // Highest relevance score across every category — used to decide
      // whether this question was genuinely answered from platform content
      // (a single incidental keyword hit, e.g. the word "lesson" appearing
      // in the question itself, shouldn't count as "grounded"). A resolved
      // Bible passage request is as confident a match as it gets.
      maxScore: Math.max(
        vocabularyTopScore,
        textsTopScore,
        versesTopScore,
        lessonsTopScore,
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
      context += `VOCABULARY FOUND:\n`;

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
- Lesson title: ${lesson.title}
  Summary: ${lesson.summary ?? 'Not provided'}
  Content: ${lesson.content}
`;
      }
    }

    if (results.courses.length > 0) {
      context += `\nRELATED COURSES:\n`;

      for (const course of results.courses) {
        context += `
- Course title: ${course.title}
  Description: ${course.description ?? 'Not provided'}
  Level: ${course.level}
`;
      }
    }

    if (!results.hasResults) {
      context += `No reliable local content was found for this question.`;
    }

    context += `

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
