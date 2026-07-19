import {
  BadRequestException,
  Injectable,
  NotFoundException,
} from '@nestjs/common';
import { Prisma, QuestionType } from '@prisma/client';

import { PrismaService } from '../prisma/prisma.service';
import { CreateQuestionDto } from './dto/create-question.dto/create-question.dto';
import { QueryQuestionDto } from './dto/query-question.dto/query-question.dto';
import { UpdateQuestionDto } from './dto/update-question.dto/update-question.dto';

@Injectable()
export class QuestionsService {
  constructor(private readonly prisma: PrismaService) {}

  async create(dto: CreateQuestionDto) {
    const quiz = await this.prisma.quiz.findUnique({
      where: { id: dto.quizId },
    });

    if (!quiz) {
      throw new BadRequestException('Invalid quizId.');
    }

    return this.prisma.question.create({
      data: {
        ...dto,
        type: dto.type ?? QuestionType.MULTIPLE_CHOICE,
      },
      include: {
        quiz: true,
        choices: true,
      },
    });
  }

  async findAll(query: QueryQuestionDto) {
    const { page = 1, limit = 10, search, quizId } = query;
    const skip = (page - 1) * limit;

    const where: Prisma.QuestionWhereInput = {};

    if (search) {
      where.questionText = {
        contains: search,
        mode: Prisma.QueryMode.insensitive,
      };
    }

    if (quizId) where.quizId = quizId;

    const [questions, total] = await Promise.all([
      this.prisma.question.findMany({
        where,
        skip,
        take: limit,
        orderBy: { createdAt: 'desc' },
        include: {
          quiz: true,
          choices: true,
        },
      }),
      this.prisma.question.count({ where }),
    ]);

    return {
      items: questions,
      total,
      page,
      limit,
      totalPages: Math.ceil(total / limit),
    };
  }

  async findOne(id: string) {
    const question = await this.prisma.question.findUnique({
      where: { id },
      include: {
        quiz: true,
        choices: true,
      },
    });

    if (!question) {
      throw new NotFoundException('Question not found.');
    }

    return question;
  }

  async update(id: string, dto: UpdateQuestionDto) {
    await this.findOne(id);

    return this.prisma.question.update({
      where: { id },
      data: dto,
      include: {
        quiz: true,
        choices: true,
      },
    });
  }

  async remove(id: string) {
    await this.findOne(id);

    return this.prisma.question.delete({
      where: { id },
    });
  }
}