import { Injectable, NotFoundException } from '@nestjs/common';
import { Prisma } from '@prisma/client';

import { PrismaService } from '../prisma/prisma.service';
import { CreateBookDto } from './dto/create-book.dto';
import { UpdateBookDto } from './dto/update-book.dto';
import { QueryBookDto } from './dto/query-book.dto';

@Injectable()
export class BooksService {
  constructor(private readonly prisma: PrismaService) {}

  create(dto: CreateBookDto) {
    return this.prisma.book.create({ data: dto });
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
    await this.findOne(id);
    return this.prisma.book.update({ where: { id }, data: dto });
  }

  async remove(id: string) {
    await this.findOne(id);
    return this.prisma.book.delete({ where: { id } });
  }
}
