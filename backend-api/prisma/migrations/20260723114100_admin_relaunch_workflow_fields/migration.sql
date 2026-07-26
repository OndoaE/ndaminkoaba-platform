-- CreateEnum
CREATE TYPE "public"."CourseVisibility" AS ENUM ('PUBLIC', 'PRIVATE');

-- CreateEnum
CREATE TYPE "public"."CourseEnrollmentMode" AS ENUM ('OPEN', 'INVITE_ONLY');

-- CreateEnum
CREATE TYPE "public"."LessonStatus" AS ENUM ('DRAFT', 'IN_REVIEW', 'APPROVED', 'PUBLISHED');

-- CreateEnum
CREATE TYPE "public"."LessonBlockType" AS ENUM ('TEXT', 'VOCABULARY', 'IMAGE', 'AUDIO', 'VIDEO', 'DIALOGUE', 'PRONUNCIATION', 'EXERCISE', 'QUIZ', 'AI_ACTIVITY');

-- CreateEnum
CREATE TYPE "public"."LessonBlockStatus" AS ENUM ('DRAFT', 'READY');

-- AlterEnum
ALTER TYPE "public"."CourseStatus" ADD VALUE 'IN_REVIEW';

-- AlterTable
ALTER TABLE "public"."Course" ADD COLUMN     "category" TEXT,
ADD COLUMN     "enrollmentMode" "public"."CourseEnrollmentMode" NOT NULL DEFAULT 'OPEN',
ADD COLUMN     "issueCertificate" BOOLEAN NOT NULL DEFAULT true,
ADD COLUMN     "learningObjectives" TEXT[] DEFAULT ARRAY[]::TEXT[],
ADD COLUMN     "prerequisiteCourseId" TEXT,
ADD COLUMN     "publicationDate" TIMESTAMP(3),
ADD COLUMN     "reviewerId" TEXT,
ADD COLUMN     "subtitle" TEXT,
ADD COLUMN     "supportLanguageCodes" TEXT[] DEFAULT ARRAY[]::TEXT[],
ADD COLUMN     "tags" TEXT[] DEFAULT ARRAY[]::TEXT[],
ADD COLUMN     "visibility" "public"."CourseVisibility" NOT NULL DEFAULT 'PUBLIC';

-- AlterTable
ALTER TABLE "public"."Lesson" ADD COLUMN     "completionRule" TEXT,
ADD COLUMN     "difficulty" "public"."Level",
ADD COLUMN     "generatedByAi" BOOLEAN NOT NULL DEFAULT false,
ADD COLUMN     "lessonType" TEXT,
ADD COLUMN     "prerequisiteLessonId" TEXT,
ADD COLUMN     "reviewerId" TEXT,
ADD COLUMN     "status" "public"."LessonStatus" NOT NULL DEFAULT 'DRAFT',
ADD COLUMN     "visibility" TEXT;

-- CreateTable
CREATE TABLE "public"."LessonComment" (
    "id" TEXT NOT NULL,
    "lessonId" TEXT NOT NULL,
    "authorId" TEXT NOT NULL,
    "text" TEXT NOT NULL,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "LessonComment_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "public"."LessonBlock" (
    "id" TEXT NOT NULL,
    "lessonId" TEXT NOT NULL,
    "orderNumber" INTEGER NOT NULL,
    "type" "public"."LessonBlockType" NOT NULL,
    "status" "public"."LessonBlockStatus" NOT NULL DEFAULT 'DRAFT',
    "titleLabel" TEXT,
    "textContent" TEXT,
    "frenchTextContent" TEXT,
    "vocabularyId" TEXT,
    "mediaUrl" TEXT,
    "dialogueJson" JSONB,
    "exerciseJson" JSONB,
    "quizId" TEXT,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "LessonBlock_pkey" PRIMARY KEY ("id")
);

-- AddForeignKey
ALTER TABLE "public"."Course" ADD CONSTRAINT "Course_reviewerId_fkey" FOREIGN KEY ("reviewerId") REFERENCES "public"."User"("id") ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "public"."Course" ADD CONSTRAINT "Course_prerequisiteCourseId_fkey" FOREIGN KEY ("prerequisiteCourseId") REFERENCES "public"."Course"("id") ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "public"."Lesson" ADD CONSTRAINT "Lesson_reviewerId_fkey" FOREIGN KEY ("reviewerId") REFERENCES "public"."User"("id") ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "public"."Lesson" ADD CONSTRAINT "Lesson_prerequisiteLessonId_fkey" FOREIGN KEY ("prerequisiteLessonId") REFERENCES "public"."Lesson"("id") ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "public"."LessonComment" ADD CONSTRAINT "LessonComment_lessonId_fkey" FOREIGN KEY ("lessonId") REFERENCES "public"."Lesson"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "public"."LessonComment" ADD CONSTRAINT "LessonComment_authorId_fkey" FOREIGN KEY ("authorId") REFERENCES "public"."User"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "public"."LessonBlock" ADD CONSTRAINT "LessonBlock_lessonId_fkey" FOREIGN KEY ("lessonId") REFERENCES "public"."Lesson"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "public"."LessonBlock" ADD CONSTRAINT "LessonBlock_vocabularyId_fkey" FOREIGN KEY ("vocabularyId") REFERENCES "public"."Vocabulary"("id") ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "public"."LessonBlock" ADD CONSTRAINT "LessonBlock_quizId_fkey" FOREIGN KEY ("quizId") REFERENCES "public"."Quiz"("id") ON DELETE SET NULL ON UPDATE CASCADE;
