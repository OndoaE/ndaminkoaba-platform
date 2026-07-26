import { Injectable, NotFoundException } from '@nestjs/common';

import { PrismaService } from '../prisma/prisma.service';
import { CreateLessonCommentDto } from './dto/create-lesson-comment.dto';

@Injectable()
export class LessonCommentsService {
  constructor(private readonly prisma: PrismaService) {}

  async findAllForLesson(lessonId: string) {
    return this.prisma.lessonComment.findMany({
      where: { lessonId },
      orderBy: { createdAt: 'asc' },
      include: {
        author: { select: { id: true, fullName: true, role: true } },
      },
    });
  }

  async create(lessonId: string, authorId: string, dto: CreateLessonCommentDto) {
    const lesson = await this.prisma.lesson.findUnique({
      where: { id: lessonId },
    });

    if (!lesson) {
      throw new NotFoundException('Lesson not found.');
    }

    return this.prisma.lessonComment.create({
      data: { lessonId, authorId, text: dto.text },
      include: {
        author: { select: { id: true, fullName: true, role: true } },
      },
    });
  }

  async remove(id: string) {
    const comment = await this.prisma.lessonComment.findUnique({
      where: { id },
    });

    if (!comment) {
      throw new NotFoundException('Comment not found.');
    }

    return this.prisma.lessonComment.delete({ where: { id } });
  }
}
