import { Injectable, NotFoundException } from '@nestjs/common';
import { Prisma } from '@prisma/client';

import { PrismaService } from '../prisma/prisma.service';
import { AiService } from '../ai/ai.service';
import { CreateSyllabaryEntryDto } from './dto/create-syllabary-entry.dto';
import { UpdateSyllabaryEntryDto } from './dto/update-syllabary-entry.dto';
import { QuerySyllabaryDto } from './dto/query-syllabary.dto';
import { ExtractSyllabaryDto } from './dto/extract-syllabary.dto';
import { extractDocumentText } from './document-text-extractor';

@Injectable()
export class SyllabaryService {
  constructor(
    private readonly prisma: PrismaService,
    private readonly aiService: AiService,
  ) {}

  // ---------- Learner-facing ----------

  /// Distinct "letters" a learner can browse for a language: every non-null
  /// consonant, plus (for any vowel-only entry with no consonant) that
  /// entry's own vowel — a standalone vowel is itself a browsable letter,
  /// not a group of eight like a consonant chart is.
  async getLetters(languageId: string): Promise<string[]> {
    const entries = await this.prisma.syllabaryEntry.findMany({
      where: { languageId },
      select: { consonant: true, vowel: true },
    });
    const letters = new Set(entries.map((e) => e.consonant ?? e.vowel));
    return Array.from(letters).sort((a, b) => a.localeCompare(b));
  }

  getChart(languageId: string, letter: string) {
    return this.prisma.syllabaryEntry.findMany({
      where: {
        languageId,
        OR: [{ consonant: letter }, { consonant: null, vowel: letter }],
      },
      orderBy: { orderNumber: 'asc' },
    });
  }

  // ---------- Admin CRUD ----------

  create(dto: CreateSyllabaryEntryDto) {
    return this.prisma.syllabaryEntry.create({ data: dto });
  }

  async findAll(query: QuerySyllabaryDto) {
    const { page = 1, limit = 10, search, languageId, letter } = query;
    const skip = (page - 1) * limit;

    const where: Prisma.SyllabaryEntryWhereInput = {};
    if (languageId) where.languageId = languageId;
    // letter and search are independent filters that must both hold when
    // both are given — each wrapped in its own OR clause and AND-ed
    // together, rather than merged into one OR (which would incorrectly
    // match a search hit with no letter match, or vice versa).
    const and: Prisma.SyllabaryEntryWhereInput[] = [];
    if (letter) {
      and.push({ OR: [{ consonant: letter }, { consonant: null, vowel: letter }] });
    }
    if (search) {
      and.push({
        OR: [
          { exampleWord: { contains: search, mode: Prisma.QueryMode.insensitive } },
          { translation: { contains: search, mode: Prisma.QueryMode.insensitive } },
          { syllable: { contains: search, mode: Prisma.QueryMode.insensitive } },
        ],
      });
    }
    if (and.length > 0) where.AND = and;

    const [items, total] = await Promise.all([
      this.prisma.syllabaryEntry.findMany({
        where,
        skip,
        take: limit,
        orderBy: [{ consonant: 'asc' }, { orderNumber: 'asc' }],
      }),
      this.prisma.syllabaryEntry.count({ where }),
    ]);

    return { items, total, page, limit, totalPages: Math.ceil(total / limit) };
  }

  async findOne(id: string) {
    const entry = await this.prisma.syllabaryEntry.findUnique({ where: { id } });
    if (!entry) throw new NotFoundException('Syllabary entry not found.');
    return entry;
  }

  async update(id: string, dto: UpdateSyllabaryEntryDto) {
    await this.findOne(id);
    return this.prisma.syllabaryEntry.update({ where: { id }, data: dto });
  }

  async remove(id: string) {
    await this.findOne(id);
    return this.prisma.syllabaryEntry.delete({ where: { id } });
  }

  // ---------- AI extraction (never writes to the DB) ----------

  /// Dispatches on whichever content field is present — pasted text goes
  /// straight to the text model, an uploaded document is text-extracted
  /// first (see `document-text-extractor.ts`) then goes the same route, and
  /// a photographed chart goes to the vision model, matching how
  /// `ExtractSyllabaryDto` documents its "exactly one of" contract.
  async extract(dto: ExtractSyllabaryDto) {
    const language = await this.prisma.language.findUnique({ where: { id: dto.languageId } });
    if (!language) {
      return {
        letters: [],
        warnings: ['Invalid languageId.'],
      };
    }

    if (dto.text && dto.text.trim().length > 0) {
      return this.aiService.extractSyllabaryChartFromText(dto.text, language.name);
    }

    if (dto.documentBase64 && dto.mimeType) {
      const buffer = Buffer.from(dto.documentBase64, 'base64');
      const text = await extractDocumentText(buffer, dto.mimeType);
      if (!text) {
        return {
          letters: [],
          warnings: [
            'Could not read any text from this file — try a different file, or paste the content directly.',
          ],
        };
      }
      return this.aiService.extractSyllabaryChartFromText(text, language.name);
    }

    if (dto.imageBase64 && dto.mimeType) {
      return this.aiService.extractSyllabaryChart(dto.imageBase64, dto.mimeType, language.name);
    }

    return {
      letters: [],
      warnings: ['No content provided to analyze.'],
    };
  }
}
