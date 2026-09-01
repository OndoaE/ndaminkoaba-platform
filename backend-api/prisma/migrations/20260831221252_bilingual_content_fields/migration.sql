-- AlterTable
ALTER TABLE "public"."Book" ADD COLUMN     "frenchDescription" TEXT;

-- AlterTable
ALTER TABLE "public"."BookPage" ADD COLUMN     "englishText" TEXT;

-- AlterTable
-- Hand-edited from the Prisma-generated version: the auto-diff produced a
-- destructive `DROP COLUMN "translation"`, which would have discarded 276
-- real, live French translations already in production. `translation` was
-- always French text (verified directly against production data before
-- writing this migration); renaming it preserves every existing row
-- instead of losing the column's contents.
ALTER TABLE "public"."SyllabaryEntry" RENAME COLUMN "translation" TO "frenchTranslation";
ALTER TABLE "public"."SyllabaryEntry" ADD COLUMN     "englishTranslation" TEXT;
