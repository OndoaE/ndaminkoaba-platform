-- CreateEnum
CREATE TYPE "public"."BookCategory" AS ENUM ('CONTES', 'HISTOIRES', 'CULTURE', 'VIE_QUOTIDIENNE', 'PROVERBES', 'EDUCATION', 'AUTRE');

-- AlterTable
ALTER TABLE "public"."Book" ADD COLUMN     "category" "public"."BookCategory",
ADD COLUMN     "hasImages" BOOLEAN NOT NULL DEFAULT false,
ADD COLUMN     "level" "public"."Level",
ADD COLUMN     "pageCount" INTEGER,
ADD COLUMN     "readingTimeMinutes" INTEGER,
ADD COLUMN     "recommendedAge" INTEGER,
ALTER COLUMN "fileUrl" DROP NOT NULL,
ALTER COLUMN "fileType" DROP NOT NULL;

-- CreateTable
CREATE TABLE "public"."BookPage" (
    "id" TEXT NOT NULL,
    "bookId" TEXT NOT NULL,
    "orderNumber" INTEGER NOT NULL,
    "illustrationUrl" TEXT,
    "ewondoText" TEXT NOT NULL,
    "frenchText" TEXT,
    "audioUrl" TEXT,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "BookPage_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "public"."BookProgress" (
    "id" TEXT NOT NULL,
    "userId" TEXT NOT NULL,
    "bookId" TEXT NOT NULL,
    "lastPageNumber" INTEGER NOT NULL DEFAULT 1,
    "completed" BOOLEAN NOT NULL DEFAULT false,
    "updatedAt" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "BookProgress_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "public"."BookBookmark" (
    "id" TEXT NOT NULL,
    "userId" TEXT NOT NULL,
    "bookId" TEXT NOT NULL,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "BookBookmark_pkey" PRIMARY KEY ("id")
);

-- CreateIndex
CREATE INDEX "BookPage_bookId_orderNumber_idx" ON "public"."BookPage"("bookId", "orderNumber");

-- CreateIndex
CREATE UNIQUE INDEX "BookProgress_userId_bookId_key" ON "public"."BookProgress"("userId", "bookId");

-- CreateIndex
CREATE UNIQUE INDEX "BookBookmark_userId_bookId_key" ON "public"."BookBookmark"("userId", "bookId");

-- AddForeignKey
ALTER TABLE "public"."BookPage" ADD CONSTRAINT "BookPage_bookId_fkey" FOREIGN KEY ("bookId") REFERENCES "public"."Book"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "public"."BookProgress" ADD CONSTRAINT "BookProgress_userId_fkey" FOREIGN KEY ("userId") REFERENCES "public"."User"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "public"."BookProgress" ADD CONSTRAINT "BookProgress_bookId_fkey" FOREIGN KEY ("bookId") REFERENCES "public"."Book"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "public"."BookBookmark" ADD CONSTRAINT "BookBookmark_userId_fkey" FOREIGN KEY ("userId") REFERENCES "public"."User"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "public"."BookBookmark" ADD CONSTRAINT "BookBookmark_bookId_fkey" FOREIGN KEY ("bookId") REFERENCES "public"."Book"("id") ON DELETE CASCADE ON UPDATE CASCADE;
