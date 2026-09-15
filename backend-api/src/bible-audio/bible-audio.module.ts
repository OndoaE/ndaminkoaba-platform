import { Module } from '@nestjs/common';
import { PrismaModule } from '../prisma/prisma.module';
import { BibleAudioController } from './bible-audio.controller';
import { BibleAudioService } from './bible-audio.service';

@Module({
  imports: [PrismaModule],
  controllers: [BibleAudioController],
  providers: [BibleAudioService],
})
export class BibleAudioModule {}
