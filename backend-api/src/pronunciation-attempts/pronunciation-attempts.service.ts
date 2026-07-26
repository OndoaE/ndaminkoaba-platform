import { BadRequestException, Injectable, Logger } from '@nestjs/common';
import { PracticeActivityType, PronunciationAttemptStatus } from '@prisma/client';
import { extname, join } from 'path';

import { PrismaService } from '../prisma/prisma.service';
import { AiService } from '../ai/ai.service';
import { StreaksService } from '../streaks/streaks.service';
import { BadgesService } from '../badges/badges.service';
import { scorePronunciation } from '../common/utils/text-similarity';
import { CreatePronunciationAttemptDto } from './dto/create-pronunciation-attempt.dto/create-pronunciation-attempt.dto';

function feedbackForScore(score: number): string {
  if (score >= 90) return 'Excellent — that was very close to the target pronunciation.';
  if (score >= 70) return 'Good effort — close, with a little room to sharpen.';
  if (score >= 40) return 'Keep practicing — some sounds are still off from the target.';
  return "That didn't quite match yet — try listening again and repeating slowly.";
}

@Injectable()
export class PronunciationAttemptsService {
  private readonly logger = new Logger(PronunciationAttemptsService.name);

  constructor(
    private readonly prisma: PrismaService,
    private readonly aiService: AiService,
    private readonly streaksService: StreaksService,
    private readonly badgesService: BadgesService,
  ) {}

  async create(userId: string, dto: CreatePronunciationAttemptDto) {
    if (dto.vocabularyId) {
      const vocabulary = await this.prisma.vocabulary.findUnique({
        where: { id: dto.vocabularyId },
      });
      if (!vocabulary) {
        throw new BadRequestException('Invalid vocabularyId.');
      }
    }

    if (dto.lessonId) {
      const lesson = await this.prisma.lesson.findUnique({ where: { id: dto.lessonId } });
      if (!lesson) {
        throw new BadRequestException('Invalid lessonId.');
      }
    }

    const attempt = await this.prisma.pronunciationAttempt.create({
      data: {
        userId,
        vocabularyId: dto.vocabularyId,
        lessonId: dto.lessonId,
        targetText: dto.targetText,
        audioUrl: dto.audioUrl,
        status: PronunciationAttemptStatus.PENDING,
      },
    });

    // Audio is stored on disk under ./uploads/<folder>/<file>, referenced by
    // the /uploads/<folder>/<file> URL returned from POST /uploads/audio.
    const absolutePath = join(process.cwd(), dto.audioUrl.replace(/^\/+/, ''));
    const format = extname(dto.audioUrl).replace('.', '').toLowerCase() || 'webm';

    const transcript = await this.aiService.transcribeAudio(absolutePath, format);

    let updated;
    if (!transcript) {
      updated = await this.prisma.pronunciationAttempt.update({
        where: { id: attempt.id },
        data: {
          status: PronunciationAttemptStatus.FAILED,
          feedback: "We couldn't score that attempt right now — please try again.",
        },
      });
    } else {
      const accuracyScore = scorePronunciation(transcript, dto.targetText);
      updated = await this.prisma.pronunciationAttempt.update({
        where: { id: attempt.id },
        data: {
          status: PronunciationAttemptStatus.SCORED,
          transcript,
          accuracyScore,
          feedback: feedbackForScore(accuracyScore),
        },
      });
    }

    await this.streaksService.recordActivity(
      userId,
      PracticeActivityType.PRONUNCIATION,
      15,
      { lessonId: dto.lessonId },
    );
    const newlyEarnedBadges = await this.badgesService.evaluateAndAward(userId);

    return { ...updated, newlyEarnedBadges };
  }

  async history(userId: string, vocabularyId?: string) {
    return this.prisma.pronunciationAttempt.findMany({
      where: { userId, vocabularyId },
      orderBy: { createdAt: 'desc' },
      take: 20,
    });
  }
}
