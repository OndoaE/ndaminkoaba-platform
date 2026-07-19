import { Injectable, NotFoundException } from '@nestjs/common';
import { BibleVerse } from '@prisma/client';

import { PrismaService } from '../prisma/prisma.service';
import { BulkUpsertBibleVersesDto } from './dto/bulk-upsert-bible-verses.dto/bulk-upsert-bible-verses.dto';
import { QueryBibleVersesDto } from './dto/query-bible-verses.dto/query-bible-verses.dto';

@Injectable()
export class BibleVersesService {
  constructor(private readonly prisma: PrismaService) {}

  async bulkUpsert(dto: BulkUpsertBibleVersesDto) {
    const items: BibleVerse[] = [];

    for (const input of dto.verses) {
      const version = input.version ?? 'ESV';

      const saved = await this.prisma.bibleVerse.upsert({
        where: {
          book_chapter_verse_version_language: {
            book: input.book,
            chapter: input.chapter,
            verse: input.verse,
            version,
            languageId: dto.languageId,
          },
        },
        create: { ...input, version, languageId: dto.languageId },
        update: {
          text: input.text,
          englishText: input.englishText,
          frenchText: input.frenchText,
        },
      });

      items.push(saved);
    }

    return { count: items.length, items };
  }

  findAll(query: QueryBibleVersesDto) {
    return this.prisma.bibleVerse.findMany({
      where: {
        book: query.book,
        chapter: query.chapter,
        version: query.version,
        languageId: query.languageId,
      },
      orderBy: { verse: 'asc' },
    });
  }

  async getChapters(languageId?: string) {
    const grouped = await this.prisma.bibleVerse.groupBy({
      by: ['book', 'chapter', 'version'],
      where: { languageId },
      _count: { _all: true },
      orderBy: [{ book: 'asc' }, { chapter: 'asc' }],
    });

    return grouped.map((g) => ({
      book: g.book,
      chapter: g.chapter,
      version: g.version,
      verseCount: g._count._all,
    }));
  }

  async deleteChapter(
    book: string,
    chapter: number,
    version?: string,
    languageId?: string,
  ) {
    return this.prisma.bibleVerse.deleteMany({
      where: { book, chapter, version: version ?? undefined, languageId },
    });
  }

  async remove(id: string) {
    const verse = await this.prisma.bibleVerse.findUnique({ where: { id } });

    if (!verse) {
      throw new NotFoundException('Bible verse not found.');
    }

    return this.prisma.bibleVerse.delete({ where: { id } });
  }
}
