import { Injectable } from '@nestjs/common';
import { LessonStatus, Prisma } from '@prisma/client';

import { PrismaService } from '../prisma/prisma.service';

@Injectable()
export class ContentWorkflowService {
  constructor(private readonly prisma: PrismaService) {}

  async getContentWorkflow(languageId?: string) {
    const where: Prisma.LessonWhereInput = languageId
      ? { module: { course: { languageId } } }
      : {};

    const counts = await this.prisma.lesson.groupBy({
      by: ['status'],
      _count: true,
      where,
    });

    const result = { draft: 0, inReview: 0, approved: 0, published: 0 };

    for (const row of counts) {
      const count = row._count as unknown as number;
      switch (row.status) {
        case LessonStatus.DRAFT:
          result.draft = count;
          break;
        case LessonStatus.IN_REVIEW:
          result.inReview = count;
          break;
        case LessonStatus.APPROVED:
          result.approved = count;
          break;
        case LessonStatus.PUBLISHED:
          result.published = count;
          break;
      }
    }

    return result;
  }
}
