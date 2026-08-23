-- CreateTable
CREATE TABLE "public"."SyllabaryEntry" (
    "id" TEXT NOT NULL,
    "consonant" TEXT,
    "vowel" TEXT NOT NULL,
    "syllable" TEXT NOT NULL,
    "exampleWord" TEXT,
    "translation" TEXT,
    "exampleSentence" TEXT,
    "orderNumber" INTEGER NOT NULL,
    "languageId" TEXT NOT NULL,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "SyllabaryEntry_pkey" PRIMARY KEY ("id")
);

-- CreateIndex
CREATE INDEX "SyllabaryEntry_languageId_consonant_idx" ON "public"."SyllabaryEntry"("languageId", "consonant");

-- AddForeignKey
ALTER TABLE "public"."SyllabaryEntry" ADD CONSTRAINT "SyllabaryEntry_languageId_fkey" FOREIGN KEY ("languageId") REFERENCES "public"."Language"("id") ON DELETE RESTRICT ON UPDATE CASCADE;
