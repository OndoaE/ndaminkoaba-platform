import { Injectable, NotFoundException } from '@nestjs/common';

import { PrismaService } from '../prisma/prisma.service';
import { UpsertBibleChapterAudioDto } from './dto/upsert-bible-chapter-audio.dto/upsert-bible-chapter-audio.dto';

@Injectable()
export class BibleAudioService {
  constructor(private readonly prisma: PrismaService) {}

  getAudio(languageId?: string) {
    return this.prisma.bibleChapterAudio.findMany({
      where: { languageId },
      orderBy: [{ book: 'asc' }, { chapter: 'asc' }],
    });
  }

  upsertAudio(dto: UpsertBibleChapterAudioDto) {
    return this.prisma.bibleChapterAudio.upsert({
      where: {
        languageId_book_chapter: {
          languageId: dto.languageId,
          book: dto.book,
          chapter: dto.chapter,
        },
      },
      create: dto,
      update: { audioUrl: dto.audioUrl },
    });
  }

  async removeAudio(id: string) {
    const audio = await this.prisma.bibleChapterAudio.findUnique({ where: { id } });
    if (!audio) {
      throw new NotFoundException('Bible chapter audio not found.');
    }
    return this.prisma.bibleChapterAudio.delete({ where: { id } });
  }
}
