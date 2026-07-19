-- CreateTable
CREATE TABLE "public"."DailyWord" (
    "id" TEXT NOT NULL,
    "ewondoWord" TEXT NOT NULL,
    "englishMeaning" TEXT,
    "frenchMeaning" TEXT,
    "usageHint" TEXT,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "DailyWord_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "public"."DailyVerse" (
    "id" TEXT NOT NULL,
    "ewondoText" TEXT NOT NULL,
    "englishText" TEXT,
    "frenchText" TEXT,
    "reference" TEXT NOT NULL,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "DailyVerse_pkey" PRIMARY KEY ("id")
);
