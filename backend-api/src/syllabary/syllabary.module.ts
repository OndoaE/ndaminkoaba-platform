import { Module } from '@nestjs/common';
import { PrismaModule } from '../prisma/prisma.module';
import { AiModule } from '../ai/ai.module';
import { SyllabaryController } from './syllabary.controller';
import { SyllabaryService } from './syllabary.service';

@Module({
  imports: [PrismaModule, AiModule],
  controllers: [SyllabaryController],
  providers: [SyllabaryService],
})
export class SyllabaryModule {}
