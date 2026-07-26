-- CreateEnum
CREATE TYPE "public"."PracticeActivityType" AS ENUM ('LESSON', 'QUIZ', 'SMART_REVIEW', 'PRONUNCIATION', 'AI_CHAT');

-- CreateEnum
CREATE TYPE "public"."PronunciationAttemptStatus" AS ENUM ('PENDING', 'SCORED', 'FAILED');

-- CreateEnum
CREATE TYPE "public"."BadgeCriteriaType" AS ENUM ('STREAK_DAYS', 'SESSIONS_COMPLETED', 'LESSONS_COMPLETED', 'QUIZZES_PASSED', 'VOCAB_MASTERED', 'PRONUNCIATION_SESSIONS');

-- AlterTable
ALTER TABLE "public"."AIConversation" ADD COLUMN     "audioTranscript" TEXT,
ADD COLUMN     "audioUrl" TEXT,
ADD COLUMN     "correction" TEXT,
ADD COLUMN     "suggestedReplies" JSONB,
ADD COLUMN     "translation" TEXT,
ADD COLUMN     "usedLocalKnowledge" BOOLEAN NOT NULL DEFAULT false;

-- AlterTable
ALTER TABLE "public"."Lesson" ADD COLUMN     "conversationJson" JSONB;

-- AlterTable
ALTER TABLE "public"."User" ADD COLUMN     "currentStreak" INTEGER NOT NULL DEFAULT 0,
ADD COLUMN     "dailyGoalMinutes" INTEGER NOT NULL DEFAULT 10,
ADD COLUMN     "lastStreakDate" TIMESTAMP(3),
ADD COLUMN     "longestStreak" INTEGER NOT NULL DEFAULT 0;

-- AlterTable
ALTER TABLE "public"."Vocabulary" ADD COLUMN     "phoneticTranscription" TEXT;

-- CreateTable
CREATE TABLE "public"."PracticeSession" (
    "id" TEXT NOT NULL,
    "userId" TEXT NOT NULL,
    "activityType" "public"."PracticeActivityType" NOT NULL,
    "durationSec" INTEGER NOT NULL,
    "lessonId" TEXT,
    "courseId" TEXT,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "PracticeSession_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "public"."VocabularyProgress" (
    "id" TEXT NOT NULL,
    "userId" TEXT NOT NULL,
    "vocabularyId" TEXT NOT NULL,
    "easeFactor" DOUBLE PRECISION NOT NULL DEFAULT 2.5,
    "intervalDays" INTEGER NOT NULL DEFAULT 0,
    "repetitions" INTEGER NOT NULL DEFAULT 0,
    "nextReviewAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "lastReviewedAt" TIMESTAMP(3),
    "lastGrade" INTEGER,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "VocabularyProgress_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "public"."PronunciationAttempt" (
    "id" TEXT NOT NULL,
    "userId" TEXT NOT NULL,
    "vocabularyId" TEXT,
    "lessonId" TEXT,
    "targetText" TEXT NOT NULL,
    "audioUrl" TEXT NOT NULL,
    "transcript" TEXT,
    "accuracyScore" INTEGER,
    "feedback" TEXT,
    "status" "public"."PronunciationAttemptStatus" NOT NULL DEFAULT 'PENDING',
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "PronunciationAttempt_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "public"."Badge" (
    "id" TEXT NOT NULL,
    "code" TEXT NOT NULL,
    "name" TEXT NOT NULL,
    "frenchName" TEXT,
    "description" TEXT NOT NULL,
    "frenchDescription" TEXT,
    "iconUrl" TEXT,
    "criteriaType" "public"."BadgeCriteriaType" NOT NULL,
    "criteriaValue" INTEGER NOT NULL,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "Badge_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "public"."UserBadge" (
    "id" TEXT NOT NULL,
    "userId" TEXT NOT NULL,
    "badgeId" TEXT NOT NULL,
    "earnedAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "UserBadge_pkey" PRIMARY KEY ("id")
);

-- CreateIndex
CREATE INDEX "PracticeSession_userId_createdAt_idx" ON "public"."PracticeSession"("userId", "createdAt");

-- CreateIndex
CREATE INDEX "VocabularyProgress_userId_nextReviewAt_idx" ON "public"."VocabularyProgress"("userId", "nextReviewAt");

-- CreateIndex
CREATE UNIQUE INDEX "VocabularyProgress_userId_vocabularyId_key" ON "public"."VocabularyProgress"("userId", "vocabularyId");

-- CreateIndex
CREATE INDEX "PronunciationAttempt_userId_createdAt_idx" ON "public"."PronunciationAttempt"("userId", "createdAt");

-- CreateIndex
CREATE UNIQUE INDEX "Badge_code_key" ON "public"."Badge"("code");

-- CreateIndex
CREATE UNIQUE INDEX "UserBadge_userId_badgeId_key" ON "public"."UserBadge"("userId", "badgeId");

-- AddForeignKey
ALTER TABLE "public"."PracticeSession" ADD CONSTRAINT "PracticeSession_userId_fkey" FOREIGN KEY ("userId") REFERENCES "public"."User"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "public"."VocabularyProgress" ADD CONSTRAINT "VocabularyProgress_userId_fkey" FOREIGN KEY ("userId") REFERENCES "public"."User"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "public"."VocabularyProgress" ADD CONSTRAINT "VocabularyProgress_vocabularyId_fkey" FOREIGN KEY ("vocabularyId") REFERENCES "public"."Vocabulary"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "public"."PronunciationAttempt" ADD CONSTRAINT "PronunciationAttempt_userId_fkey" FOREIGN KEY ("userId") REFERENCES "public"."User"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "public"."PronunciationAttempt" ADD CONSTRAINT "PronunciationAttempt_vocabularyId_fkey" FOREIGN KEY ("vocabularyId") REFERENCES "public"."Vocabulary"("id") ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "public"."PronunciationAttempt" ADD CONSTRAINT "PronunciationAttempt_lessonId_fkey" FOREIGN KEY ("lessonId") REFERENCES "public"."Lesson"("id") ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "public"."UserBadge" ADD CONSTRAINT "UserBadge_userId_fkey" FOREIGN KEY ("userId") REFERENCES "public"."User"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "public"."UserBadge" ADD CONSTRAINT "UserBadge_badgeId_fkey" FOREIGN KEY ("badgeId") REFERENCES "public"."Badge"("id") ON DELETE RESTRICT ON UPDATE CASCADE;
