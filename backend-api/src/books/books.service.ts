import { Injectable, NotFoundException } from '@nestjs/common';
import { Prisma } from '@prisma/client';

import { PrismaService } from '../prisma/prisma.service';
import { CreateBookDto } from './dto/create-book.dto';
import { UpdateBookDto } from './dto/update-book.dto';
import { QueryBookDto } from './dto/query-book.dto';
import { extractBookText } from './book-text-extractor';

@Injectable()
export class BooksService {
  constructor(private readonly prisma: PrismaService) {}

  async create(dto: CreateBookDto) {
    const content = await extractBookText(dto.fileUrl, dto.fileType);
    return this.prisma.book.create({ data: { ...dto, content } });
  }

  async findAll(query: QueryBookDto) {
    const { page = 1, limit = 10, search, languageId } = query;
    const skip = (page - 1) * limit;

    const where: Prisma.BookWhereInput = {};
    if (languageId) where.languageId = languageId;
    if (search) {
      where.OR = [
        { title: { contains: search, mode: Prisma.QueryMode.insensitive } },
        { author: { contains: search, mode: Prisma.QueryMode.insensitive } },
      ];
    }

    const [items, total] = await Promise.all([
      this.prisma.book.findMany({ where, skip, take: limit, orderBy: { createdAt: 'desc' } }),
      this.prisma.book.count({ where }),
    ]);

    return { items, total, page, limit, totalPages: Math.ceil(total / limit) };
  }

  async findOne(id: string) {
    const book = await this.prisma.book.findUnique({ where: { id } });
    if (!book) throw new NotFoundException('Book not found.');
    return book;
  }

  async update(id: string, dto: UpdateBookDto) {
    const existing = await this.findOne(id);

    // Only re-extract when the file actually changed — re-parsing on every
    // metadata-only edit (title, description, ...) would be wasted work.
    const fileUrl = dto.fileUrl ?? existing.fileUrl;
    const fileType = dto.fileType ?? existing.fileType;
    const fileChanged = dto.fileUrl != null && dto.fileUrl !== existing.fileUrl;
    const content = fileChanged
      ? await extractBookText(fileUrl, fileType)
      : undefined;

    return this.prisma.book.update({
      where: { id },
      data: content !== undefined ? { ...dto, content } : dto,
    });
  }

  async remove(id: string) {
    await this.findOne(id);
    return this.prisma.book.delete({ where: { id } });
  }

  /// Re-runs text extraction for a book whose content is missing or stale
  /// (e.g. extraction failed at upload time, or the extractor improved
  /// since) without needing to re-upload the file.
  async reextract(id: string) {
    const book = await this.findOne(id);
    const content = await extractBookText(book.fileUrl, book.fileType);
    return this.prisma.book.update({ where: { id }, data: { content } });
  }

  /// Extracts content for every book that doesn't have it yet — covers
  /// books uploaded before this feature existed. Safe to call repeatedly;
  /// already-extracted books are left untouched.
  async backfillContent() {
    const pending = await this.prisma.book.findMany({
      where: { content: null },
      select: { id: true, fileUrl: true, fileType: true },
    });

    let extracted = 0;
    for (const book of pending) {
      const content = await extractBookText(book.fileUrl, book.fileType);
      if (content) {
        await this.prisma.book.update({ where: { id: book.id }, data: { content } });
        extracted++;
      }
    }

    return { checked: pending.length, extracted };
  }
}
