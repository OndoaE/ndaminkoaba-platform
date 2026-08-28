import { Injectable } from '@nestjs/common';

import { PrismaService } from '../prisma/prisma.service';

/// Static, hand-written descriptive content about the platform itself
/// (distinct from the real app CONTENT pulled live below) -- overview,
/// platforms, features, FAQ. Editing this file and redeploying is the
/// update path for this part, same as any other static copy in the app.
const APP_OVERVIEW = {
  name: 'NdaMinkoaba',
  tagline: 'Learn • Preserve • Transmit',
  description:
    'NdaMinkoaba is a full-stack, multi-language e-learning platform for ' +
    "Cameroonian heritage languages, piloted with Ewondo as its first " +
    'fully populated language. It combines structured leveled courses, ' +
    'spaced-repetition vocabulary review, pronunciation practice, an AI ' +
    'conversation tutor grounded in curated content, gamification, and an ' +
    'illustrated book library, all built on a language-agnostic ' +
    'architecture that can extend to additional Cameroonian languages ' +
    'without being rebuilt.',
  mission:
    'Cameroon is home to a large number of indigenous languages, several ' +
    'of which are increasingly endangered as urbanisation and the ' +
    'dominance of French and English in formal education weaken ' +
    'intergenerational transmission. NdaMinkoaba treats a Cameroonian ' +
    'language with the same structural rigour and technological ' +
    'sophistication mainstream apps apply to major world languages.',
};

const PLATFORMS = {
  web: {
    status: 'available',
    url: 'https://ndaminkoaba-c31d8.web.app',
    notes: 'Works in any modern browser, on desktop, tablet, or phone.',
  },
  android: {
    status: 'available',
    notes:
      'A signed Android build is available for direct installation. ' +
      'Play Store listing is in progress.',
  },
  ios: {
    status: 'not yet available',
    notes: 'iOS support is planned but not yet built.',
  },
};

const FEATURES = [
  {
    name: 'Structured leveled courses',
    description:
      'Courses are organised Beginner, Intermediate, and Advanced, each ' +
      'broken into modules and lessons that build on one another.',
  },
  {
    name: 'Vocabulary review (spaced repetition)',
    description:
      'Uses the SM-2 spaced-repetition algorithm so words you are close ' +
      'to forgetting come back at the right time.',
  },
  {
    name: 'Pronunciation practice',
    description: 'Record yourself saying a word or phrase and get feedback.',
  },
  {
    name: 'Nnanga, the AI tutor',
    description:
      'A conversational AI tutor grounded in the ' +
      "platform's own curated content, with corrections, translations, " +
      'and suggested replies.',
  },
  {
    name: 'Gamification and certificates',
    description:
      'Daily streaks, badges, and automatically generated, level-themed, ' +
      'QR-verifiable PDF certificates on course completion.',
  },
  {
    name: 'Illustrated book library',
    description:
      'Readable books, both uploaded PDF/EPUB files and illustrated, ' +
      'page-by-page stories.',
  },
  {
    name: 'Syllabary / alphabet chart',
    description:
      'A browsable consonant-vowel syllable chart with example words, ' +
      'translations, and example sentences.',
  },
  {
    name: 'Ewondo Bible',
    description:
      'A searchable collection of Bible verses translated into Ewondo, ' +
      'alongside English/French text.',
  },
  {
    name: 'Offline mode',
    description:
      'Download a course for offline access to its lessons, vocabulary, ' +
      'and images.',
  },
  {
    name: 'Bilingual interface',
    description: 'The app is fully usable in both English and French.',
  },
];

const FAQ = [
  {
    question: 'What is NdaMinkoaba?',
    answer:
      'NdaMinkoaba is an app for learning Cameroonian heritage languages, ' +
      'currently piloted with Ewondo, combining structured lessons, an ' +
      'AI tutor, vocabulary practice, and gamification.',
  },
  {
    question: 'Is NdaMinkoaba free to use?',
    answer: 'Yes, the platform is currently free to use.',
  },
  {
    question: 'Do I need to create an account?',
    answer:
      'Yes, a quick sign-up (email/password or Google sign-in) is needed ' +
      'to track your progress, streaks, and certificates.',
  },
  {
    question: 'Can I use the app without internet access?',
    answer:
      'Yes. You can download a course for offline use. A few features ' +
      '(the AI tutor and scored quizzes) still need connectivity.',
  },
  {
    question: 'How do I get a certificate?',
    answer:
      'Certificates are issued automatically once you complete every ' +
      'lesson and pass every quiz in a course, as a downloadable, ' +
      'QR-verifiable PDF.',
  },
  {
    question: 'Where can I download the app?',
    answer:
      'Web: https://ndaminkoaba-c31d8.web.app (any browser). Android: a ' +
      'direct-install build is available, Play Store listing coming. ' +
      'iOS is not available yet.',
  },
];

export type Row = [string, string];

function toCsv(rows: Row[]): string {
  const escape = (s: string) => `"${s.replace(/"/g, '""')}"`;
  const header = 'question,answer';
  const body = rows.map(([q, a]) => `${escape(q)},${escape(a)}`).join('\n');
  return `${header}\n${body}`;
}

@Injectable()
export class ChatbotKnowledgeService {
  constructor(private readonly prisma: PrismaService) {}

  // ---------- Overview (static copy, always tiny) ----------

  getOverview() {
    return { app: APP_OVERVIEW, platforms: PLATFORMS, features: FEATURES, faq: FAQ };
  }

  getOverviewRows(): Row[] {
    const rows: Row[] = [];
    rows.push(['What is NdaMinkoaba?', APP_OVERVIEW.description]);
    rows.push(["What is NdaMinkoaba's mission?", APP_OVERVIEW.mission]);
    for (const f of FEATURES) {
      rows.push([`What is the "${f.name}" feature?`, f.description]);
    }
    for (const f of FAQ) rows.push([f.question, f.answer]);
    return rows;
  }

  // ---------- Lessons ----------
  // Deliberately NOT filtered by workflow status: that field exists for
  // the admin review pipeline, but the learner app renders a lesson's
  // content regardless of status (a disclosed, pre-existing gap) --
  // confirmed directly against production, where 0 of 87 lessons are
  // marked PUBLISHED despite all being visible to learners. Filtering
  // here would silently hide real, live content.

  async getLessons() {
    return this.prisma.lesson.findMany({
      select: {
        title: true,
        summary: true,
        content: true,
        frenchContent: true,
        orderNumber: true,
        module: {
          select: {
            title: true,
            course: {
              select: {
                title: true,
                level: true,
                language: { select: { name: true } },
              },
            },
          },
        },
      },
    });
  }

  async getLessonRows(): Promise<Row[]> {
    const lessons = await this.getLessons();
    return lessons.map((l) => {
      const course = l.module.course;
      const q = `What does the lesson "${l.title}" (${course.title}, ${course.level}) teach?`;
      const parts = [l.summary, l.content, l.frenchContent].filter(
        (p): p is string => !!p && p.trim().length > 0,
      );
      return [q, parts.join('\n\n')] as Row;
    });
  }

  // ---------- Vocabulary ----------

  async getVocabulary() {
    return this.prisma.vocabulary.findMany({
      select: {
        word: true,
        frenchMeaning: true,
        englishMeaning: true,
        exampleSentence: true,
        exampleTranslation: true,
        difficulty: true,
        language: { select: { name: true } },
      },
    });
  }

  async getVocabularyRows(): Promise<Row[]> {
    const vocabulary = await this.getVocabulary();
    return vocabulary.map((v) => {
      const meanings = [v.englishMeaning, v.frenchMeaning]
        .filter((m): m is string => !!m)
        .join(' / ');
      const example = [v.exampleSentence, v.exampleTranslation]
        .filter((e): e is string => !!e)
        .join(' — ');
      const answer = [meanings, example && `Example: ${example}`]
        .filter(Boolean)
        .join('. ');
      return [
        `What does "${v.word}" mean in ${v.language.name}?`,
        answer || meanings,
      ] as Row;
    });
  }

  // ---------- Books ----------

  async getBooks() {
    return this.prisma.book.findMany({
      select: {
        title: true,
        author: true,
        description: true,
        category: true,
        level: true,
        content: true,
        language: { select: { name: true } },
        pages: {
          select: { ewondoText: true, frenchText: true },
          orderBy: { orderNumber: 'asc' },
        },
      },
    });
  }

  async getBookRows(): Promise<Row[]> {
    const books = await this.getBooks();
    return books.map((b) => {
      const pageText = b.pages
        .map((p) => [p.ewondoText, p.frenchText].filter(Boolean).join(' — '))
        .join('\n');
      const answer = [b.description, b.content, pageText]
        .filter((p): p is string => !!p && p.trim().length > 0)
        .join('\n\n');
      return [`What is the book "${b.title}" about?`, answer || (b.description ?? '')] as Row;
    });
  }

  // ---------- Syllabary ----------

  async getSyllabary() {
    return this.prisma.syllabaryEntry.findMany({
      select: {
        consonant: true,
        vowel: true,
        syllable: true,
        exampleWord: true,
        translation: true,
        exampleSentence: true,
        language: { select: { name: true } },
      },
      orderBy: [{ consonant: 'asc' }, { orderNumber: 'asc' }],
    });
  }

  async getSyllabaryRows(): Promise<Row[]> {
    const syllabary = await this.getSyllabary();
    return syllabary.map((s) => {
      const letter = s.consonant ?? s.vowel;
      const answer = [
        `The syllable is "${s.syllable}".`,
        s.exampleWord &&
          `Example word: ${s.exampleWord}${s.translation ? ` (${s.translation})` : ''}.`,
        s.exampleSentence && `Example sentence: ${s.exampleSentence}`,
      ]
        .filter(Boolean)
        .join(' ');
      return [
        `How do you combine "${letter}" and "${s.vowel}" in ${s.language.name}?`,
        answer,
      ] as Row;
    });
  }

  // ---------- Bible ----------

  async getBibleVerses() {
    return this.prisma.bibleVerse.findMany({
      select: {
        book: true,
        chapter: true,
        verse: true,
        text: true,
        englishText: true,
        frenchText: true,
        language: { select: { name: true } },
      },
      orderBy: [{ book: 'asc' }, { chapter: 'asc' }, { verse: 'asc' }],
    });
  }

  async getBibleRows(): Promise<Row[]> {
    const verses = await this.getBibleVerses();
    return verses.map((v) => {
      const answer = [v.text, v.frenchText, v.englishText]
        .filter((t): t is string => !!t)
        .join(' / ');
      return [`What does ${v.book} ${v.chapter}:${v.verse} say?`, answer] as Row;
    });
  }

  // ---------- Combined (everything in one call -- may be too large for
  // some chatbot tools' sync-from-URL size limits; the per-section
  // methods above exist so a large source can be split into several
  // smaller ones instead) ----------

  async getKnowledgeBase() {
    const [lessons, vocabulary, books, syllabary, bibleVerses] = await Promise.all([
      this.getLessons(),
      this.getVocabulary(),
      this.getBooks(),
      this.getSyllabary(),
      this.getBibleVerses(),
    ]);
    const content = { lessons, vocabulary, books, syllabary, bibleVerses };

    return {
      ...this.getOverview(),
      content,
      counts: {
        lessons: lessons.length,
        vocabulary: vocabulary.length,
        books: books.length,
        syllabaryEntries: syllabary.length,
        bibleVerses: bibleVerses.length,
      },
      lastSyncedAt: new Date().toISOString(),
    };
  }

  async getKnowledgeBaseAsCsv(): Promise<string> {
    const [overview, lessons, vocabulary, books, syllabary, bible] = await Promise.all([
      this.getOverviewRows(),
      this.getLessonRows(),
      this.getVocabularyRows(),
      this.getBookRows(),
      this.getSyllabaryRows(),
      this.getBibleRows(),
    ]);
    return toCsv([...overview, ...lessons, ...vocabulary, ...books, ...syllabary, ...bible]);
  }

  // ---------- Per-section CSV builders (small, single-purpose files) ----------

  async getOverviewCsv(): Promise<string> {
    return toCsv(this.getOverviewRows());
  }

  async getLessonsCsv(): Promise<string> {
    return toCsv(await this.getLessonRows());
  }

  async getVocabularyCsv(): Promise<string> {
    return toCsv(await this.getVocabularyRows());
  }

  async getBooksCsv(): Promise<string> {
    return toCsv(await this.getBookRows());
  }

  async getSyllabaryCsv(): Promise<string> {
    return toCsv(await this.getSyllabaryRows());
  }

  async getBibleCsv(): Promise<string> {
    return toCsv(await this.getBibleRows());
  }
}
