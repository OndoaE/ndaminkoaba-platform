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

type Row = [string, string];

@Injectable()
export class ChatbotKnowledgeService {
  constructor(private readonly prisma: PrismaService) {}

  /// Pulls the platform's real, current content -- not just marketing
  /// copy -- so a chatbot syncing this endpoint can answer questions
  /// about specific lessons, words, books, syllables, and Bible verses.
  /// Lessons are NOT filtered by workflow status: that field exists for
  /// the admin review pipeline but the learner app itself renders a
  /// lesson's content regardless of status (a disclosed, pre-existing
  /// gap), so filtering here would silently hide real, live content.
  private async getRealContent() {
    const [lessons, vocabulary, books, syllabary, bibleVerses] =
      await Promise.all([
        this.prisma.lesson.findMany({
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
        }),
        this.prisma.vocabulary.findMany({
          select: {
            word: true,
            frenchMeaning: true,
            englishMeaning: true,
            exampleSentence: true,
            exampleTranslation: true,
            difficulty: true,
            language: { select: { name: true } },
          },
        }),
        this.prisma.book.findMany({
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
        }),
        this.prisma.syllabaryEntry.findMany({
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
        }),
        this.prisma.bibleVerse.findMany({
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
        }),
      ]);

    return { lessons, vocabulary, books, syllabary, bibleVerses };
  }

  async getKnowledgeBase() {
    const content = await this.getRealContent();

    return {
      app: APP_OVERVIEW,
      platforms: PLATFORMS,
      features: FEATURES,
      faq: FAQ,
      content,
      counts: {
        lessons: content.lessons.length,
        vocabulary: content.vocabulary.length,
        books: content.books.length,
        syllabaryEntries: content.syllabary.length,
        bibleVerses: content.bibleVerses.length,
      },
      lastSyncedAt: new Date().toISOString(),
    };
  }

  /// Flattens everything -- marketing copy AND real app content -- into
  /// simple question,answer rows for chatbot tools that ingest a CSV
  /// knowledge source instead of JSON. One row per lesson, vocabulary
  /// word, book, syllabary entry, and Bible verse, so the chatbot can
  /// answer specific content questions, not just "what is this app".
  async getKnowledgeBaseAsCsv(): Promise<string> {
    const content = await this.getRealContent();
    const rows: Row[] = [];

    rows.push(['What is NdaMinkoaba?', APP_OVERVIEW.description]);
    rows.push(["What is NdaMinkoaba's mission?", APP_OVERVIEW.mission]);
    for (const f of FEATURES) {
      rows.push([`What is the "${f.name}" feature?`, f.description]);
    }
    for (const f of FAQ) rows.push([f.question, f.answer]);

    for (const l of content.lessons) {
      const course = l.module.course;
      const q = `What does the lesson "${l.title}" (${course.title}, ` +
        `${course.level}) teach?`;
      const parts = [l.summary, l.content, l.frenchContent].filter(
        (p): p is string => !!p && p.trim().length > 0,
      );
      rows.push([q, parts.join('\n\n')]);
    }

    for (const v of content.vocabulary) {
      const meanings = [v.englishMeaning, v.frenchMeaning]
        .filter((m): m is string => !!m)
        .join(' / ');
      const example = [v.exampleSentence, v.exampleTranslation]
        .filter((e): e is string => !!e)
        .join(' — ');
      const answer = [meanings, example && `Example: ${example}`]
        .filter(Boolean)
        .join('. ');
      rows.push([
        `What does "${v.word}" mean in ${v.language.name}?`,
        answer || meanings,
      ]);
    }

    for (const b of content.books) {
      const pageText = b.pages
        .map((p) => [p.ewondoText, p.frenchText].filter(Boolean).join(' — '))
        .join('\n');
      const answer = [b.description, b.content, pageText]
        .filter((p): p is string => !!p && p.trim().length > 0)
        .join('\n\n');
      rows.push([`What is the book "${b.title}" about?`, answer || (b.description ?? '')]);
    }

    for (const s of content.syllabary) {
      const letter = s.consonant ?? s.vowel;
      const answer = [
        `The syllable is "${s.syllable}".`,
        s.exampleWord && `Example word: ${s.exampleWord}${s.translation ? ` (${s.translation})` : ''}.`,
        s.exampleSentence && `Example sentence: ${s.exampleSentence}`,
      ]
        .filter(Boolean)
        .join(' ');
      rows.push([
        `How do you combine "${letter}" and "${s.vowel}" in ${s.language.name}?`,
        answer,
      ]);
    }

    for (const v of content.bibleVerses) {
      const answer = [v.text, v.frenchText, v.englishText]
        .filter((t): t is string => !!t)
        .join(' / ');
      rows.push([`What does ${v.book} ${v.chapter}:${v.verse} say?`, answer]);
    }

    const escape = (s: string) => `"${s.replace(/"/g, '""')}"`;
    const header = 'question,answer';
    const body = rows.map(([q, a]) => `${escape(q)},${escape(a)}`).join('\n');
    return `${header}\n${body}`;
  }
}
