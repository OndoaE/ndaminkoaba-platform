-- AlterTable
ALTER TABLE "public"."Lesson" ADD COLUMN     "category" TEXT,
ADD COLUMN     "coverImageUrl" TEXT,
ADD COLUMN     "estimatedMinutes" INTEGER,
ADD COLUMN     "learningObjectives" TEXT[] DEFAULT ARRAY[]::TEXT[],
ADD COLUMN     "outcomes" TEXT[] DEFAULT ARRAY[]::TEXT[];

-- CreateTable
CREATE TABLE "public"."LessonViewHistory" (
    "id" TEXT NOT NULL,
    "userId" TEXT NOT NULL,
    "lessonId" TEXT NOT NULL,
    "viewDate" TIMESTAMP(3) NOT NULL,
    "viewedAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "LessonViewHistory_pkey" PRIMARY KEY ("id")
);

-- CreateIndex
CREATE UNIQUE INDEX "LessonViewHistory_userId_lessonId_viewDate_key" ON "public"."LessonViewHistory"("userId", "lessonId", "viewDate");

-- AddForeignKey
ALTER TABLE "public"."LessonViewHistory" ADD CONSTRAINT "LessonViewHistory_userId_fkey" FOREIGN KEY ("userId") REFERENCES "public"."User"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "public"."LessonViewHistory" ADD CONSTRAINT "LessonViewHistory_lessonId_fkey" FOREIGN KEY ("lessonId") REFERENCES "public"."Lesson"("id") ON DELETE RESTRICT ON UPDATE CASCADE;
