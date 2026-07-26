import { Module } from '@nestjs/common';
import { PrismaModule } from '../prisma/prisma.module';
import { StreaksModule } from '../streaks/streaks.module';
import { BadgesModule } from '../badges/badges.module';
import { QuizAttemptsController } from './quiz-attempts.controller';
import { QuizAttemptsService } from './quiz-attempts.service';

@Module({
  imports: [PrismaModule, StreaksModule, BadgesModule],
  controllers: [QuizAttemptsController],
  providers: [QuizAttemptsService],
})
export class QuizAttemptsModule {}
