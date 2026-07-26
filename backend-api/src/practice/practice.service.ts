import { Injectable } from '@nestjs/common';

import { PrismaService } from '../prisma/prisma.service';

function startOfUtcDay(date: Date): Date {
  return new Date(Date.UTC(date.getUTCFullYear(), date.getUTCMonth(), date.getUTCDate()));
}

@Injectable()
export class PracticeService {
  constructor(private readonly prisma: PrismaService) {}

  async getToday(userId: string) {
    const user = await this.prisma.user.findUniqueOrThrow({
      where: { id: userId },
      select: { dailyGoalMinutes: true },
    });

    const startOfToday = startOfUtcDay(new Date());
    const sessions = await this.prisma.practiceSession.aggregate({
      where: { userId, createdAt: { gte: startOfToday } },
      _sum: { durationSec: true },
    });

    const minutesToday = Math.round((sessions._sum.durationSec ?? 0) / 60);
    const goalMinutes = user.dailyGoalMinutes;

    return {
      minutesToday,
      goalMinutes,
      progressRatio: goalMinutes > 0 ? Math.min(1, minutesToday / goalMinutes) : 0,
    };
  }

  async getWeeklyCalendar(userId: string) {
    const today = startOfUtcDay(new Date());
    const sevenDaysAgo = new Date(today);
    sevenDaysAgo.setUTCDate(sevenDaysAgo.getUTCDate() - 6);

    const sessions = await this.prisma.practiceSession.findMany({
      where: { userId, createdAt: { gte: sevenDaysAgo } },
      select: { createdAt: true, durationSec: true },
    });

    const minutesByDay = new Map<string, number>();
    for (const session of sessions) {
      const key = startOfUtcDay(session.createdAt).toISOString();
      minutesByDay.set(key, (minutesByDay.get(key) ?? 0) + session.durationSec / 60);
    }

    const days: { date: string; completed: boolean; minutes: number }[] = [];
    for (let i = 0; i < 7; i++) {
      const day = new Date(sevenDaysAgo);
      day.setUTCDate(day.getUTCDate() + i);
      const key = day.toISOString();
      const minutes = Math.round(minutesByDay.get(key) ?? 0);

      days.push({
        date: key.slice(0, 10),
        completed: minutes > 0,
        minutes,
      });
    }

    return days;
  }
}
