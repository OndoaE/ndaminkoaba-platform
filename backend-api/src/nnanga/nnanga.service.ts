import {
  BadRequestException,
  ForbiddenException,
  Injectable,
  NotFoundException,
} from '@nestjs/common';
import { PracticeActivityType, Prisma, UserRole } from '@prisma/client';
import { extname, join } from 'path';

import { PrismaService } from '../prisma/prisma.service';
import { KnowledgeService } from '../knowledge/knowledge.service';
import { AiService } from '../ai/ai.service';
import { StreaksService } from '../streaks/streaks.service';
import { ICurrentUser } from '../common/interfaces/current-user.interface';

import { CreateNnangaChatDto } from './dto/create-nnanga-chat.dto/create-nnanga-chat.dto';
import { QueryNnangaChatDto } from './dto/query-nnanga-chat.dto/query-nnanga-chat.dto';

@Injectable()
export class NnangaService {
  constructor(
    private readonly prisma: PrismaService,
    private readonly knowledgeService: KnowledgeService,
    private readonly aiService: AiService,
    private readonly streaksService: StreaksService,
  ) {}

  async chat(dto: CreateNnangaChatDto & { userId: string }) {
    const user = await this.prisma.user.findUnique({
      where: { id: dto.userId },
    });

    if (!user) {
      throw new BadRequestException('Invalid userId.');
    }

    if (dto.enrollmentId) {
      const enrollment = await this.prisma.enrollment.findUnique({
        where: { id: dto.enrollmentId },
      });

      if (!enrollment) {
        throw new BadRequestException('Invalid enrollmentId.');
      }
    }

    if (dto.lessonId) {
      const lesson = await this.prisma.lesson.findUnique({
        where: { id: dto.lessonId },
      });

      if (!lesson) {
        throw new BadRequestException('Invalid lessonId.');
      }
    }

    if (dto.vocabularyId) {
      const vocabulary = await this.prisma.vocabulary.findUnique({
        where: { id: dto.vocabularyId },
      });

      if (!vocabulary) {
        throw new BadRequestException('Invalid vocabularyId.');
      }
    }

    let languageName: string | undefined;
    if (dto.languageId) {
      const language = await this.prisma.language.findUnique({
        where: { id: dto.languageId },
      });

      if (!language) {
        throw new BadRequestException('Invalid languageId.');
      }

      languageName = language.name;
    }

    // A voice message is transcribed into the same `prompt` text the rest
    // of the pipeline expects — Nnanga doesn't need a separate audio code
    // path beyond this point. If transcription fails, fall back to asking
    // the learner to try again rather than silently running the pipeline
    // on empty text.
    let audioTranscript: string | null = null;
    let prompt = dto.prompt;
    if (dto.audioUrl) {
      const absolutePath = join(process.cwd(), dto.audioUrl.replace(/^\/+/, ''));
      const format = extname(dto.audioUrl).replace('.', '').toLowerCase() || 'webm';
      audioTranscript = await this.aiService.transcribeAudio(absolutePath, format);

      if (!audioTranscript) {
        throw new BadRequestException(
          "Couldn't transcribe that voice message — please try again or type your message.",
        );
      }
      prompt = audioTranscript;
    }

    const results = await this.knowledgeService.search(prompt, dto.languageId, languageName);
    const context = this.knowledgeService.buildTeachingContext(results, languageName);
    const usedLocalKnowledge = this.knowledgeService.hasStrongLocalKnowledge(results);

    // Recent turns for this learner, oldest first, so Nnanga can follow up
    // on what was just discussed instead of treating every message as a
    // fresh, context-free question. 20 turns (40 messages) comfortably fits
    // gpt-4o-mini's context window and covers a genuinely long conversation
    // rather than losing the thread after a handful of exchanges.
    const priorTurns = await this.prisma.aIConversation.findMany({
      where: { userId: dto.userId },
      orderBy: { createdAt: 'desc' },
      take: 20,
      select: { prompt: true, response: true },
    });
    const history = priorTurns
      .reverse()
      .flatMap((turn) => [
        { role: 'user' as const, content: turn.prompt },
        { role: 'assistant' as const, content: turn.response },
      ]);

    const structured = await this.aiService.generateStructuredTutorResponse(
      prompt,
      context,
      history,
      usedLocalKnowledge,
      languageName,
      results.biblePassage != null,
      results.isUngroundedTranslationRequest,
      results.suggestedVocabulary,
    );

    const conversation = await this.prisma.aIConversation.create({
      data: {
        userId: dto.userId,
        prompt,
        response: structured.response,
        tokens: 0,
        audioUrl: dto.audioUrl,
        audioTranscript,
        correction: structured.correction,
        translation: structured.translation,
        suggestedReplies: structured.suggestedReplies,
        usedLocalKnowledge,
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
      },
    });

    await this.streaksService.recordActivity(dto.userId, PracticeActivityType.AI_CHAT, 60, {
      lessonId: dto.lessonId,
    });

    return {
      ...conversation,
      matchedKeywords: results.keywords,
    };
  }

  async findAll(query: QueryNnangaChatDto) {
    const { page = 1, limit = 10, userId } = query;
    const skip = (page - 1) * limit;

    const where: Prisma.AIConversationWhereInput = {};
    if (userId) where.userId = userId;

    const [conversations, total] = await Promise.all([
      this.prisma.aIConversation.findMany({
        where,
        skip,
        take: limit,
        orderBy: { createdAt: 'desc' },
        include: {
          user: {
            select: {
              id: true,
              fullName: true,
              email: true,
              role: true,
            },
          },
        },
      }),
      this.prisma.aIConversation.count({ where }),
    ]);

    return {
      assistantName: 'Nnanga',
      items: conversations,
      total,
      page,
      limit,
      totalPages: Math.ceil(total / limit),
    };
  }

  async findOne(id: string) {
    const conversation = await this.prisma.aIConversation.findUnique({
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
      },
    });

    if (!conversation) {
      throw new NotFoundException('Nnanga conversation not found.');
    }

    return conversation;
  }

  async findOneForUser(id: string, currentUser: ICurrentUser) {
    const conversation = await this.findOne(id);

    const isOwner = conversation.userId === currentUser.userId;
    const isStaff =
      currentUser.role === UserRole.ADMIN ||
      currentUser.role === UserRole.TEACHER;

    if (!isOwner && !isStaff) {
      throw new ForbiddenException('You do not have access to this record.');
    }

    return conversation;
  }
}