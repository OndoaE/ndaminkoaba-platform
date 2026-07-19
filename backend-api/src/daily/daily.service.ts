import { Injectable, NotFoundException } from '@nestjs/common';
import { Prisma } from '@prisma/client';

import { PrismaService } from '../prisma/prisma.service';
import { CreateDailyWordDto } from './dto/create-daily-word.dto';
import { UpdateDailyWordDto } from './dto/update-daily-word.dto';
import { CreateDailyVerseDto } from './dto/create-daily-verse.dto';
import { UpdateDailyVerseDto } from './dto/update-daily-verse.dto';
import { QueryDailyDto } from './dto/query-daily.dto';

@Injectable()
export class DailyService {
  constructor(private readonly prisma: PrismaService) {}

  /// Picks a stable index into a pool of size `count` that only changes
  /// once per calendar day (UTC) — the same formula used for both the word
  /// and verse pools so admins never have to mark anything as "today's".
  private todayIndex(count: number): number {
    const daysSinceEpoch = Math.floor(Date.now() / 86_400_000);
    return daysSinceEpoch % count;
  }

  // ---------- Daily Word ----------

  async todayWord(languageId?: string) {
    const words = await this.prisma.dailyWord.findMany({
      where: { languageId },
      orderBy: { createdAt: 'asc' },
    });
    if (words.length === 0) return null;
    return words[this.todayIndex(words.length)];
  }

  createWord(dto: CreateDailyWordDto) {
    return this.prisma.dailyWord.create({ data: dto });
  }

  async findAllWords(query: QueryDailyDto) {
    const { page = 1, limit = 10, search, languageId } = query;
    const skip = (page - 1) * limit;

    const where: Prisma.DailyWordWhereInput = {};
    if (languageId) where.languageId = languageId;
    if (search) {
      where.OR = [
        { word: { contains: search, mode: Prisma.QueryMode.insensitive } },
        { englishMeaning: { contains: search, mode: Prisma.QueryMode.insensitive } },
        { frenchMeaning: { contains: search, mode: Prisma.QueryMode.insensitive } },
      ];
    }

    const [items, total] = await Promise.all([
      this.prisma.dailyWord.findMany({ where, skip, take: limit, orderBy: { createdAt: 'desc' } }),
      this.prisma.dailyWord.count({ where }),
    ]);

    return { items, total, page, limit, totalPages: Math.ceil(total / limit) };
  }

  async findOneWord(id: string) {
    const word = await this.prisma.dailyWord.findUnique({ where: { id } });
    if (!word) throw new NotFoundException('Daily word not found.');
    return word;
  }

  async updateWord(id: string, dto: UpdateDailyWordDto) {
    await this.findOneWord(id);
    return this.prisma.dailyWord.update({ where: { id }, data: dto });
  }

  async removeWord(id: string) {
    await this.findOneWord(id);
    return this.prisma.dailyWord.delete({ where: { id } });
  }

  // ---------- Daily Verse ----------

  async todayVerse(languageId?: string) {
    const verses = await this.prisma.dailyVerse.findMany({
      where: { languageId },
      orderBy: { createdAt: 'asc' },
    });
    if (verses.length === 0) return null;
    return verses[this.todayIndex(verses.length)];
  }

  createVerse(dto: CreateDailyVerseDto) {
    return this.prisma.dailyVerse.create({ data: dto });
  }

  async findAllVerses(query: QueryDailyDto) {
    const { page = 1, limit = 10, search, languageId } = query;
    const skip = (page - 1) * limit;

    const where: Prisma.DailyVerseWhereInput = {};
    if (languageId) where.languageId = languageId;
    if (search) {
      where.OR = [
        { text: { contains: search, mode: Prisma.QueryMode.insensitive } },
        { englishText: { contains: search, mode: Prisma.QueryMode.insensitive } },
        { frenchText: { contains: search, mode: Prisma.QueryMode.insensitive } },
        { reference: { contains: search, mode: Prisma.QueryMode.insensitive } },
      ];
    }

    const [items, total] = await Promise.all([
      this.prisma.dailyVerse.findMany({ where, skip, take: limit, orderBy: { createdAt: 'desc' } }),
      this.prisma.dailyVerse.count({ where }),
    ]);

    return { items, total, page, limit, totalPages: Math.ceil(total / limit) };
  }

  async findOneVerse(id: string) {
    const verse = await this.prisma.dailyVerse.findUnique({ where: { id } });
    if (!verse) throw new NotFoundException('Daily verse not found.');
    return verse;
  }

  async updateVerse(id: string, dto: UpdateDailyVerseDto) {
    await this.findOneVerse(id);
    return this.prisma.dailyVerse.update({ where: { id }, data: dto });
  }

  async removeVerse(id: string) {
    await this.findOneVerse(id);
    return this.prisma.dailyVerse.delete({ where: { id } });
  }
}
