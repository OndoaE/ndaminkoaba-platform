import {
  BadRequestException,
  ForbiddenException,
  Injectable,
  NotFoundException,
} from '@nestjs/common';
import { EnrollmentStatus, Prisma, UserRole } from '@prisma/client';

import { PrismaService } from '../prisma/prisma.service';
import { ICurrentUser } from '../common/interfaces/current-user.interface';
import { CreateProgressDto } from './dto/create-progress.dto/create-progress.dto';
import { QueryProgressDto } from './dto/query-progress.dto/query-progress.dto';
import { UpdateProgressDto } from './dto/update-progress.dto/update-progress.dto';

@Injectable()
export class ProgressService {
  constructor(private readonly prisma: PrismaService) {}

  private async updateEnrollmentProgress(userId: string, lessonId: string) {
    const lesson = await this.prisma.lesson.findUnique({
      where: { id: lessonId },
      include: {
        module: {
          include: {
            course: {
              include: {
                modules: {
                  include: {
                    lessons: true,
                  },
                },
              },
            },
          },
        },
      },
    });

    if (!lesson) return;

    const course = lesson.module.course;

    const lessonIds = course.modules.flatMap((module) =>
      module.lessons.map((lesson) => lesson.id),
    );

    if (lessonIds.length === 0) return;

    const completedLessons = await this.prisma.progress.count({
      where: {
        userId,
        lessonId: {
          in: lessonIds,
        },
        completed: true,
      },
    });

    const progress = Math.round((completedLessons / lessonIds.length) * 100);

    await this.prisma.enrollment.updateMany({
      where: {
        userId,
        courseId: course.id,
      },
      data: {
        progress,
        status:
          progress === 100
            ? EnrollmentStatus.COMPLETED
            : EnrollmentStatus.ACTIVE,
        completedAt: progress === 100 ? new Date() : null,
      },
    });
  }

  async create(dto: CreateProgressDto) {
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

    const progress = await this.prisma.progress.upsert({
      where: {
        userId_lessonId: {
          userId: dto.userId,
          lessonId: dto.lessonId,
        },
      },
      update: {
        score: dto.score,
        attempts: dto.attempts,
        completed: dto.completed ?? false,
        completedAt: dto.completed ? new Date() : dto.completedAt,
      },
      create: {
        userId: dto.userId,
        lessonId: dto.lessonId,
        score: dto.score,
        attempts: dto.attempts ?? 0,
        completed: dto.completed ?? false,
        completedAt: dto.completed ? new Date() : dto.completedAt,
      },
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

    await this.updateEnrollmentProgress(dto.userId, dto.lessonId);

    return progress;
  }

  async findAll(query: QueryProgressDto) {
    const { page = 1, limit = 10, userId, lessonId } = query;
    const skip = (page - 1) * limit;

    const where: Prisma.ProgressWhereInput = {};

    if (userId) where.userId = userId;
    if (lessonId) where.lessonId = lessonId;

    const [progress, total] = await Promise.all([
      this.prisma.progress.findMany({
        where,
        skip,
        take: limit,
        orderBy: { updatedAt: 'desc' },
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
      this.prisma.progress.count({ where }),
    ]);

    return {
      items: progress,
      total,
      page,
      limit,
      totalPages: Math.ceil(total / limit),
    };
  }

  async findOne(id: string) {
    const progress = await this.prisma.progress.findUnique({
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

    if (!progress) {
      throw new NotFoundException('Progress record not found.');
    }

    return progress;
  }

  async update(id: string, dto: UpdateProgressDto) {
    const existingProgress = await this.findOne(id);

    const progress = await this.prisma.progress.update({
      where: { id },
      data: {
        ...dto,
        completedAt: dto.completed ? new Date() : dto.completedAt,
      },
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

    await this.updateEnrollmentProgress(
      progress.userId,
      existingProgress.lessonId,
    );

    return progress;
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
    const progress = await this.findOne(id);
    this.assertOwnerOrStaff(progress, currentUser);
    return progress;
  }

  async updateForUser(
    id: string,
    dto: UpdateProgressDto,
    currentUser: ICurrentUser,
  ) {
    const existing = await this.findOne(id);
    this.assertOwnerOrStaff(existing, currentUser);
    return this.update(id, dto);
  }

  async remove(id: string) {
    const existingProgress = await this.findOne(id);

    const deleted = await this.prisma.progress.delete({
      where: { id },
    });

    await this.updateEnrollmentProgress(
      existingProgress.userId,
      existingProgress.lessonId,
    );

    return deleted;
  }
}