import { Module } from '@nestjs/common';
import { PrismaModule } from '../prisma/prisma.module';
import { BibleVersesController } from './bible-verses.controller';
import { BibleVersesService } from './bible-verses.service';

@Module({
  imports: [PrismaModule],
  controllers: [BibleVersesController],
  providers: [BibleVersesService],
})
export class BibleVersesModule {}
