import { Injectable } from '@nestjs/common';
import { PracticeActivityType } from '@prisma/client';

import { PrismaService } from '../prisma/prisma.service';

function startOfUtcDay(date: Date): Date {
  return new Date(Date.UTC(date.getUTCFullYear(), date.getUTCMonth(), date.getUTCDate()));
}

function isSameUtcDay(a: Date, b: Date): boolean {
  return startOfUtcDay(a).getTime() === startOfUtcDay(b).getTime();
}

function isConsecutiveUtcDay(previous: Date, current: Date): boolean {
  const previousDay = startOfUtcDay(previous);
  const currentDay = startOfUtcDay(current);
  const diffMs = currentDay.getTime() - previousDay.getTime();
  return diffMs === 24 * 60 * 60 * 1000;
}

@Injectable()
export class StreaksService {
  constructor(private readonly prisma: PrismaService) {}

  async getMe(userId: string) {
    const user = await this.prisma.user.findUniqueOrThrow({
      where: { id: userId },
      select: { currentStreak: true, longestStreak: true, dailyGoalMinutes: true },
    });

    const startOfToday = startOfUtcDay(new Date());
    const sessions = await this.prisma.practiceSession.aggregate({
      where: { userId, createdAt: { gte: startOfToday } },
      _sum: { durationSec: true },
    });

    const todayMinutes = Math.round((sessions._sum.durationSec ?? 0) / 60);

    return {
      currentStreak: user.currentStreak,
      longestStreak: user.longestStreak,
      dailyGoalMinutes: user.dailyGoalMinutes,
      todayMinutes,
    };
  }

  async updateGoal(userId: string, minutes: number) {
    await this.prisma.user.update({
      where: { id: userId },
      data: { dailyGoalMinutes: minutes },
    });

    return { dailyGoalMinutes: minutes };
  }

  /// Shared entry point injected by every module that logs learner practice
  /// (lessons, quizzes, Smart Review, pronunciation, AI chat). Records the
  /// activity and updates the streak lazily — no cron job: streak state is
  /// only ever recomputed the next time the learner does something.
  /// "Day" boundaries use UTC calendar days for simplicity; this is a
  /// server-side, not device-local, day boundary.
  async recordActivity(
    userId: string,
    activityType: PracticeActivityType,
    durationSec: number,
    context: { lessonId?: string; courseId?: string } = {},
  ) {
    await this.prisma.practiceSession.create({
      data: {
        userId,
        activityType,
        durationSec,
        lessonId: context.lessonId,
        courseId: context.courseId,
      },
    });

    const user = await this.prisma.user.findUniqueOrThrow({
      where: { id: userId },
      select: { currentStreak: true, longestStreak: true, lastStreakDate: true },
    });

    const now = new Date();
    let nextStreak = user.currentStreak;

    if (!user.lastStreakDate) {
      nextStreak = 1;
    } else if (isSameUtcDay(user.lastStreakDate, now)) {
      nextStreak = user.currentStreak;
    } else if (isConsecutiveUtcDay(user.lastStreakDate, now)) {
      nextStreak = user.currentStreak + 1;
    } else {
      nextStreak = 1;
    }

    await this.prisma.user.update({
      where: { id: userId },
      data: {
        currentStreak: nextStreak,
        longestStreak: Math.max(nextStreak, user.longestStreak),
        lastStreakDate: now,
      },
    });
  }
}
