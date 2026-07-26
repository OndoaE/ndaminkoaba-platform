import { BadRequestException, Injectable } from '@nestjs/common';
import { PracticeActivityType } from '@prisma/client';

import { PrismaService } from '../prisma/prisma.service';
import { StreaksService } from '../streaks/streaks.service';
import { BadgesService } from '../badges/badges.service';
import { applySm2 } from './sm2';

@Injectable()
export class VocabularyReviewService {
  constructor(
    private readonly prisma: PrismaService,
    private readonly streaksService: StreaksService,
    private readonly badgesService: BadgesService,
  ) {}

  async getDue(userId: string, limit = 20) {
    const [items, dueCount] = await Promise.all([
      this.prisma.vocabularyProgress.findMany({
        where: { userId, nextReviewAt: { lte: new Date() } },
        orderBy: { nextReviewAt: 'asc' },
        take: limit,
        include: { vocabulary: true },
      }),
      this.prisma.vocabularyProgress.count({
        where: { userId, nextReviewAt: { lte: new Date() } },
      }),
    ]);

    return { items, dueCount };
  }

  async grade(userId: string, vocabularyId: string, grade: number) {
    const vocabulary = await this.prisma.vocabulary.findUnique({
      where: { id: vocabularyId },
    });

    if (!vocabulary) {
      throw new BadRequestException('Invalid vocabularyId.');
    }

    const existing = await this.prisma.vocabularyProgress.findUnique({
      where: { userId_vocabularyId: { userId, vocabularyId } },
    });

    const currentState = {
      easeFactor: existing?.easeFactor ?? 2.5,
      intervalDays: existing?.intervalDays ?? 0,
      repetitions: existing?.repetitions ?? 0,
    };

    const nextState = applySm2(currentState, grade);
    const nextReviewAt = new Date();
    nextReviewAt.setUTCDate(nextReviewAt.getUTCDate() + nextState.intervalDays);

    const updated = await this.prisma.vocabularyProgress.upsert({
      where: { userId_vocabularyId: { userId, vocabularyId } },
      update: {
        ...nextState,
        nextReviewAt,
        lastReviewedAt: new Date(),
        lastGrade: grade,
      },
      create: {
        userId,
        vocabularyId,
        ...nextState,
        nextReviewAt,
        lastReviewedAt: new Date(),
        lastGrade: grade,
      },
    });

    await this.streaksService.recordActivity(userId, PracticeActivityType.SMART_REVIEW, 30);
    const newlyEarnedBadges = await this.badgesService.evaluateAndAward(userId);

    return { ...updated, newlyEarnedBadges };
  }

  /// Auto-seeds a VocabularyProgress row (with the SM-2 defaults) for every
  /// word tied to a lesson, the first time that lesson is completed — so
  /// Smart Review has content without a manual "add to review" step.
  /// Upserts, so re-completing a lesson never resets existing progress.
  async seedFromLesson(userId: string, lessonId: string) {
    const words = await this.prisma.vocabulary.findMany({
      where: { lessonId },
      select: { id: true },
    });

    if (words.length === 0) return;

    await Promise.all(
      words.map((word) =>
        this.prisma.vocabularyProgress.upsert({
          where: { userId_vocabularyId: { userId, vocabularyId: word.id } },
          update: {},
          create: { userId, vocabularyId: word.id },
        }),
      ),
    );
  }
}
