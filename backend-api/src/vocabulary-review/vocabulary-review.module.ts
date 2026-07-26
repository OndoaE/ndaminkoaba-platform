import { Module } from '@nestjs/common';

import { PrismaModule } from '../prisma/prisma.module';
import { StreaksModule } from '../streaks/streaks.module';
import { BadgesModule } from '../badges/badges.module';
import { VocabularyReviewController } from './vocabulary-review.controller';
import { VocabularyReviewService } from './vocabulary-review.service';

@Module({
  imports: [PrismaModule, StreaksModule, BadgesModule],
  controllers: [VocabularyReviewController],
  providers: [VocabularyReviewService],
  exports: [VocabularyReviewService],
})
export class VocabularyReviewModule {}
