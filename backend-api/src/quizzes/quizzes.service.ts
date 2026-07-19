import {
  BadRequestException,
  Injectable,
  NotFoundException,
} from '@nestjs/common';
import { Prisma } from '@prisma/client';

import { PrismaService } from '../prisma/prisma.service';
import { CreateQuizDto } from './dto/create-quiz.dto/create-quiz.dto';
import { QueryQuizDto } from './dto/query-quiz.dto/query-quiz.dto';
import { UpdateQuizDto } from './dto/update-quiz.dto/update-quiz.dto';

@Injectable()
export class QuizzesService {
  constructor(private readonly prisma: PrismaService) {}

  async create(dto: CreateQuizDto) {
    const lesson = await this.prisma.lesson.findUnique({
      where: { id: dto.lessonId },
    });

    if (!lesson) {
      throw new BadRequestException('Invalid lessonId.');
    }

    return this.prisma.quiz.create({
      data: {
        ...dto,
        passingScore: dto.passingScore ?? 80,
      },
      include: {
        lesson: { include: { module: { include: { course: true } } } },
        questions: true,
      },
    });
  }

  async findAll(query: QueryQuizDto) {
    const { page = 1, limit = 10, search, lessonId, languageId } = query;
    const skip = (page - 1) * limit;

    const where: Prisma.QuizWhereInput = {};

    if (search) {
      where.OR = [
        { title: { contains: search, mode: Prisma.QueryMode.insensitive } },
        { description: { contains: search, mode: Prisma.QueryMode.insensitive } },
      ];
    }

    if (lessonId) where.lessonId = lessonId;
    if (languageId) where.lesson = { module: { course: { languageId } } };

    const [quizzes, total] = await Promise.all([
      this.prisma.quiz.findMany({
        where,
        skip,
        take: limit,
        orderBy: { createdAt: 'desc' },
        include: {
          lesson: { include: { module: { include: { course: true } } } },
          questions: {
            include: {
              choices: true,
            },
          },
        },
      }),
      this.prisma.quiz.count({ where }),
    ]);

    return {
      items: quizzes,
      total,
      page,
      limit,
      totalPages: Math.ceil(total / limit),
    };
  }

  async findOne(id: string) {
    const quiz = await this.prisma.quiz.findUnique({
      where: { id },
      include: {
        lesson: { include: { module: { include: { course: true } } } },
        questions: {
          include: {
            choices: true,
          },
        },
      },
    });

    if (!quiz) {
      throw new NotFoundException('Quiz not found.');
    }

    return quiz;
  }

  async update(id: string, dto: UpdateQuizDto) {
    await this.findOne(id);

    return this.prisma.quiz.update({
      where: { id },
      data: dto,
      include: {
        lesson: { include: { module: { include: { course: true } } } },
        questions: true,
      },
    });
  }

  async remove(id: string) {
    await this.findOne(id);

    return this.prisma.quiz.delete({
      where: { id },
    });
  }
}