import { Module } from '@nestjs/common';

import { PrismaModule } from '../prisma/prisma.module';
import { AiModule } from '../ai/ai.module';
import { StreaksModule } from '../streaks/streaks.module';
import { BadgesModule } from '../badges/badges.module';
import { PronunciationAttemptsController } from './pronunciation-attempts.controller';
import { PronunciationAttemptsService } from './pronunciation-attempts.service';

@Module({
  imports: [PrismaModule, AiModule, StreaksModule, BadgesModule],
  controllers: [PronunciationAttemptsController],
  providers: [PronunciationAttemptsService],
})
export class PronunciationAttemptsModule {}
