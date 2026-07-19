-- AlterTable
ALTER TABLE "public"."Choice" ADD COLUMN     "frenchChoiceText" TEXT;

-- AlterTable
ALTER TABLE "public"."Course" ADD COLUMN     "frenchDescription" TEXT,
ADD COLUMN     "frenchTitle" TEXT;

-- AlterTable
ALTER TABLE "public"."CourseModule" ADD COLUMN     "frenchDescription" TEXT,
ADD COLUMN     "frenchTitle" TEXT;

-- AlterTable
ALTER TABLE "public"."Lesson" ADD COLUMN     "frenchContent" TEXT,
ADD COLUMN     "frenchSummary" TEXT,
ADD COLUMN     "frenchTitle" TEXT;

-- AlterTable
ALTER TABLE "public"."Question" ADD COLUMN     "frenchExplanation" TEXT,
ADD COLUMN     "frenchQuestionText" TEXT;

-- AlterTable
ALTER TABLE "public"."Quiz" ADD COLUMN     "frenchDescription" TEXT,
ADD COLUMN     "frenchTitle" TEXT;
