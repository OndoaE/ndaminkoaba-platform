-- CreateTable
CREATE TABLE "public"."KnowledgeText" (
    "id" TEXT NOT NULL,
    "text" TEXT NOT NULL,
    "translation" TEXT,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "KnowledgeText_pkey" PRIMARY KEY ("id")
);
