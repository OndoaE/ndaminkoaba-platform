-- DropForeignKey
ALTER TABLE "public"."Vocabulary" DROP CONSTRAINT "Vocabulary_lessonId_fkey";

-- AlterTable
ALTER TABLE "public"."Vocabulary" ADD COLUMN     "exampleTranslation" TEXT,
ALTER COLUMN "lessonId" DROP NOT NULL;

-- AddForeignKey
ALTER TABLE "public"."Vocabulary" ADD CONSTRAINT "Vocabulary_lessonId_fkey" FOREIGN KEY ("lessonId") REFERENCES "public"."Lesson"("id") ON DELETE SET NULL ON UPDATE CASCADE;
