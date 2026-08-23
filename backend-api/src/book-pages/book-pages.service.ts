import { Injectable, NotFoundException } from '@nestjs/common';

import { PrismaService } from '../prisma/prisma.service';
import { CreateBookPageDto } from './dto/create-book-page.dto';
import { UpdateBookPageDto } from './dto/update-book-page.dto';
import { ReorderBookPagesDto } from './dto/reorder-book-pages.dto';

@Injectable()
export class BookPagesService {
  constructor(private readonly prisma: PrismaService) {}

  findAllForBook(bookId: string) {
    return this.prisma.bookPage.findMany({
      where: { bookId },
      orderBy: { orderNumber: 'asc' },
    });
  }

  async create(dto: CreateBookPageDto) {
    const page = await this.prisma.bookPage.create({ data: dto });
    await this.syncPageCount(dto.bookId);
    return page;
  }

  async findOne(id: string) {
    const page = await this.prisma.bookPage.findUnique({ where: { id } });
    if (!page) throw new NotFoundException('Book page not found.');
    return page;
  }

  async update(id: string, dto: UpdateBookPageDto) {
    await this.findOne(id);
    return this.prisma.bookPage.update({ where: { id }, data: dto });
  }

  async remove(id: string) {
    const page = await this.findOne(id);
    await this.prisma.bookPage.delete({ where: { id } });
    await this.syncPageCount(page.bookId);
    return page;
  }

  /// Bulk-rewrites orderNumber = index+1 for the given id list, matching
  /// LessonBlocksService.reorder's shape — one PATCH from the client
  /// instead of N sequential ones.
  async reorder(dto: ReorderBookPagesDto) {
    await this.prisma.$transaction(
      dto.orderedIds.map((id, index) =>
        this.prisma.bookPage.update({
          where: { id },
          data: { orderNumber: index + 1 },
        }),
      ),
    );
    await this.syncPageCount(dto.bookId);
    return this.findAllForBook(dto.bookId);
  }

  /// Keeps Book.pageCount in sync with the actual page rows for a
  /// pages-mode book — a plain follow-up update, not part of a shared
  /// transaction with the page write itself, since nothing else in the
  /// same request reads pageCount before this runs.
  private async syncPageCount(bookId: string) {
    const pageCount = await this.prisma.bookPage.count({ where: { bookId } });
    await this.prisma.book.update({ where: { id: bookId }, data: { pageCount } });
  }
}
