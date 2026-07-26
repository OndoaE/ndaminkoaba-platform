/**
 * Seed script for local development / demo purposes.
 *
 * Run with:
 *   npx ts-node prisma/seed.ts
 * or (after `npx prisma generate`):
 *   npx prisma db seed
 *
 * Creates a demo admin, teacher and learner account, an Ewondo language,
 * and one published course per level (Beginner / Intermediate / Advanced),
 * each with a module, lesson, vocabulary and quiz, so the app isn't empty
 * on first run and the level filter has real data to show.
 *
 * Demo logins (all use the same password below):
 *   admin@ndaminkoaba.com    / Passw0rd!
 *   teacher@ndaminkoaba.com  / Passw0rd!
 *   learner@ndaminkoaba.com  / Passw0rd!
 */
import { PrismaClient, UserRole, Level, CourseStatus } from '@prisma/client';
import * as bcrypt from 'bcrypt';

const prisma = new PrismaClient();

const DEMO_PASSWORD = 'Passw0rd!';

async function upsertUser(email: string, fullName: string, role: UserRole) {
  const passwordHash = await bcrypt.hash(DEMO_PASSWORD, 10);

  return prisma.user.upsert({
    where: { email },
    update: {},
    create: { email, fullName, passwordHash, role },
  });
}

interface CourseSeed {
  level: Level;
  title: string;
  description: string;
  estimatedHours: number;
  moduleTitle: string;
  moduleDescription: string;
  lessonTitle: string;
  lessonSummary: string;
  lessonContent: string;
  vocabWord: string;
  vocabFrench: string;
  vocabEnglish: string;
  vocabExample: string;
  categoryName: string;
  quizTitle: string;
  questionText: string;
  correctChoice: string;
  wrongChoices: string[];
}

const COURSES: CourseSeed[] = [
  {
    level: Level.BEGINNER,
    title: 'Ewondo for Beginners',
    description:
      'Start speaking Ewondo with everyday greetings, numbers and family vocabulary.',
    estimatedHours: 6,
    moduleTitle: 'Greetings & Introductions',
    moduleDescription: 'Learn how to greet people and introduce yourself in Ewondo.',
    lessonTitle: 'Saying Hello',
    lessonSummary: 'Basic greetings used every day.',
    lessonContent:
      '**Mbolo** means "hello". Use it any time of day to greet one or more people.',
    vocabWord: 'Mbolo',
    vocabFrench: 'Bonjour',
    vocabEnglish: 'Hello',
    vocabExample: 'Mbolo, wa nga zu na?',
    categoryName: 'Greetings',
    quizTitle: 'Greetings Quiz',
    questionText: 'What does "Mbolo" mean?',
    correctChoice: 'Hello',
    wrongChoices: ['Goodbye', 'Thank you', 'Please'],
  },
  {
    level: Level.INTERMEDIATE,
    title: 'Everyday Ewondo Conversations',
    description:
      'Build on the basics with conversational phrases, questions and daily-life vocabulary.',
    estimatedHours: 8,
    moduleTitle: 'Asking & Answering Questions',
    moduleDescription: 'Learn to ask simple questions and hold a short conversation.',
    lessonTitle: 'How Are You?',
    lessonSummary: 'Asking about someone\'s wellbeing and responding.',
    lessonContent:
      '**O ne mbeng?** means "How are you?". A common reply is **Ma ne mbeng**, "I am fine."',
    vocabWord: 'O ne mbeng?',
    vocabFrench: 'Comment vas-tu ?',
    vocabEnglish: 'How are you?',
    vocabExample: 'O ne mbeng? — Ma ne mbeng, akiba.',
    categoryName: 'Conversation',
    quizTitle: 'Conversation Quiz',
    questionText: 'What does "O ne mbeng?" mean?',
    correctChoice: 'How are you?',
    wrongChoices: ['What is your name?', 'Where are you going?', 'See you later'],
  },
  {
    level: Level.ADVANCED,
    title: 'Advanced Ewondo: Culture & Storytelling',
    description:
      'Deepen your fluency with proverbs, storytelling structures and cultural expressions.',
    estimatedHours: 10,
    moduleTitle: 'Proverbs & Idioms',
    moduleDescription: 'Understand and use traditional Ewondo proverbs correctly.',
    lessonTitle: 'A Classic Proverb',
    lessonSummary: 'Meaning and usage of a well-known Ewondo proverb.',
    lessonContent:
      '**Nkukuma a ne si abui a ne si** is a traditional Ewondo proverb about patience and wisdom passed down through generations.',
    vocabWord: 'Nkukuma',
    vocabFrench: 'Sagesse',
    vocabEnglish: 'Wisdom',
    vocabExample: 'Nkukuma a ne si abui a ne si.',
    categoryName: 'Culture',
    quizTitle: 'Culture Quiz',
    questionText: 'What does "Nkukuma" mean?',
    correctChoice: 'Wisdom',
    wrongChoices: ['Water', 'Mountain', 'Family'],
  },
];

async function main() {
  console.log('Seeding NdaMinkoaba demo data...');

  const [admin, teacher, learner] = await Promise.all([
    upsertUser('admin@ndaminkoaba.com', 'Admin Nkoaba', UserRole.ADMIN),
    upsertUser('teacher@ndaminkoaba.com', 'Teacher Nkoaba', UserRole.TEACHER),
    upsertUser('learner@ndaminkoaba.com', 'Etienne Learner', UserRole.LEARNER),
  ]);

  const ewondo = await prisma.language.upsert({
    where: { code: 'ewo' },
    update: {},
    create: {
      name: 'Ewondo',
      code: 'ewo',
      country: 'Cameroon',
      isActive: true,
    },
  });

  const createdCourses: { level: Level; title: string; id: string }[] = [];

  for (const seed of COURSES) {
    let course = await prisma.course.findFirst({
      where: { title: seed.title, languageId: ewondo.id },
    });

    if (!course) {
      course = await prisma.course.create({
        data: {
          title: seed.title,
          description: seed.description,
          level: seed.level,
          status: CourseStatus.PUBLISHED,
          estimatedHours: seed.estimatedHours,
          languageId: ewondo.id,
          teacherId: teacher.id,
        },
      });
    }

    let module_ = await prisma.courseModule.findFirst({
      where: { courseId: course.id, orderNumber: 1 },
    });

    if (!module_) {
      module_ = await prisma.courseModule.create({
        data: {
          title: seed.moduleTitle,
          description: seed.moduleDescription,
          orderNumber: 1,
          courseId: course.id,
        },
      });
    }

    let lesson = await prisma.lesson.findFirst({
      where: { moduleId: module_.id, orderNumber: 1 },
    });

    if (!lesson) {
      lesson = await prisma.lesson.create({
        data: {
          title: seed.lessonTitle,
          summary: seed.lessonSummary,
          content: seed.lessonContent,
          orderNumber: 1,
          moduleId: module_.id,
        },
      });
    }

    const category = await prisma.category.upsert({
      where: { name: seed.categoryName },
      update: {},
      create: { name: seed.categoryName },
    });

    const existingVocab = await prisma.vocabulary.findFirst({
      where: { lessonId: lesson.id, word: seed.vocabWord },
    });

    if (!existingVocab) {
      await prisma.vocabulary.create({
        data: {
          word: seed.vocabWord,
          frenchMeaning: seed.vocabFrench,
          englishMeaning: seed.vocabEnglish,
          partOfSpeech: 'phrase',
          exampleSentence: seed.vocabExample,
          difficulty: seed.level,
          lessonId: lesson.id,
          categoryId: category.id,
          languageId: ewondo.id,
        },
      });
    }

    let quiz = await prisma.quiz.findFirst({ where: { lessonId: lesson.id } });

    if (!quiz) {
      quiz = await prisma.quiz.create({
        data: {
          title: seed.quizTitle,
          description: `Check what you learned in ${seed.lessonTitle}.`,
          passingScore: 70,
          lessonId: lesson.id,
        },
      });

      const question = await prisma.question.create({
        data: {
          questionText: seed.questionText,
          explanation: `The correct answer is "${seed.correctChoice}".`,
          quizId: quiz.id,
        },
      });

      await prisma.choice.createMany({
        data: [
          { choiceText: seed.correctChoice, isCorrect: true, questionId: question.id },
          ...seed.wrongChoices.map((text) => ({
            choiceText: text,
            isCorrect: false,
            questionId: question.id,
          })),
        ],
      });
    }

    createdCourses.push({ level: course.level, title: course.title, id: course.id });
  }

  const beginnerCourse = createdCourses.find((c) => c.level === Level.BEGINNER)!;

  await prisma.enrollment.upsert({
    where: { userId_courseId: { userId: learner.id, courseId: beginnerCourse.id } },
    update: {},
    create: { userId: learner.id, courseId: beginnerCourse.id },
  });

  const BADGES: {
    code: string;
    name: string;
    frenchName: string;
    description: string;
    frenchDescription: string;
    criteriaType: 'STREAK_DAYS' | 'SESSIONS_COMPLETED' | 'LESSONS_COMPLETED' | 'QUIZZES_PASSED' | 'VOCAB_MASTERED' | 'PRONUNCIATION_SESSIONS';
    criteriaValue: number;
  }[] = [
    {
      code: 'FIRST_STEPS',
      name: 'First Steps',
      frenchName: 'Premiers Pas',
      description: 'Complete your first practice session.',
      frenchDescription: 'Terminez votre première session de pratique.',
      criteriaType: 'SESSIONS_COMPLETED',
      criteriaValue: 1,
    },
    {
      code: 'CONSISTENT_LEARNER',
      name: 'Consistent Learner',
      frenchName: 'Apprenant Assidu',
      description: 'Reach a 7-day practice streak.',
      frenchDescription: 'Atteignez une série de 7 jours de pratique.',
      criteriaType: 'STREAK_DAYS',
      criteriaValue: 7,
    },
    {
      code: 'DEDICATED_LEARNER',
      name: 'Dedicated Learner',
      frenchName: 'Apprenant Dévoué',
      description: 'Reach a 30-day practice streak.',
      frenchDescription: 'Atteignez une série de 30 jours de pratique.',
      criteriaType: 'STREAK_DAYS',
      criteriaValue: 30,
    },
    {
      code: 'LESSON_MILESTONE_10',
      name: 'Ten Lessons In',
      frenchName: 'Dix Leçons Faites',
      description: 'Complete 10 lessons.',
      frenchDescription: 'Terminez 10 leçons.',
      criteriaType: 'LESSONS_COMPLETED',
      criteriaValue: 10,
    },
    {
      code: 'QUIZ_ACE',
      name: 'Quiz Ace',
      frenchName: 'As du Quiz',
      description: 'Pass 5 quizzes.',
      frenchDescription: 'Réussissez 5 quiz.',
      criteriaType: 'QUIZZES_PASSED',
      criteriaValue: 5,
    },
    {
      code: 'WORD_MASTER',
      name: 'Word Master',
      frenchName: 'Maître des Mots',
      description: 'Master 20 vocabulary words through Smart Review.',
      frenchDescription: 'Maîtrisez 20 mots de vocabulaire grâce à la révision intelligente.',
      criteriaType: 'VOCAB_MASTERED',
      criteriaValue: 20,
    },
    {
      code: 'CONFIDENT_SPEAKER',
      name: 'Confident Speaker',
      frenchName: 'Orateur Confiant',
      description: 'Complete 10 pronunciation practice sessions.',
      frenchDescription: 'Terminez 10 sessions de pratique de prononciation.',
      criteriaType: 'PRONUNCIATION_SESSIONS',
      criteriaValue: 10,
    },
  ];

  for (const badge of BADGES) {
    await prisma.badge.upsert({
      where: { code: badge.code },
      update: {
        name: badge.name,
        frenchName: badge.frenchName,
        description: badge.description,
        frenchDescription: badge.frenchDescription,
        criteriaType: badge.criteriaType,
        criteriaValue: badge.criteriaValue,
      },
      create: badge,
    });
  }

  console.log('Seed complete:', {
    users: [admin.email, teacher.email, learner.email],
    courses: createdCourses.map((c) => `${c.title} (${c.level})`),
  });
}

main()
  .catch((error) => {
    console.error(error);
    process.exit(1);
  })
  .finally(async () => {
    await prisma.$disconnect();
  });
