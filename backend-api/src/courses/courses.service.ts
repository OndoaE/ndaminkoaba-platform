import {
  BadRequestException,
  Injectable,
  NotFoundException,
} from '@nestjs/common';
import { CourseStatus, LessonStatus, Prisma } from '@prisma/client';

import { PrismaService } from '../prisma/prisma.service';
import { BulkStatusCourseDto } from './dto/bulk-status-course.dto';
import { CreateCourseDto } from './dto/create-course.dto/create-course.dto';
import { QueryCourseDto } from './dto/query-course.dto/query-course.dto';
import { UpdateCourseDto } from './dto/update-course.dto/update-course.dto';

@Injectable()
export class CoursesService {
  constructor(private readonly prisma: PrismaService) {}

  async create(dto: CreateCourseDto) {
    const language = await this.prisma.language.findUnique({
      where: { id: dto.languageId },
    });

    if (!language) {
      throw new BadRequestException('Invalid languageId.');
    }

    if (dto.teacherId) {
      const teacher = await this.prisma.user.findUnique({
        where: { id: dto.teacherId },
      });

      if (!teacher) {
        throw new BadRequestException('Invalid teacherId.');
      }
    }

    return this.prisma.course.create({
      data: {
        ...dto,
        status: dto.status ?? CourseStatus.DRAFT,
      },
      include: {
        language: true,
        teacher: true,
      },
    });
  }

  async findAll(query: QueryCourseDto) {
    const {
      page = 1,
      limit = 10,
      search,
      level,
      status,
      languageId,
      teacherId,
    } = query;

    const skip = (page - 1) * limit;

    const where: Prisma.CourseWhereInput = {};

    if (search) {
      where.OR = [
        {
          title: {
            contains: search,
            mode: Prisma.QueryMode.insensitive,
          },
        },
        {
          description: {
            contains: search,
            mode: Prisma.QueryMode.insensitive,
          },
        },
      ];
    }

    if (level) where.level = level;
    if (status) where.status = status;
    if (languageId) where.languageId = languageId;
    if (teacherId) where.teacherId = teacherId;

    const [courses, total] = await Promise.all([
      this.prisma.course.findMany({
        where,
        skip,
        take: limit,
        orderBy: { createdAt: 'desc' },
        include: {
          language: true,
          teacher: {
            select: {
              id: true,
              fullName: true,
              email: true,
              role: true,
            },
          },
          reviewer: {
            select: {
              id: true,
              fullName: true,
            },
          },
          modules: {
            include: {
              lessons: true,
            },
          },
        },
      }),
      this.prisma.course.count({ where }),
    ]);

    return {
      items: courses,
      total,
      page,
      limit,
      totalPages: Math.ceil(total / limit),
    };
  }

  async findOne(id: string) {
    const course = await this.prisma.course.findUnique({
      where: { id },
      include: {
        language: true,
        teacher: {
          select: {
            id: true,
            fullName: true,
            email: true,
            role: true,
          },
        },
        reviewer: {
          select: {
            id: true,
            fullName: true,
          },
        },
        modules: {
          include: {
            lessons: true,
          },
          orderBy: {
            orderNumber: 'asc',
          },
        },
      },
    });

    if (!course) {
      throw new NotFoundException('Course not found.');
    }

    return course;
  }

  async update(id: string, dto: UpdateCourseDto) {
    await this.findOne(id);

    return this.prisma.course.update({
      where: { id },
      data: dto,
      include: {
        language: true,
        teacher: true,
      },
    });
  }

  async remove(id: string) {
    await this.findOne(id);

    return this.prisma.course.delete({
      where: { id },
    });
  }

  // Silently skips ids that don't exist or don't match — a stale checkbox
  // selection in the admin UI shouldn't fail the whole bulk action.
  async bulkSetStatus(dto: BulkStatusCourseDto) {
    const result = await this.prisma.course.updateMany({
      where: { id: { in: dto.ids } },
      data: { status: dto.status },
    });

    return { updated: result.count };
  }

  // Computed on demand, not stored — a course's readiness changes whenever
  // any of its lessons change, so persisting a stale percentage would be
  // more misleading than useful.
  async getReadiness(courseId: string) {
    const course = await this.prisma.course.findUnique({
      where: { id: courseId },
      include: {
        modules: {
          include: {
            lessons: {
              include: { quizzes: true },
            },
          },
        },
      },
    });

    if (!course) {
      throw new NotFoundException('Course not found.');
    }

    const lessons = course.modules.flatMap((moduleItem) => moduleItem.lessons);
    const lessonsTotalCount = lessons.length;
    const lessonsReadyCount = lessons.filter(
      (lesson) =>
        lesson.status === LessonStatus.APPROVED ||
        lesson.status === LessonStatus.PUBLISHED,
    ).length;
    const lessonsMissingAudioCount = lessons.filter(
      (lesson) => !lesson.audioUrl,
    ).length;
    const assessmentComplete = lessons.some(
      (lesson) => lesson.quizzes.length > 0,
    );
    const courseDetailsComplete = Boolean(
      course.title && course.description && course.level && course.category,
    );

    const lessonsReadyRatio =
      lessonsTotalCount > 0 ? lessonsReadyCount / lessonsTotalCount : 0;
    const audioReadyRatio =
      lessonsTotalCount > 0
        ? (lessonsTotalCount - lessonsMissingAudioCount) / lessonsTotalCount
        : 0;

    const completionPercent = Math.round(
      (((courseDetailsComplete ? 1 : 0) +
        lessonsReadyRatio +
        audioReadyRatio +
        (assessmentComplete ? 1 : 0)) /
        4) *
        100,
    );

    return {
      completionPercent,
      courseDetailsComplete,
      lessonsReadyCount,
      lessonsTotalCount,
      lessonsMissingAudioCount,
      assessmentComplete,
    };
  }
}