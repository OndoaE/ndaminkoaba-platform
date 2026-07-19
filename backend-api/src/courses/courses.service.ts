import {
  BadRequestException,
  Injectable,
  NotFoundException,
} from '@nestjs/common';
import { CourseStatus, Prisma } from '@prisma/client';

import { PrismaService } from '../prisma/prisma.service';
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
}