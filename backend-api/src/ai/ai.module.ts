import { Module } from '@nestjs/common';
import { AiService } from './ai.service';
import { LessonAssistController } from './lesson-assist.controller';
import { LessonAssistService } from './lesson-assist.service';

@Module({
  controllers: [LessonAssistController],
  providers: [AiService, LessonAssistService],
  exports: [AiService],
})
export class AiModule {}