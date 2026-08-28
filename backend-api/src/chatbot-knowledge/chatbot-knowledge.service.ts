import { Injectable } from '@nestjs/common';
import { CourseStatus } from '@prisma/client';

import { PrismaService } from '../prisma/prisma.service';

/// Static, hand-written descriptive content about the platform, kept
/// separate from the live counts pulled in getKnowledgeBase() below. This
/// is content a marketing/download site's chatbot widget can point its
/// "sync from URL" feature at -- re-fetching this endpoint is the entire
/// resync mechanism, so nothing here needs a database table or an admin
/// screen of its own; editing this file and redeploying is the update
/// path, exactly like any other static copy in the app.
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
    name: 'Rich lesson content',
    description:
      'Lessons combine text, example dialogues, audio, and images, with ' +
      'an embedded quiz to check understanding before moving on.',
  },
  {
    name: 'Vocabulary review (spaced repetition)',
    description:
      'A dedicated vocabulary review feature uses the SM-2 spaced-' +
      'repetition algorithm so words you are close to forgetting come ' +
      'back at the right time to keep them in long-term memory.',
  },
  {
    name: 'Pronunciation practice',
    description:
      'Learners record themselves saying a word or phrase and get ' +
      'feedback on their pronunciation.',
  },
  {
    name: 'Nnanga, the AI tutor',
    description:
      'A conversational AI tutor whose answers are grounded in the ' +
      "platform's own curated vocabulary and knowledge content rather " +
      'than an ungrounded general model, with corrections, translations, ' +
      'and suggested replies alongside the main response.',
  },
  {
    name: 'Gamification and certificates',
    description:
      'Daily learning streaks, badges for milestones, and automatically ' +
      'generated, level-themed, QR-verifiable PDF certificates on course ' +
      'completion (green/one star for Beginner, red/two stars for ' +
      'Intermediate, yellow/three stars for Advanced).',
  },
  {
    name: 'Illustrated book library',
    description:
      'A library of readable books, some as uploaded PDF/EPUB files and ' +
      'some authored as illustrated, page-by-page stories with Ewondo ' +
      'and French text side by side.',
  },
  {
    name: 'Syllabary / alphabet chart',
    description:
      'A browsable consonant-vowel syllable chart (the traditional ' +
      'literacy-teaching format) with example words, translations, and ' +
      'example sentences per syllable.',
  },
  {
    name: 'Offline mode',
    description:
      'A course can be downloaded for offline access to its lessons, ' +
      'vocabulary, and images when there is no connectivity.',
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
    question: 'What languages can I learn right now?',
    answer:
      'Ewondo has a complete course catalogue today. The platform is ' +
      'built to support additional Cameroonian languages over time.',
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
      'Yes. You can download a course for offline use, which makes its ' +
      'lessons, vocabulary, and images available without a connection. ' +
      'A few features (like the AI tutor and scored quizzes) still need ' +
      'connectivity.',
  },
  {
    question: 'What is Nnanga?',
    answer:
      "Nnanga is NdaMinkoaba's built-in AI conversation tutor. Its " +
      'answers are grounded in the app’s own curated Ewondo content, ' +
      'and it can correct, translate, and suggest replies as you chat.',
  },
  {
    question: 'How do I get a certificate?',
    answer:
      'Certificates are issued automatically once you complete every ' +
      'lesson and pass every quiz in a course. Each certificate is a ' +
      'downloadable PDF with a QR code that publicly verifies it.',
  },
  {
    question: 'Where can I download the app?',
    answer:
      'The web app works in any browser at ' +
      'https://ndaminkoaba-c31d8.web.app. An Android build is available ' +
      'for direct installation, with a Play Store listing on the way. ' +
      'iOS is not available yet.',
  },
  {
    question: 'How is NdaMinkoaba different from apps like Duolingo?',
    answer:
      'Mainstream language apps like Duolingo do not support Cameroonian ' +
      'languages. NdaMinkoaba was purpose-built for that gap, pairing a ' +
      'structured, gamified learning experience with an AI tutor and a ' +
      'book library specific to a heritage language.',
  },
];

@Injectable()
export class ChatbotKnowledgeService {
  constructor(private readonly prisma: PrismaService) {}

  async getKnowledgeBase() {
    const [languages, publishedCourses, totalLessons] = await Promise.all([
      this.prisma.language.findMany({
        where: { isActive: true },
        select: { name: true },
        orderBy: { name: 'asc' },
      }),
      this.prisma.course.count({ where: { status: CourseStatus.PUBLISHED } }),
      this.prisma.lesson.count(),
    ]);

    return {
      app: APP_OVERVIEW,
      platforms: PLATFORMS,
      features: FEATURES,
      faq: FAQ,
      liveStats: {
        activeLanguages: languages.length,
        languageNames: languages.map((l) => l.name),
        publishedCourses,
        totalLessons,
      },
      lastSyncedAt: new Date().toISOString(),
    };
  }

  /// Same content as getKnowledgeBase(), flattened into simple
  /// question,answer rows for chatbot tools that expect a CSV knowledge
  /// source instead of JSON.
  async getKnowledgeBaseAsCsv(): Promise<string> {
    const data = await this.getKnowledgeBase();
    const rows: [string, string][] = [
      ['What is NdaMinkoaba?', data.app.description],
      ['What is NdaMinkoaba’s mission?', data.app.mission],
      ...data.features.map(
        (f): [string, string] => [`What is "${f.name}"?`, f.description],
      ),
      ...data.faq.map((f): [string, string] => [f.question, f.answer]),
      [
        'How many languages are currently active?',
        String(data.liveStats.activeLanguages),
      ],
      [
        'Which languages are active?',
        data.liveStats.languageNames.join(', '),
      ],
      [
        'How many published courses are there?',
        String(data.liveStats.publishedCourses),
      ],
    ];

    const escape = (s: string) => `"${s.replace(/"/g, '""')}"`;
    const header = 'question,answer';
    const body = rows.map(([q, a]) => `${escape(q)},${escape(a)}`).join('\n');
    return `${header}\n${body}`;
  }
}
