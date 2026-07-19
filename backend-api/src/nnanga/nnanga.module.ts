import { Module } from '@nestjs/common';
import { PrismaModule } from '../prisma/prisma.module';
import { KnowledgeModule } from '../knowledge/knowledge.module';
import { AiModule } from '../ai/ai.module';

import { NnangaController } from './nnanga.controller';
import { NnangaService } from './nnanga.service';

@Module({
  imports: [
    PrismaModule,
    KnowledgeModule,
    AiModule,
  ],
  controllers: [NnangaController],
  providers: [NnangaService],
})
export class NnangaModule {}