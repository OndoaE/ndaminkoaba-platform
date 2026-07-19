import { Module } from '@nestjs/common';
import { PrismaModule } from '../prisma/prisma.module';
import { LessonImagesController } from './lesson-images.controller';
import { LessonImagesService } from './lesson-images.service';

@Module({
  imports: [PrismaModule],
  controllers: [LessonImagesController],
  providers: [LessonImagesService],
})
export class LessonImagesModule {}
