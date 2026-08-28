import { Controller, Get, Res } from '@nestjs/common';
import type { Response } from 'express';

import { ChatbotKnowledgeService } from './chatbot-knowledge.service';

/// Public, unauthenticated content describing the platform (features,
/// platforms, FAQ) plus its real content (lessons, vocabulary, books, the
/// syllabary, and Bible verses), meant to be pointed at by a third-party
/// chatbot widget's "sync from URL" feature -- e.g. on a separate
/// marketing/download site. Re-fetching any route IS the resync
/// mechanism; there is nothing else to trigger.
///
/// All routes write directly to the raw Express response (@Res, non-
/// passthrough) instead of returning a value, deliberately bypassing the
/// app-wide ResponseInterceptor that wraps every other endpoint's payload
/// in {success, data, timestamp} -- an external tool pointed at "a JSON/
/// CSV endpoint" should get exactly that, not this API's internal
/// envelope, and a CSV route in particular would otherwise have its
/// whole body re-encoded as a JSON string instead of served as real CSV.
///
/// The combined `/` and `/csv` routes bundle EVERYTHING in one response
/// (~2MB) -- some third-party chatbot "sync from URL" tools silently
/// truncate a large source, which would drop Books/Bible since they are
/// appended last. The per-section routes below exist so a sync tool can
/// be pointed at several much smaller sources instead (e.g. one URL just
/// for Books, one just for Bible), sidestepping any such limit entirely
/// and making it possible to verify each content type ingests correctly
/// on its own.
@Controller('chatbot-knowledge')
export class ChatbotKnowledgeController {
  constructor(private readonly chatbotKnowledgeService: ChatbotKnowledgeService) {}

  @Get()
  async getJson(@Res() res: Response) {
    const data = await this.chatbotKnowledgeService.getKnowledgeBase();
    res.type('application/json').send(data);
  }

  @Get('csv')
  async getCsv(@Res() res: Response) {
    const csv = await this.chatbotKnowledgeService.getKnowledgeBaseAsCsv();
    res.type('text/csv; charset=utf-8').send(csv);
  }

  // ---------- Per-section routes (small, single-purpose) ----------

  @Get('overview')
  async getOverview(@Res() res: Response) {
    res.type('application/json').send(this.chatbotKnowledgeService.getOverview());
  }

  @Get('overview/csv')
  async getOverviewCsv(@Res() res: Response) {
    const csv = await this.chatbotKnowledgeService.getOverviewCsv();
    res.type('text/csv; charset=utf-8').send(csv);
  }

  @Get('lessons')
  async getLessons(@Res() res: Response) {
    const lessons = await this.chatbotKnowledgeService.getLessons();
    res.type('application/json').send({ lessons, count: lessons.length });
  }

  @Get('lessons/csv')
  async getLessonsCsv(@Res() res: Response) {
    const csv = await this.chatbotKnowledgeService.getLessonsCsv();
    res.type('text/csv; charset=utf-8').send(csv);
  }

  @Get('vocabulary')
  async getVocabulary(@Res() res: Response) {
    const vocabulary = await this.chatbotKnowledgeService.getVocabulary();
    res.type('application/json').send({ vocabulary, count: vocabulary.length });
  }

  @Get('vocabulary/csv')
  async getVocabularyCsv(@Res() res: Response) {
    const csv = await this.chatbotKnowledgeService.getVocabularyCsv();
    res.type('text/csv; charset=utf-8').send(csv);
  }

  @Get('books')
  async getBooks(@Res() res: Response) {
    const books = await this.chatbotKnowledgeService.getBooks();
    res.type('application/json').send({ books, count: books.length });
  }

  @Get('books/csv')
  async getBooksCsv(@Res() res: Response) {
    const csv = await this.chatbotKnowledgeService.getBooksCsv();
    res.type('text/csv; charset=utf-8').send(csv);
  }

  @Get('syllabary')
  async getSyllabary(@Res() res: Response) {
    const syllabary = await this.chatbotKnowledgeService.getSyllabary();
    res.type('application/json').send({ syllabary, count: syllabary.length });
  }

  @Get('syllabary/csv')
  async getSyllabaryCsv(@Res() res: Response) {
    const csv = await this.chatbotKnowledgeService.getSyllabaryCsv();
    res.type('text/csv; charset=utf-8').send(csv);
  }

  @Get('bible')
  async getBible(@Res() res: Response) {
    const bibleVerses = await this.chatbotKnowledgeService.getBibleVerses();
    res.type('application/json').send({ bibleVerses, count: bibleVerses.length });
  }

  @Get('bible/csv')
  async getBibleCsv(@Res() res: Response) {
    const csv = await this.chatbotKnowledgeService.getBibleCsv();
    res.type('text/csv; charset=utf-8').send(csv);
  }
}
