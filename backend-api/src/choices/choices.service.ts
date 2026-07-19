import {
  BadRequestException,
  Injectable,
  NotFoundException,
} from '@nestjs/common';
import { Prisma } from '@prisma/client';

import { PrismaService } from '../prisma/prisma.service';
import { CreateChoiceDto } from './dto/create-choice.dto/create-choice.dto';
import { QueryChoiceDto } from './dto/query-choice.dto/query-choice.dto';
import { UpdateChoiceDto } from './dto/update-choice.dto/update-choice.dto';

@Injectable()
export class ChoicesService {
  constructor(private readonly prisma: PrismaService) {}

  async create(dto: CreateChoiceDto) {
    const question = await this.prisma.question.findUnique({
      where: { id: dto.questionId },
    });

    if (!question) {
      throw new BadRequestException('Invalid questionId.');
    }

    return this.prisma.choice.create({
      data: dto,
      include: {
        question: true,
      },
    });
  }

  async findAll(query: QueryChoiceDto) {
    const { page = 1, limit = 10, questionId } = query;
    const skip = (page - 1) * limit;

    const where: Prisma.ChoiceWhereInput = {};

    if (questionId) {
      where.questionId = questionId;
    }

    const [choices, total] = await Promise.all([
      this.prisma.choice.findMany({
        where,
        skip,
        take: limit,
        orderBy: {
          choiceText: 'asc',
        },
        include: {
          question: true,
        },
      }),
      this.prisma.choice.count({ where }),
    ]);

    return {
      items: choices,
      total,
      page,
      limit,
      totalPages: Math.ceil(total / limit),
    };
  }

  async findOne(id: string) {
    const choice = await this.prisma.choice.findUnique({
      where: { id },
      include: {
        question: true,
      },
    });

    if (!choice) {
      throw new NotFoundException('Choice not found.');
    }

    return choice;
  }

  async update(id: string, dto: UpdateChoiceDto) {
    await this.findOne(id);

    return this.prisma.choice.update({
      where: { id },
      data: dto,
      include: {
        question: true,
      },
    });
  }

  async remove(id: string) {
    await this.findOne(id);

    return this.prisma.choice.delete({
      where: { id },
    });
  }
}