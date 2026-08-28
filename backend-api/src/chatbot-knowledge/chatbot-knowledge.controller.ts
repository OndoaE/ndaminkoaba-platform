import { Controller, Get, Res } from '@nestjs/common';
import type { Response } from 'express';

import { ChatbotKnowledgeService } from './chatbot-knowledge.service';

/// Public, unauthenticated content describing the platform (features,
/// platforms, FAQ) plus its real content (lessons, vocabulary, books, the
/// syllabary, and Bible verses), meant to be pointed at by a third-party
/// chatbot widget's "sync from URL" feature -- e.g. on a separate
/// marketing/download site. Re-fetching either endpoint IS the resync
/// mechanism; there is nothing else to trigger.
///
/// Both routes write directly to the raw Express response (@Res, non-
/// passthrough) instead of returning a value, deliberately bypassing the
/// app-wide ResponseInterceptor that wraps every other endpoint's payload
/// in {success, data, timestamp} -- an external tool pointed at "a JSON/
/// CSV endpoint" should get exactly that, not this API's internal
/// envelope, and the CSV route in particular would otherwise have its
/// whole body re-encoded as a JSON string instead of served as real CSV.
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
}
