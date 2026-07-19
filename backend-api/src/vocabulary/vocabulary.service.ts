import {
  BadRequestException,
  Injectable,
  NotFoundException,
} from '@nestjs/common';
import { Level, Prisma } from '@prisma/client';

import { PrismaService } from '../prisma/prisma.service';
import { CreateVocabularyDto } from './dto/create-vocabulary.dto/create-vocabulary.dto';
import { QueryVocabularyDto } from './dto/query-vocabulary.dto/query-vocabulary.dto';
import { UpdateVocabularyDto } from './dto/update-vocabulary.dto/update-vocabulary.dto';

@Injectable()
export class VocabularyService {
  constructor(private readonly prisma: PrismaService) {}

  async create(dto: CreateVocabularyDto) {
    if (dto.lessonId) {
      const lesson = await this.prisma.lesson.findUnique({
        where: { id: dto.lessonId },
      });

      if (!lesson) {
        throw new BadRequestException('Invalid lessonId.');
      }
    }

    if (dto.categoryId) {
      const category = await this.prisma.category.findUnique({
        where: { id: dto.categoryId },
      });

      if (!category) {
        throw new BadRequestException('Invalid categoryId.');
      }
    }

    const language = await this.prisma.language.findUnique({
      where: { id: dto.languageId },
    });

    if (!language) {
      throw new BadRequestException('Invalid languageId.');
    }

    return this.prisma.vocabulary.create({
      data: {
        ...dto,
        difficulty: dto.difficulty ?? Level.BEGINNER,
      },
      include: {
        lesson: true,
        category: true,
        pronunciations: true,
      },
    });
  }

  async findAll(query: QueryVocabularyDto) {
    const { page = 1, limit = 10, search, difficulty, lessonId, categoryId, languageId } =
      query;

    const skip = (page - 1) * limit;
    const where: Prisma.VocabularyWhereInput = {};

    if (search) {
      where.OR = [
        { word: { contains: search, mode: Prisma.QueryMode.insensitive } },
        { frenchMeaning: { contains: search, mode: Prisma.QueryMode.insensitive } },
        { englishMeaning: { contains: search, mode: Prisma.QueryMode.insensitive } },
      ];
    }

    if (difficulty) where.difficulty = difficulty;
    if (lessonId) where.lessonId = lessonId;
    if (categoryId) where.categoryId = categoryId;
    if (languageId) where.languageId = languageId;

    const [vocabulary, total] = await Promise.all([
      this.prisma.vocabulary.findMany({
        where,
        skip,
        take: limit,
        orderBy: { createdAt: 'desc' },
        include: {
          lesson: true,
          category: true,
          pronunciations: true,
        },
      }),
      this.prisma.vocabulary.count({ where }),
    ]);

    return {
      items: vocabulary,
      total,
      page,
      limit,
      totalPages: Math.ceil(total / limit),
    };
  }

  async findOne(id: string) {
    const vocabulary = await this.prisma.vocabulary.findUnique({
      where: { id },
      include: {
        lesson: true,
        category: true,
        pronunciations: true,
      },
    });

    if (!vocabulary) {
      throw new NotFoundException('Vocabulary not found.');
    }

    return vocabulary;
  }

  async update(id: string, dto: UpdateVocabularyDto) {
    await this.findOne(id);

    return this.prisma.vocabulary.update({
      where: { id },
      data: dto,
      include: {
        lesson: true,
        category: true,
        pronunciations: true,
      },
    });
  }

  async remove(id: string) {
    await this.findOne(id);

    return this.prisma.vocabulary.delete({
      where: { id },
    });
  }
}