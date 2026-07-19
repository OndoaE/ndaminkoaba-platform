import {
  ConflictException,
  Injectable,
  NotFoundException,
} from '@nestjs/common';
import { Prisma } from '@prisma/client';

import { PrismaService } from '../prisma/prisma.service';
import { CreateLanguageDto } from './dto/create-language.dto/create-language.dto';
import { UpdateLanguageDto } from './dto/update-language.dto/update-language.dto';
import { QueryLanguageDto } from './dto/query-language.dto/query-language.dto';

@Injectable()
export class LanguagesService {
  constructor(private readonly prisma: PrismaService) {}

  async create(dto: CreateLanguageDto) {
    const exists = await this.prisma.language.findUnique({
      where: { code: dto.code },
    });

    if (exists) {
      throw new ConflictException('Language code already exists.');
    }

    return this.prisma.language.create({
      data: dto,
    });
  }

  async findAll(query: QueryLanguageDto) {
    const { page = 1, limit = 10, search, isActive } = query;
    const skip = (page - 1) * limit;

    const where: Prisma.LanguageWhereInput = {};

    if (isActive !== undefined) where.isActive = isActive;

    if (search) {
      where.OR = [
        {
          name: {
            contains: search,
            mode: Prisma.QueryMode.insensitive,
          },
        },
        {
          code: {
            contains: search,
            mode: Prisma.QueryMode.insensitive,
          },
        },
      ];
    }

    const [languages, total] = await Promise.all([
      this.prisma.language.findMany({
        where,
        skip,
        take: limit,
        orderBy: { name: 'asc' },
      }),
      this.prisma.language.count({ where }),
    ]);

    return {
      items: languages,
      total,
      page,
      limit,
      totalPages: Math.ceil(total / limit),
    };
  }

  async findOne(id: string) {
    const language = await this.prisma.language.findUnique({
      where: { id },
    });

    if (!language) {
      throw new NotFoundException('Language not found.');
    }

    return language;
  }

  async update(id: string, dto: UpdateLanguageDto) {
    await this.findOne(id);

    return this.prisma.language.update({
      where: { id },
      data: dto,
    });
  }

  async remove(id: string) {
    await this.findOne(id);

    const courseCount = await this.prisma.course.count({
      where: { languageId: id },
    });

    if (courseCount > 0) {
      throw new ConflictException(
        'Cannot delete a language with existing content — deactivate it instead.',
      );
    }

    return this.prisma.language.delete({
      where: { id },
    });
  }
}