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

  /// Reading a lesson's blocks materializes any legacy flat content
  /// (content/frenchContent/conversationJson/audioUrl/videoUrl, authored
  /// before the block editor existed) into real blocks, so the Content tab
  /// shows what the lesson actually has instead of appearing empty.
  /// Checked per block-type rather than "any block exists" — a lesson can
  /// already have e.g. an EXERCISE or IMAGE block an admin added while
  /// exploring the editor, with its original TEXT content never migrated;
  /// gating on "any block exists" would skip that lesson forever. Once a
  /// given type exists it's never re-created, so this is safe to run on
  /// every read. Non-destructive: the flat fields are read, never cleared,
  /// and stay in sync afterward via deriveAndPersist on every block save.
  async findAllForLesson(lessonId: string) {
    const existing = await this.prisma.lessonBlock.findMany({
      where: { lessonId },
      orderBy: { orderNumber: 'asc' },
    });

    const lesson = await this.prisma.lesson.findUnique({ where: { id: lessonId } });
    if (!lesson) return existing;

    const hasType = (type: LessonBlockType) => existing.some((b) => b.type === type);
    const toCreate: Prisma.LessonBlockCreateManyInput[] = [];
    let orderNumber =
      existing.length > 0 ? Math.max(...existing.map((b) => b.orderNumber)) + 1 : 1;

    if (!hasType(LessonBlockType.TEXT) && lesson.content?.trim()) {
      toCreate.push({
        lessonId,
        orderNumber: orderNumber++,
        type: LessonBlockType.TEXT,
        textContent: lesson.content,
        frenchTextContent: lesson.frenchContent?.trim() ? lesson.frenchContent : null,
      });
    }

    if (
      !hasType(LessonBlockType.DIALOGUE) &&
      Array.isArray(lesson.conversationJson) &&
      (lesson.conversationJson as unknown[]).length > 0
    ) {
      toCreate.push({
        lessonId,
        orderNumber: orderNumber++,
        type: LessonBlockType.DIALOGUE,
        dialogueJson: lesson.conversationJson as Prisma.InputJsonValue,
      });
    }

    if (!hasType(LessonBlockType.AUDIO) && lesson.audioUrl) {
      toCreate.push({
        lessonId,
        orderNumber: orderNumber++,
        type: LessonBlockType.AUDIO,
        mediaUrl: lesson.audioUrl,
      });
    }

    if (!hasType(LessonBlockType.VIDEO) && lesson.videoUrl) {
      toCreate.push({
        lessonId,
        orderNumber: orderNumber++,
        type: LessonBlockType.VIDEO,
        mediaUrl: lesson.videoUrl,
      });
    }

    if (toCreate.length === 0) return existing;

    await this.prisma.lessonBlock.createMany({ data: toCreate });
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
