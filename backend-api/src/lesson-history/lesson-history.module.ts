import { Module } from '@nestjs/common';
import { PrismaModule } from '../prisma/prisma.module';
import { LessonHistoryController } from './lesson-history.controller';
import { LessonHistoryService } from './lesson-history.service';

@Module({
  imports: [PrismaModule],
  controllers: [LessonHistoryController],
  providers: [LessonHistoryService],
})
export class LessonHistoryModule {}
