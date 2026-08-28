import { Controller, Get, Header } from '@nestjs/common';

import { ChatbotKnowledgeService } from './chatbot-knowledge.service';

/// Public, unauthenticated content describing the platform (features,
/// platforms, FAQ, and a few live counts), meant to be pointed at by a
/// third-party chatbot widget's "sync from URL" feature -- e.g. on a
/// separate marketing/download site. Re-fetching either endpoint IS the
/// resync mechanism; there is nothing else to trigger.
@Controller('chatbot-knowledge')
export class ChatbotKnowledgeController {
  constructor(private readonly chatbotKnowledgeService: ChatbotKnowledgeService) {}

  @Get()
  getJson() {
    return this.chatbotKnowledgeService.getKnowledgeBase();
  }

  @Get('csv')
  @Header('Content-Type', 'text/csv; charset=utf-8')
  async getCsv() {
    return this.chatbotKnowledgeService.getKnowledgeBaseAsCsv();
  }
}
