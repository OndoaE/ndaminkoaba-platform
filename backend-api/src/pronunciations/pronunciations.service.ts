import {
  BadRequestException,
  Injectable,
  NotFoundException,
} from '@nestjs/common';
import { Prisma } from '@prisma/client';

import { PrismaService } from '../prisma/prisma.service';
import { CreatePronunciationDto } from './dto/create-pronunciation.dto/create-pronunciation.dto';
import { QueryPronunciationDto } from './dto/query-pronunciation.dto/query-pronunciation.dto';
import { UpdatePronunciationDto } from './dto/update-pronunciation.dto/update-pronunciation.dto';

@Injectable()
export class PronunciationsService {
  constructor(private readonly prisma: PrismaService) {}

  async create(dto: CreatePronunciationDto) {
    const vocabulary = await this.prisma.vocabulary.findUnique({
      where: { id: dto.vocabularyId },
    });

    if (!vocabulary) {
      throw new BadRequestException('Invalid vocabularyId.');
    }

    return this.prisma.pronunciation.create({
      data: dto,
      include: {
        vocabulary: true,
      },
    });
  }

  async findAll(query: QueryPronunciationDto) {
    const { page = 1, limit = 10, vocabularyId, dialect } = query;
    const skip = (page - 1) * limit;

    const where: Prisma.PronunciationWhereInput = {};

    if (vocabularyId) where.vocabularyId = vocabularyId;
    if (dialect) {
      where.dialect = {
        contains: dialect,
        mode: Prisma.QueryMode.insensitive,
      };
    }

    const [pronunciations, total] = await Promise.all([
      this.prisma.pronunciation.findMany({
        where,
        skip,
        take: limit,
        orderBy: { createdAt: 'desc' },
        include: {
          vocabulary: true,
        },
      }),
      this.prisma.pronunciation.count({ where }),
    ]);

    return {
      items: pronunciations,
      total,
      page,
      limit,
      totalPages: Math.ceil(total / limit),
    };
  }

  async findOne(id: string) {
    const pronunciation = await this.prisma.pronunciation.findUnique({
      where: { id },
      include: {
        vocabulary: true,
      },
    });

    if (!pronunciation) {
      throw new NotFoundException('Pronunciation not found.');
    }

    return pronunciation;
  }

  async update(id: string, dto: UpdatePronunciationDto) {
    await this.findOne(id);

    return this.prisma.pronunciation.update({
      where: { id },
      data: dto,
      include: {
        vocabulary: true,
      },
    });
  }

  async remove(id: string) {
    await this.findOne(id);

    return this.prisma.pronunciation.delete({
      where: { id },
    });
  }
}