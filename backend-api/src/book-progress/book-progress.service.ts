import { Injectable } from '@nestjs/common';

import { PrismaService } from '../prisma/prisma.service';
import { CreateBookProgressDto } from './dto/create-book-progress.dto';
import { QueryBookProgressDto } from './dto/query-book-progress.dto';

@Injectable()
export class BookProgressService {
  constructor(private readonly prisma: PrismaService) {}

  /// Upserts by (userId, bookId) so re-recording the same reading session
  /// updates the existing row instead of erroring on the unique
  /// constraint — this is the "best-effort, fire on every page turn"
  /// entry point (see BookReaderScreen), so it must always succeed cheaply.
  async recordProgress(dto: CreateBookProgressDto) {
    const book = await this.prisma.book.findUnique({
      where: { id: dto.bookId },
      select: { pageCount: true },
    });
    const completed = book?.pageCount != null && dto.lastPageNumber >= book.pageCount;

    return this.prisma.bookProgress.upsert({
      where: { userId_bookId: { userId: dto.userId, bookId: dto.bookId } },
      create: { userId: dto.userId, bookId: dto.bookId, lastPageNumber: dto.lastPageNumber, completed },
      update: { lastPageNumber: dto.lastPageNumber, completed },
    });
  }

  async findAll(query: QueryBookProgressDto) {
    const { page = 1, limit = 100, userId, bookId } = query;
    const skip = (page - 1) * limit;

    const where = { ...(userId ? { userId } : {}), ...(bookId ? { bookId } : {}) };

    const [items, total] = await Promise.all([
      this.prisma.bookProgress.findMany({ where, skip, take: limit, orderBy: { updatedAt: 'desc' } }),
      this.prisma.bookProgress.count({ where }),
    ]);

    return { items, total, page, limit, totalPages: Math.ceil(total / limit) };
  }
}
