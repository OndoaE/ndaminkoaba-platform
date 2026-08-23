import { Module } from '@nestjs/common';
import { PrismaModule } from '../prisma/prisma.module';
import { BookBookmarksController } from './book-bookmarks.controller';
import { BookBookmarksService } from './book-bookmarks.service';

@Module({
  imports: [PrismaModule],
  controllers: [BookBookmarksController],
  providers: [BookBookmarksService],
})
export class BookBookmarksModule {}
