import {
  BadRequestException,
  Injectable,
  NotFoundException,
} from '@nestjs/common';
import { LessonBlockType, Prisma } from '@prisma/client';

import { PrismaService } from '../prisma/prisma.service';
import { CreateLessonBlockDto } from './dto/create-lesson-block.dto';
import { ReorderLessonBlocksDto } from './dto/reorder-lesson-blocks.dto';
import { UpdateLessonBlockDto } from './dto/update-lesson-block.dto';

type Tx = Prisma.TransactionClient;

/**
 * Lesson blocks are the Lesson Editor's AUTHORING structure only — they are
 * not what the learner app renders from. Every mutation here (block
 * create/update/delete/reorder) runs inside ONE transaction together with
 * deriveAndPersist(), which regenerates Lesson.content/frenchContent/
 * conversationJson/audioUrl and upserts LessonImage rows from the current
 * block list. Both the block write and the derivation must share a
 * transaction — if the block write committed on its own and the derivation
 * failed afterwards, the invalid block would be left in the database as a
 * "poison pill" that re-fails derivation on every subsequent save for that
 * lesson. Lessons with zero blocks (everything authored the old way) are
 * never touched by this — the learner-facing lesson screen keeps rendering
 * their original fields unchanged.
 */
@Injectable()
export class LessonBlocksService {
  constructor(private readonly prisma: PrismaService) {}

  async findAllForLesson(lessonId: string) {
    return this.prisma.lessonBlock.findMany({
      where: { lessonId },
      orderBy: { orderNumber: 'asc' },
    });
  }

  async create(dto: CreateLessonBlockDto) {
    const lesson = await this.prisma.lesson.findUnique({
      where: { id: dto.lessonId },
    });

    if (!lesson) {
      throw new BadRequestException('Invalid lessonId.');
    }

    await this.validateReferences(dto);

    return this.prisma.$transaction(async (tx) => {
      await tx.lessonBlock.create({ data: dto });
      return this.deriveAndPersist(tx, dto.lessonId);
    });
  }

  async update(id: string, dto: UpdateLessonBlockDto) {
    const block = await this.prisma.lessonBlock.findUnique({ where: { id } });

    if (!block) {
      throw new NotFoundException('Lesson block not found.');
    }

    await this.validateReferences(dto);

    return this.prisma.$transaction(async (tx) => {
      await tx.lessonBlock.update({ where: { id }, data: dto });
      return this.deriveAndPersist(tx, block.lessonId);
    });
  }

  async remove(id: string) {
    const block = await this.prisma.lessonBlock.findUnique({ where: { id } });

    if (!block) {
      throw new NotFoundException('Lesson block not found.');
    }

    return this.prisma.$transaction(async (tx) => {
      await tx.lessonBlock.delete({ where: { id } });
      return this.deriveAndPersist(tx, block.lessonId);
    });
  }

  async reorder(dto: ReorderLessonBlocksDto) {
    return this.prisma.$transaction(async (tx) => {
      for (const [index, id] of dto.orderedIds.entries()) {
        await tx.lessonBlock.update({
          where: { id },
          data: { orderNumber: index + 1 },
        });
      }
      return this.deriveAndPersist(tx, dto.lessonId);
    });
  }

  private async validateReferences(
    dto: CreateLessonBlockDto | UpdateLessonBlockDto,
  ) {
    if (dto.vocabularyId) {
      const vocabulary = await this.prisma.vocabulary.findUnique({
        where: { id: dto.vocabularyId },
      });
      if (!vocabulary) {
        throw new BadRequestException('Invalid vocabularyId.');
      }
    }

    if (dto.quizId) {
      const quiz = await this.prisma.quiz.findUnique({
        where: { id: dto.quizId },
      });
      if (!quiz) {
        throw new BadRequestException('Invalid quizId.');
      }
    }
  }

  private async deriveAndPersist(tx: Tx, lessonId: string) {
    const blocks = await tx.lessonBlock.findMany({
      where: { lessonId },
      orderBy: { orderNumber: 'asc' },
    });

    const textBlocks = blocks.filter((b) => b.type === LessonBlockType.TEXT);
    const dialogueBlock = blocks.find(
      (b) => b.type === LessonBlockType.DIALOGUE,
    );
    const audioBlock = blocks.find((b) => b.type === LessonBlockType.AUDIO);
    const videoBlock = blocks.find((b) => b.type === LessonBlockType.VIDEO);
    const imageBlocks = blocks.filter((b) => b.type === LessonBlockType.IMAGE);

    // An IMAGE block without a word label or asset URL can't produce a valid
    // LessonImage row (word is non-nullable) — fail loudly here so the whole
    // transaction (including the block write that triggered this) rolls
    // back, rather than persisting a block the lesson can never derive from.
    for (const block of imageBlocks) {
      if (!block.titleLabel || !block.mediaUrl) {
        throw new BadRequestException(
          `IMAGE block ${block.id} is missing a word label or image URL and cannot be saved.`,
        );
      }
    }

    const lessonUpdate: Prisma.LessonUpdateInput = {};

    if (textBlocks.length > 0) {
      lessonUpdate.content = textBlocks
        .map((b) => b.textContent ?? '')
        .filter((text) => text.length > 0)
        .join('\n\n');
      const frenchText = textBlocks
        .map((b) => b.frenchTextContent ?? '')
        .filter((text) => text.length > 0)
        .join('\n\n');
      if (frenchText.length > 0) {
        lessonUpdate.frenchContent = frenchText;
      }
    }

    if (dialogueBlock?.dialogueJson) {
      lessonUpdate.conversationJson = dialogueBlock.dialogueJson as
        | Prisma.InputJsonValue
        | undefined;
    }

    if (audioBlock?.mediaUrl) {
      lessonUpdate.audioUrl = audioBlock.mediaUrl;
    }

    if (videoBlock?.mediaUrl) {
      lessonUpdate.videoUrl = videoBlock.mediaUrl;
    }

    const lesson = Object.keys(lessonUpdate).length
      ? await tx.lesson.update({ where: { id: lessonId }, data: lessonUpdate })
      : await tx.lesson.findUniqueOrThrow({ where: { id: lessonId } });

    // Upsert by (lessonId, imageUrl) rather than delete-and-recreate, so
    // images added independently via the existing Lesson Images screen are
    // never touched by block derivation.
    for (const [index, block] of imageBlocks.entries()) {
      const existing = await tx.lessonImage.findFirst({
        where: { lessonId, imageUrl: block.mediaUrl! },
      });

      if (existing) {
        await tx.lessonImage.update({
          where: { id: existing.id },
          data: {
            word: block.titleLabel!,
            caption: block.textContent,
            orderNumber: index + 1,
          },
        });
      } else {
        await tx.lessonImage.create({
          data: {
            lessonId,
            imageUrl: block.mediaUrl!,
            word: block.titleLabel!,
            caption: block.textContent,
            orderNumber: index + 1,
          },
        });
      }
    }

    return lesson;
  }
}
