import { Injectable, NotFoundException } from '@nestjs/common';
import { Prisma } from '@prisma/client';

import { PrismaService } from '../prisma/prisma.service';
import { CreateKnowledgeTextDto } from './dto/create-knowledge-text.dto/create-knowledge-text.dto';
import { QueryKnowledgeTextDto } from './dto/query-knowledge-text.dto/query-knowledge-text.dto';
import { UpdateKnowledgeTextDto } from './dto/update-knowledge-text.dto/update-knowledge-text.dto';

@Injectable()
export class KnowledgeTextsService {
  constructor(private readonly prisma: PrismaService) {}

  create(dto: CreateKnowledgeTextDto) {
    return this.prisma.knowledgeText.create({ data: dto });
  }

  async findAll(query: QueryKnowledgeTextDto) {
    const { page = 1, limit = 10, search, languageId } = query;
    const skip = (page - 1) * limit;

    const where: Prisma.KnowledgeTextWhereInput = {};

    if (languageId) where.languageId = languageId;
    if (search) {
      where.OR = [
        { text: { contains: search, mode: Prisma.QueryMode.insensitive } },
        { translation: { contains: search, mode: Prisma.QueryMode.insensitive } },
      ];
    }

    const [items, total] = await Promise.all([
      this.prisma.knowledgeText.findMany({
        where,
        skip,
        take: limit,
        orderBy: { createdAt: 'desc' },
      }),
      this.prisma.knowledgeText.count({ where }),
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
    const text = await this.prisma.knowledgeText.findUnique({ where: { id } });

    if (!text) {
      throw new NotFoundException('Knowledge text not found.');
    }

    return text;
  }

  async update(id: string, dto: UpdateKnowledgeTextDto) {
    await this.findOne(id);

    return this.prisma.knowledgeText.update({ where: { id }, data: dto });
  }

  async remove(id: string) {
    await this.findOne(id);

    return this.prisma.knowledgeText.delete({ where: { id } });
  }
}
