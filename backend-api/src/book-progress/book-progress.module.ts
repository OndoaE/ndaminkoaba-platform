import { Module } from '@nestjs/common';
import { PrismaModule } from '../prisma/prisma.module';
import { BookProgressController } from './book-progress.controller';
import { BookProgressService } from './book-progress.service';

@Module({
  imports: [PrismaModule],
  controllers: [BookProgressController],
  providers: [BookProgressService],
})
export class BookProgressModule {}
