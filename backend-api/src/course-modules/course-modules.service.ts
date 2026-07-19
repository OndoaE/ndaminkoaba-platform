import {
  BadRequestException,
  Injectable,
  NotFoundException,
} from '@nestjs/common';
import { Prisma } from '@prisma/client';

import { PrismaService } from '../prisma/prisma.service';
import { CreateCourseModuleDto } from './dto/create-course-module.dto/create-course-module.dto';
import { QueryCourseModuleDto } from './dto/query-course-module.dto/query-course-module.dto';
import { UpdateCourseModuleDto } from './dto/update-course-module.dto/update-course-module.dto';

@Injectable()
export class CourseModulesService {
  constructor(private readonly prisma: PrismaService) {}

  async create(dto: CreateCourseModuleDto) {
    const course = await this.prisma.course.findUnique({
      where: { id: dto.courseId },
    });

    if (!course) {
      throw new BadRequestException('Invalid courseId.');
    }

    return this.prisma.courseModule.create({
      data: dto,
      include: {
        course: true,
      },
    });
  }

  async findAll(query: QueryCourseModuleDto) {
    const { page = 1, limit = 10, search, courseId, languageId } = query;
    const skip = (page - 1) * limit;

    const where: Prisma.CourseModuleWhereInput = {};

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

    if (courseId) {
      where.courseId = courseId;
    }

    if (languageId) {
      where.course = { languageId };
    }

    const [modules, total] = await Promise.all([
      this.prisma.courseModule.findMany({
        where,
        skip,
        take: limit,
        orderBy: {
          orderNumber: 'asc',
        },
        include: {
          course: true,
          lessons: true,
        },
      }),
      this.prisma.courseModule.count({ where }),
    ]);

    return {
      items: modules,
      total,
      page,
      limit,
      totalPages: Math.ceil(total / limit),
    };
  }

  async findOne(id: string) {
    const module = await this.prisma.courseModule.findUnique({
      where: { id },
      include: {
        course: true,
        lessons: {
          orderBy: {
            orderNumber: 'asc',
          },
        },
      },
    });

    if (!module) {
      throw new NotFoundException('Course module not found.');
    }

    return module;
  }

  async update(id: string, dto: UpdateCourseModuleDto) {
    await this.findOne(id);

    return this.prisma.courseModule.update({
      where: { id },
      data: dto,
      include: {
        course: true,
      },
    });
  }

  async remove(id: string) {
    await this.findOne(id);

    return this.prisma.courseModule.delete({
      where: { id },
    });
  }
}