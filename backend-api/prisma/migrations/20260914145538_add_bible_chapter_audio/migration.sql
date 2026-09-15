-- CreateTable
CREATE TABLE "public"."BibleChapterAudio" (
    "id" TEXT NOT NULL,
    "languageId" TEXT NOT NULL,
    "book" TEXT NOT NULL,
    "chapter" INTEGER NOT NULL,
    "audioUrl" TEXT NOT NULL,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "BibleChapterAudio_pkey" PRIMARY KEY ("id")
);

-- CreateIndex
CREATE UNIQUE INDEX "BibleChapterAudio_languageId_book_chapter_key" ON "public"."BibleChapterAudio"("languageId", "book", "chapter");

-- AddForeignKey
ALTER TABLE "public"."BibleChapterAudio" ADD CONSTRAINT "BibleChapterAudio_languageId_fkey" FOREIGN KEY ("languageId") REFERENCES "public"."Language"("id") ON DELETE RESTRICT ON UPDATE CASCADE;
