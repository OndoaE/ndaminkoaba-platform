import { Module } from '@nestjs/common';
import { PrismaModule } from '../prisma/prisma.module';
import { PronunciationsController } from './pronunciations.controller';
import { PronunciationsService } from './pronunciations.service';

@Module({
  imports: [PrismaModule],
  controllers: [PronunciationsController],
  providers: [PronunciationsService],
})
export class PronunciationsModule {}