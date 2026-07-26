import { Module } from '@nestjs/common';
import { PrismaModule } from '../prisma/prisma.module';
import { LessonCommentsController } from './lesson-comments.controller';
import { LessonCommentsService } from './lesson-comments.service';

@Module({
  imports: [PrismaModule],
  controllers: [LessonCommentsController],
  providers: [LessonCommentsService],
})
export class LessonCommentsModule {}
