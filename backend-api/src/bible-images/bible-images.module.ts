import { Module } from '@nestjs/common';
import { PrismaModule } from '../prisma/prisma.module';
import { BibleImagesController } from './bible-images.controller';
import { BibleImagesService } from './bible-images.service';

@Module({
  imports: [PrismaModule],
  controllers: [BibleImagesController],
  providers: [BibleImagesService],
})
export class BibleImagesModule {}
