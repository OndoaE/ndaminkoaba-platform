import { Module } from '@nestjs/common';
import { PrismaModule } from '../prisma/prisma.module';
import { LessonBlocksController } from './lesson-blocks.controller';
import { LessonBlocksService } from './lesson-blocks.service';

@Module({
  imports: [PrismaModule],
  controllers: [LessonBlocksController],
  providers: [LessonBlocksService],
})
export class LessonBlocksModule {}
