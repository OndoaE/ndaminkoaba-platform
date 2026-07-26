import { Injectable } from '@nestjs/common';
import { BadgeCriteriaType } from '@prisma/client';

import { PrismaService } from '../prisma/prisma.service';

// A word counts as "mastered" once its SM-2 interval has grown past three
// weeks — a reasonable proxy for "the learner reliably recalls this now"
// without requiring a separate explicit mastery flag.
const MASTERED_INTERVAL_DAYS = 21;

@Injectable()
export class BadgesService {
  constructor(private readonly prisma: PrismaService) {}

  private async getCurrentValue(userId: string, criteriaType: BadgeCriteriaType): Promise<number> {
    switch (criteriaType) {
      case BadgeCriteriaType.STREAK_DAYS: {
        const user = await this.prisma.user.findUniqueOrThrow({
          where: { id: userId },
          select: { currentStreak: true },
        });
        return user.currentStreak;
      }
      case BadgeCriteriaType.SESSIONS_COMPLETED:
        return this.prisma.practiceSession.count({ where: { userId } });
      case BadgeCriteriaType.LESSONS_COMPLETED:
        return this.prisma.progress.count({ where: { userId, completed: true } });
      case BadgeCriteriaType.QUIZZES_PASSED:
        return this.prisma.quizAttempt.count({ where: { userId, passed: true } });
      case BadgeCriteriaType.VOCAB_MASTERED:
        return this.prisma.vocabularyProgress.count({
          where: { userId, intervalDays: { gte: MASTERED_INTERVAL_DAYS } },
        });
      case BadgeCriteriaType.PRONUNCIATION_SESSIONS:
        return this.prisma.pronunciationAttempt.count({ where: { userId, status: 'SCORED' } });
      default:
        return 0;
    }
  }

  async getBadgesForUser(userId: string) {
    const [badges, userBadges] = await Promise.all([
      this.prisma.badge.findMany({ orderBy: { criteriaValue: 'asc' } }),
      this.prisma.userBadge.findMany({ where: { userId } }),
    ]);

    const earnedByBadgeId = new Map(userBadges.map((ub) => [ub.badgeId, ub.earnedAt]));

    return Promise.all(
      badges.map(async (badge) => {
        const progress = await this.getCurrentValue(userId, badge.criteriaType);
        return {
          ...badge,
          earned: earnedByBadgeId.has(badge.id),
          earnedAt: earnedByBadgeId.get(badge.id) ?? null,
          progress: Math.min(progress, badge.criteriaValue),
        };
      }),
    );
  }

  /// Runs after any activity that could complete a badge. Returns only the
  /// badges newly earned by this call, so callers can surface a celebration
  /// moment without a separate polling endpoint.
  async evaluateAndAward(userId: string) {
    const [badges, userBadges] = await Promise.all([
      this.prisma.badge.findMany(),
      this.prisma.userBadge.findMany({ where: { userId } }),
    ]);

    const earnedBadgeIds = new Set(userBadges.map((ub) => ub.badgeId));
    const newlyEarned: (typeof badges)[number][] = [];

    for (const badge of badges) {
      if (earnedBadgeIds.has(badge.id)) continue;

      const currentValue = await this.getCurrentValue(userId, badge.criteriaType);
      if (currentValue >= badge.criteriaValue) {
        await this.prisma.userBadge.create({
          data: { userId, badgeId: badge.id },
        });
        newlyEarned.push(badge);
      }
    }

    return newlyEarned;
  }
}
