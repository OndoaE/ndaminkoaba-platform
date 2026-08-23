import { Module } from '@nestjs/common';
import { PrismaModule } from '../prisma/prisma.module';
import { BookPagesController } from './book-pages.controller';
import { BookPagesService } from './book-pages.service';

@Module({
  imports: [PrismaModule],
  controllers: [BookPagesController],
  providers: [BookPagesService],
})
export class BookPagesModule {}
