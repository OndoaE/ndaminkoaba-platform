import {
  BadRequestException,
  ConflictException,
  ForbiddenException,
  Injectable,
  NotFoundException,
} from '@nestjs/common';
import { Prisma, UserRole } from '@prisma/client';

import { PrismaService } from '../prisma/prisma.service';
import { ICurrentUser } from '../common/interfaces/current-user.interface';
import { CreateBookmarkDto } from './dto/create-bookmark.dto/create-bookmark.dto';
import { QueryBookmarkDto } from './dto/query-bookmark.dto/query-bookmark.dto';

@Injectable()
export class BookmarksService {
  constructor(private readonly prisma: PrismaService) {}

  async create(dto: CreateBookmarkDto) {
    const user = await this.prisma.user.findUnique({
      where: { id: dto.userId },
    });

    if (!user) {
      throw new BadRequestException('Invalid userId.');
    }

    const lesson = await this.prisma.lesson.findUnique({
      where: { id: dto.lessonId },
    });

    if (!lesson) {
      throw new BadRequestException('Invalid lessonId.');
    }

    const exists = await this.prisma.bookmark.findUnique({
      where: {
        userId_lessonId: {
          userId: dto.userId,
          lessonId: dto.lessonId,
        },
      },
    });

    if (exists) {
      throw new ConflictException('Lesson already bookmarked.');
    }

    return this.prisma.bookmark.create({
      data: dto,
      include: {
        user: {
          select: {
            id: true,
            fullName: true,
            email: true,
            role: true,
          },
        },
        lesson: true,
      },
    });
  }

  async findAll(query: QueryBookmarkDto) {
    const { page = 1, limit = 10, userId, lessonId } = query;
    const skip = (page - 1) * limit;

    const where: Prisma.BookmarkWhereInput = {};

    if (userId) where.userId = userId;
    if (lessonId) where.lessonId = lessonId;

    const [bookmarks, total] = await Promise.all([
      this.prisma.bookmark.findMany({
        where,
        skip,
        take: limit,
        orderBy: { createdAt: 'desc' },
        include: {
          user: {
            select: {
              id: true,
              fullName: true,
              email: true,
              role: true,
            },
          },
          lesson: true,
        },
      }),
      this.prisma.bookmark.count({ where }),
    ]);

    return {
      items: bookmarks,
      total,
      page,
      limit,
      totalPages: Math.ceil(total / limit),
    };
  }

  async findOne(id: string) {
    const bookmark = await this.prisma.bookmark.findUnique({
      where: { id },
      include: {
        user: {
          select: {
            id: true,
            fullName: true,
            email: true,
            role: true,
          },
        },
        lesson: true,
      },
    });

    if (!bookmark) {
      throw new NotFoundException('Bookmark not found.');
    }

    return bookmark;
  }

  async remove(id: string) {
    await this.findOne(id);

    return this.prisma.bookmark.delete({
      where: { id },
    });
  }

  private assertOwnerOrStaff(
    record: { userId: string },
    currentUser: ICurrentUser,
  ) {
    const isOwner = record.userId === currentUser.userId;
    const isStaff =
      currentUser.role === UserRole.ADMIN ||
      currentUser.role === UserRole.TEACHER;

    if (!isOwner && !isStaff) {
      throw new ForbiddenException('You do not have access to this record.');
    }
  }

  async findOneForUser(id: string, currentUser: ICurrentUser) {
    const bookmark = await this.findOne(id);
    this.assertOwnerOrStaff(bookmark, currentUser);
    return bookmark;
  }

  async removeForUser(id: string, currentUser: ICurrentUser) {
    const bookmark = await this.findOne(id);
    this.assertOwnerOrStaff(bookmark, currentUser);
    return this.remove(id);
  }
}