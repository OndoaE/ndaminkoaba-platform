-- CreateTable
CREATE TABLE "public"."BibleVerse" (
    "id" TEXT NOT NULL,
    "book" TEXT NOT NULL,
    "chapter" INTEGER NOT NULL,
    "verse" INTEGER NOT NULL,
    "ewondoText" TEXT NOT NULL,
    "englishText" TEXT,
    "version" TEXT NOT NULL DEFAULT 'ESV',
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "BibleVerse_pkey" PRIMARY KEY ("id")
);

-- CreateIndex
CREATE UNIQUE INDEX "BibleVerse_book_chapter_verse_version_key" ON "public"."BibleVerse"("book", "chapter", "verse", "version");
