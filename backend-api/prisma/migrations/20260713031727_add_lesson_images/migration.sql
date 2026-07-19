-- CreateTable
CREATE TABLE "public"."LessonImage" (
    "id" TEXT NOT NULL,
    "imageUrl" TEXT NOT NULL,
    "word" TEXT NOT NULL,
    "caption" TEXT,
    "orderNumber" INTEGER NOT NULL DEFAULT 1,
    "lessonId" TEXT NOT NULL,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "LessonImage_pkey" PRIMARY KEY ("id")
);

-- AddForeignKey
ALTER TABLE "public"."LessonImage" ADD CONSTRAINT "LessonImage_lessonId_fkey" FOREIGN KEY ("lessonId") REFERENCES "public"."Lesson"("id") ON DELETE CASCADE ON UPDATE CASCADE;
