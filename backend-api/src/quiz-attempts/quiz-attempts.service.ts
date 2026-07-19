import {
  BadRequestException,
  ForbiddenException,
  Injectable,
  NotFoundException,
} from '@nestjs/common';
import { Prisma, UserRole } from '@prisma/client';

import { PrismaService } from '../prisma/prisma.service';
import { ICurrentUser } from '../common/interfaces/current-user.interface';
import { CreateQuizAttemptDto } from './dto/create-quiz-attempt.dto/create-quiz-attempt.dto';
import { QueryQuizAttemptDto } from './dto/query-quiz-attempt.dto/query-quiz-attempt.dto';

@Injectable()
export class QuizAttemptsService {
  constructor(private readonly prisma: PrismaService) {}

  async create(dto: CreateQuizAttemptDto) {
    const user = await this.prisma.user.findUnique({
      where: { id: dto.userId },
    });

    if (!user) {
      throw new BadRequestException('Invalid userId.');
    }

    const quiz = await this.prisma.quiz.findUnique({
      where: { id: dto.quizId },
      include: { questions: { include: { choices: true } } },
    });

    if (!quiz) {
      throw new BadRequestException('Invalid quizId.');
    }

    if (quiz.questions.length === 0) {
      throw new BadRequestException('This quiz has no questions.');
    }

    // Score is always computed server-side from the real answer key — a
    // client can never submit its own score or pass/fail flag.
    const results = quiz.questions.map((question) => {
      const answer = dto.answers.find((a) => a.questionId === question.id);
      const selectedChoice = answer
        ? question.choices.find((c) => c.id === answer.choiceId)
        : undefined;

      if (answer && !selectedChoice) {
        throw new BadRequestException(
          `Choice ${answer.choiceId} does not belong to question ${question.id}.`,
        );
      }

      return {
        questionId: question.id,
        choiceId: selectedChoice?.id ?? null,
        isCorrect: selectedChoice?.isCorrect ?? false,
      };
    });

    const correctCount = results.filter((r) => r.isCorrect).length;
    const score = Math.round((correctCount / quiz.questions.length) * 100);
    const passed = score >= quiz.passingScore;

    const attempt = await this.prisma.quizAttempt.create({
      data: {
        userId: dto.userId,
        quizId: dto.quizId,
        score,
        passed,
      },
      include: {
        user: {
          select: {
            id: true,
            fullName: true,
            email: true,
            role: true,
          },
        },
        quiz: true,
      },
    });

    return { ...attempt, results };
  }

  async findAll(query: QueryQuizAttemptDto) {
    const { page = 1, limit = 10, userId, quizId } = query;
    const skip = (page - 1) * limit;

    const where: Prisma.QuizAttemptWhereInput = {};

    if (userId) where.userId = userId;
    if (quizId) where.quizId = quizId;

    const [attempts, total] = await Promise.all([
      this.prisma.quizAttempt.findMany({
        where,
        skip,
        take: limit,
        orderBy: { attemptedAt: 'desc' },
        include: {
          user: {
            select: {
              id: true,
              fullName: true,
              email: true,
              role: true,
            },
          },
          quiz: true,
        },
      }),
      this.prisma.quizAttempt.count({ where }),
    ]);

    return {
      items: attempts,
      total,
      page,
      limit,
      totalPages: Math.ceil(total / limit),
    };
  }

  async findOne(id: string) {
    const attempt = await this.prisma.quizAttempt.findUnique({
      where: { id },
      include: {
        user: {
          select: {
            id: true,
            fullName: true,
            email: true,
            role: true,
          },
        },
        quiz: true,
      },
    });

    if (!attempt) {
      throw new NotFoundException('Quiz attempt not found.');
    }

    return attempt;
  }

  async remove(id: string) {
    await this.findOne(id);

    return this.prisma.quizAttempt.delete({
      where: { id },
    });
  }

  async findOneForUser(id: string, currentUser: ICurrentUser) {
    const attempt = await this.findOne(id);

    const isOwner = attempt.userId === currentUser.userId;
    const isStaff =
      currentUser.role === UserRole.ADMIN ||
      currentUser.role === UserRole.TEACHER;

    if (!isOwner && !isStaff) {
      throw new ForbiddenException('You do not have access to this record.');
    }

    return attempt;
  }
}