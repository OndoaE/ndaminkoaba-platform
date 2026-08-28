import { Module } from '@nestjs/common';

import { PrismaModule } from '../prisma/prisma.module';
import { ChatbotKnowledgeController } from './chatbot-knowledge.controller';
import { ChatbotKnowledgeService } from './chatbot-knowledge.service';

@Module({
  imports: [PrismaModule],
  controllers: [ChatbotKnowledgeController],
  providers: [ChatbotKnowledgeService],
})
export class ChatbotKnowledgeModule {}
