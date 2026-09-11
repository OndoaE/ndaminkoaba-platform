-- CreateTable
CREATE TABLE "public"."BibleBookCover" (
    "id" TEXT NOT NULL,
    "languageId" TEXT NOT NULL,
    "bookKey" TEXT NOT NULL,
    "coverUrl" TEXT NOT NULL,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "BibleBookCover_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "public"."BibleHeroImage" (
    "id" TEXT NOT NULL,
    "languageId" TEXT NOT NULL,
    "imageUrl" TEXT NOT NULL,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "BibleHeroImage_pkey" PRIMARY KEY ("id")
);

-- CreateIndex
CREATE UNIQUE INDEX "BibleBookCover_languageId_bookKey_key" ON "public"."BibleBookCover"("languageId", "bookKey");

-- CreateIndex
CREATE UNIQUE INDEX "BibleHeroImage_languageId_key" ON "public"."BibleHeroImage"("languageId");

-- AddForeignKey
ALTER TABLE "public"."BibleBookCover" ADD CONSTRAINT "BibleBookCover_languageId_fkey" FOREIGN KEY ("languageId") REFERENCES "public"."Language"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "public"."BibleHeroImage" ADD CONSTRAINT "BibleHeroImage_languageId_fkey" FOREIGN KEY ("languageId") REFERENCES "public"."Language"("id") ON DELETE RESTRICT ON UPDATE CASCADE;
