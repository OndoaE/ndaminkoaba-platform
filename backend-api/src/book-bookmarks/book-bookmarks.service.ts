import {
  BadRequestException,
  ConflictException,
  ForbiddenException,
  Injectable,
  NotFoundException,
} from '@nestjs/common';
import { UserRole } from '@prisma/client';

import { PrismaService } from '../prisma/prisma.service';
import { ICurrentUser } from '../common/interfaces/current-user.interface';
import { CreateBookBookmarkDto } from './dto/create-book-bookmark.dto';
import { QueryBookBookmarkDto } from './dto/query-book-bookmark.dto';

@Injectable()
export class BookBookmarksService {
  constructor(private readonly prisma: PrismaService) {}

  async create(dto: CreateBookBookmarkDto) {
    const user = await this.prisma.user.findUnique({ where: { id: dto.userId } });
    if (!user) {
      throw new BadRequestException('Invalid userId.');
    }

    const book = await this.prisma.book.findUnique({ where: { id: dto.bookId } });
    if (!book) {
      throw new BadRequestException('Invalid bookId.');
    }

    const exists = await this.prisma.bookBookmark.findUnique({
      where: { userId_bookId: { userId: dto.userId, bookId: dto.bookId } },
    });
    if (exists) {
      throw new ConflictException('Book already bookmarked.');
    }

    return this.prisma.bookBookmark.create({
      data: dto,
      include: { book: true },
    });
  }

  async findAll(query: QueryBookBookmarkDto) {
    const { page = 1, limit = 10, userId, bookId } = query;
    const skip = (page - 1) * limit;

    const where = { ...(userId ? { userId } : {}), ...(bookId ? { bookId } : {}) };

    const [items, total] = await Promise.all([
      this.prisma.bookBookmark.findMany({
        where,
        skip,
        take: limit,
        orderBy: { createdAt: 'desc' },
        include: { book: true },
      }),
      this.prisma.bookBookmark.count({ where }),
    ]);

    return { items, total, page, limit, totalPages: Math.ceil(total / limit) };
  }

  async findOne(id: string) {
    const bookmark = await this.prisma.bookBookmark.findUnique({
      where: { id },
      include: { book: true },
    });
    if (!bookmark) {
      throw new NotFoundException('Book bookmark not found.');
    }
    return bookmark;
  }

  async remove(id: string) {
    await this.findOne(id);
    return this.prisma.bookBookmark.delete({ where: { id } });
  }

  private assertOwnerOrStaff(record: { userId: string }, currentUser: ICurrentUser) {
    const isOwner = record.userId === currentUser.userId;
    const isStaff = currentUser.role === UserRole.ADMIN || currentUser.role === UserRole.TEACHER;
    if (!isOwner && !isStaff) {
      throw new ForbiddenException('You do not have access to this record.');
    }
  }

  async removeForUser(id: string, currentUser: ICurrentUser) {
    const bookmark = await this.findOne(id);
    this.assertOwnerOrStaff(bookmark, currentUser);
    return this.remove(id);
  }
}
