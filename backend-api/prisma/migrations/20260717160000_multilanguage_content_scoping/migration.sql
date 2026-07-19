-- Multi-language content scoping: adds a languageId FK to every content
-- model that was previously implicitly Ewondo-only, and renames the
-- hardcoded ewondo* columns to generic names. All existing rows are
-- backfilled to the single "Ewondo" Language row (code 'ewo') that already
-- exists, so this is a zero-data-loss migration.

-- RenameColumn
ALTER TABLE "public"."Vocabulary" RENAME COLUMN "ewondoWord" TO "word";
ALTER TABLE "public"."BibleVerse" RENAME COLUMN "ewondoText" TO "text";
ALTER TABLE "public"."DailyWord" RENAME COLUMN "ewondoWord" TO "word";
ALTER TABLE "public"."DailyVerse" RENAME COLUMN "ewondoText" TO "text";

-- AddColumn (nullable first, backfilled below, then tightened to NOT NULL)
ALTER TABLE "public"."Vocabulary" ADD COLUMN "languageId" TEXT;
ALTER TABLE "public"."BibleVerse" ADD COLUMN "languageId" TEXT;
ALTER TABLE "public"."DailyWord" ADD COLUMN "languageId" TEXT;
ALTER TABLE "public"."DailyVerse" ADD COLUMN "languageId" TEXT;
ALTER TABLE "public"."KnowledgeText" ADD COLUMN "languageId" TEXT;
ALTER TABLE "public"."Book" ADD COLUMN "languageId" TEXT;

-- Backfill: every existing row belongs to the single pre-existing "Ewondo"
-- language (code 'ewo', created by prisma/seed.ts).
UPDATE "public"."Vocabulary" SET "languageId" = (SELECT "id" FROM "public"."Language" WHERE "code" = 'ewo' LIMIT 1) WHERE "languageId" IS NULL;
UPDATE "public"."BibleVerse" SET "languageId" = (SELECT "id" FROM "public"."Language" WHERE "code" = 'ewo' LIMIT 1) WHERE "languageId" IS NULL;
UPDATE "public"."DailyWord" SET "languageId" = (SELECT "id" FROM "public"."Language" WHERE "code" = 'ewo' LIMIT 1) WHERE "languageId" IS NULL;
UPDATE "public"."DailyVerse" SET "languageId" = (SELECT "id" FROM "public"."Language" WHERE "code" = 'ewo' LIMIT 1) WHERE "languageId" IS NULL;
UPDATE "public"."KnowledgeText" SET "languageId" = (SELECT "id" FROM "public"."Language" WHERE "code" = 'ewo' LIMIT 1) WHERE "languageId" IS NULL;
UPDATE "public"."Book" SET "languageId" = (SELECT "id" FROM "public"."Language" WHERE "code" = 'ewo' LIMIT 1) WHERE "languageId" IS NULL;

-- Tighten to NOT NULL now that every row has a value.
ALTER TABLE "public"."Vocabulary" ALTER COLUMN "languageId" SET NOT NULL;
ALTER TABLE "public"."BibleVerse" ALTER COLUMN "languageId" SET NOT NULL;
ALTER TABLE "public"."DailyWord" ALTER COLUMN "languageId" SET NOT NULL;
ALTER TABLE "public"."DailyVerse" ALTER COLUMN "languageId" SET NOT NULL;
ALTER TABLE "public"."KnowledgeText" ALTER COLUMN "languageId" SET NOT NULL;
ALTER TABLE "public"."Book" ALTER COLUMN "languageId" SET NOT NULL;

-- DropIndex (old unique constraint, single-language assumption)
DROP INDEX "public"."BibleVerse_book_chapter_verse_version_key";

-- CreateIndex (new unique constraint, scoped per language so the same
-- book/chapter/verse/version can exist once per language)
CREATE UNIQUE INDEX "BibleVerse_book_chapter_verse_version_languageId_key" ON "public"."BibleVerse"("book", "chapter", "verse", "version", "languageId");

-- AddForeignKey
ALTER TABLE "public"."Vocabulary" ADD CONSTRAINT "Vocabulary_languageId_fkey" FOREIGN KEY ("languageId") REFERENCES "public"."Language"("id") ON DELETE RESTRICT ON UPDATE CASCADE;
ALTER TABLE "public"."BibleVerse" ADD CONSTRAINT "BibleVerse_languageId_fkey" FOREIGN KEY ("languageId") REFERENCES "public"."Language"("id") ON DELETE RESTRICT ON UPDATE CASCADE;
ALTER TABLE "public"."DailyWord" ADD CONSTRAINT "DailyWord_languageId_fkey" FOREIGN KEY ("languageId") REFERENCES "public"."Language"("id") ON DELETE RESTRICT ON UPDATE CASCADE;
ALTER TABLE "public"."DailyVerse" ADD CONSTRAINT "DailyVerse_languageId_fkey" FOREIGN KEY ("languageId") REFERENCES "public"."Language"("id") ON DELETE RESTRICT ON UPDATE CASCADE;
ALTER TABLE "public"."KnowledgeText" ADD CONSTRAINT "KnowledgeText_languageId_fkey" FOREIGN KEY ("languageId") REFERENCES "public"."Language"("id") ON DELETE RESTRICT ON UPDATE CASCADE;
ALTER TABLE "public"."Book" ADD CONSTRAINT "Book_languageId_fkey" FOREIGN KEY ("languageId") REFERENCES "public"."Language"("id") ON DELETE RESTRICT ON UPDATE CASCADE;
