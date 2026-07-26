import { Module } from '@nestjs/common';
import { PrismaModule } from '../prisma/prisma.module';
import { StreaksModule } from '../streaks/streaks.module';
import { BadgesModule } from '../badges/badges.module';
import { VocabularyReviewModule } from '../vocabulary-review/vocabulary-review.module';
import { ProgressController } from './progress.controller';
import { ProgressService } from './progress.service';

@Module({
  imports: [PrismaModule, StreaksModule, BadgesModule, VocabularyReviewModule],
  controllers: [ProgressController],
  providers: [ProgressService],
})
export class ProgressModule {}
