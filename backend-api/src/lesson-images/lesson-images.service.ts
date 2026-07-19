import {
  BadRequestException,
  Injectable,
  NotFoundException,
} from '@nestjs/common';
import { Prisma } from '@prisma/client';

import { PrismaService } from '../prisma/prisma.service';
import { CreateLessonImageDto } from './dto/create-lesson-image.dto/create-lesson-image.dto';
import { QueryLessonImageDto } from './dto/query-lesson-image.dto/query-lesson-image.dto';
import { UpdateLessonImageDto } from './dto/update-lesson-image.dto/update-lesson-image.dto';

@Injectable()
export class LessonImagesService {
  constructor(private readonly prisma: PrismaService) {}

  async create(dto: CreateLessonImageDto) {
    const lesson = await this.prisma.lesson.findUnique({
      where: { id: dto.lessonId },
    });

    if (!lesson) {
      throw new BadRequestException('Invalid lessonId.');
    }

    return this.prisma.lessonImage.create({ data: dto });
  }

  async findAll(query: QueryLessonImageDto) {
    const { page = 1, limit = 10, lessonId } = query;
    const skip = (page - 1) * limit;

    const where: Prisma.LessonImageWhereInput = {};

    if (lessonId) {
      where.lessonId = lessonId;
    }

    const [items, total] = await Promise.all([
      this.prisma.lessonImage.findMany({
        where,
        skip,
        take: limit,
        orderBy: { orderNumber: 'asc' },
      }),
      this.prisma.lessonImage.count({ where }),
    ]);

    return {
      items,
      total,
      page,
      limit,
      totalPages: Math.ceil(total / limit),
    };
  }

  async findOne(id: string) {
    const image = await this.prisma.lessonImage.findUnique({ where: { id } });

    if (!image) {
      throw new NotFoundException('Lesson image not found.');
    }

    return image;
  }

  async update(id: string, dto: UpdateLessonImageDto) {
    await this.findOne(id);

    return this.prisma.lessonImage.update({ where: { id }, data: dto });
  }

  async remove(id: string) {
    await this.findOne(id);

    return this.prisma.lessonImage.delete({ where: { id } });
  }
}
