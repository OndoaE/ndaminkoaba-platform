import { Module } from '@nestjs/common';
import { PrismaModule } from '../prisma/prisma.module';
import { KnowledgeTextsController } from './knowledge-texts.controller';
import { KnowledgeTextsService } from './knowledge-texts.service';

@Module({
  imports: [PrismaModule],
  controllers: [KnowledgeTextsController],
  providers: [KnowledgeTextsService],
})
export class KnowledgeTextsModule {}
