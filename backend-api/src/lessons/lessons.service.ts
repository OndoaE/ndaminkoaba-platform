import {
  BadRequestException,
  Injectable,
  NotFoundException,
} from '@nestjs/common';
import { Prisma } from '@prisma/client';

import { PrismaService } from '../prisma/prisma.service';
import { CreateLessonDto } from './dto/create-lesson.dto/create-lesson.dto';
import { QueryLessonDto } from './dto/query-lesson.dto/query-lesson.dto';
import { UpdateLessonDto } from './dto/update-lesson.dto/update-lesson.dto';

@Injectable()
export class LessonsService {
  constructor(private readonly prisma: PrismaService) {}

  async create(dto: CreateLessonDto) {
    const module = await this.prisma.courseModule.findUnique({
      where: { id: dto.moduleId },
    });

    if (!module) {
      throw new BadRequestException('Invalid moduleId.');
    }

    return this.prisma.lesson.create({
      data: dto,
      include: {
        module: { include: { course: true } },
      },
    });
  }

  async findAll(query: QueryLessonDto) {
    const { page = 1, limit = 10, search, moduleId, languageId } = query;
    const skip = (page - 1) * limit;

    const where: Prisma.LessonWhereInput = {};

    if (search) {
      where.OR = [
        {
          title: {
            contains: search,
            mode: Prisma.QueryMode.insensitive,
          },
        },
        {
          summary: {
            contains: search,
            mode: Prisma.QueryMode.insensitive,
          },
        },
      ];
    }

    if (moduleId) {
      where.moduleId = moduleId;
    }

    if (languageId) {
      where.module = { course: { languageId } };
    }

    const [lessons, total] = await Promise.all([
      this.prisma.lesson.findMany({
        where,
        skip,
        take: limit,
        orderBy: {
          orderNumber: 'asc',
        },
        include: {
          module: { include: { course: true } },
          vocabulary: true,
          quizzes: true,
        },
      }),
      this.prisma.lesson.count({ where }),
    ]);

    return {
      items: lessons,
      total,
      page,
      limit,
      totalPages: Math.ceil(total / limit),
    };
  }

  async findOne(id: string) {
    const lesson = await this.prisma.lesson.findUnique({
      where: { id },
      include: {
        module: { include: { course: true } },
        vocabulary: true,
        quizzes: true,
      },
    });

    if (!lesson) {
      throw new NotFoundException('Lesson not found.');
    }

    return lesson;
  }

  async update(id: string, dto: UpdateLessonDto) {
    await this.findOne(id);

    return this.prisma.lesson.update({
      where: { id },
      data: dto,
      include: {
        module: { include: { course: true } },
      },
    });
  }

  async remove(id: string) {
    await this.findOne(id);

    return this.prisma.lesson.delete({
      where: { id },
    });
  }
}