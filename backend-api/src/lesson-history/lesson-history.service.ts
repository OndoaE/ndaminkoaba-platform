import { Injectable } from '@nestjs/common';

import { PrismaService } from '../prisma/prisma.service';
import { CreateLessonHistoryDto } from './dto/create-lesson-history.dto';
import { QueryLessonHistoryDto } from './dto/query-lesson-history.dto';

function startOfUtcDay(date: Date): Date {
  return new Date(Date.UTC(date.getUTCFullYear(), date.getUTCMonth(), date.getUTCDate()));
}

@Injectable()
export class LessonHistoryService {
  constructor(private readonly prisma: PrismaService) {}

  /// Upserts by (userId, lessonId, viewDate) so reopening the same lesson
  /// several times in one day updates the existing row's `viewedAt` instead
  /// of appending duplicates — keeps the Historique list one entry per
  /// lesson per day. Callers should treat this as best-effort (see
  /// LessonHistoryController) — a failure here must never block the learner
  /// from seeing lesson content.
  async recordView(dto: CreateLessonHistoryDto) {
    const viewDate = startOfUtcDay(new Date());
    return this.prisma.lessonViewHistory.upsert({
      where: {
        userId_lessonId_viewDate: {
          userId: dto.userId,
          lessonId: dto.lessonId,
          viewDate,
        },
      },
      create: { userId: dto.userId, lessonId: dto.lessonId, viewDate },
      update: { viewedAt: new Date() },
    });
  }

  async findAllForUser(query: QueryLessonHistoryDto) {
    const { page = 1, limit = 10, userId } = query;
    const skip = (page - 1) * limit;

    const where = userId ? { userId } : {};

    const [items, total] = await Promise.all([
      this.prisma.lessonViewHistory.findMany({
        where,
        skip,
        take: limit,
        orderBy: { viewedAt: 'desc' },
        include: {
          lesson: {
            include: { module: { include: { course: true } } },
          },
        },
      }),
      this.prisma.lessonViewHistory.count({ where }),
    ]);

    return { items, total, page, limit, totalPages: Math.ceil(total / limit) };
  }
}
