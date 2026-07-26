import { Body, Controller, Get, Post, Query, UseGuards } from '@nestjs/common';
import { ApiBearerAuth, ApiTags } from '@nestjs/swagger';

import { JwtAuthGuard } from '../auth/guards/jwt-auth/jwt-auth.guard';
import { CurrentUser } from '../common/decorators/current-user.decorator';
import type { ICurrentUser } from '../common/interfaces/current-user.interface';

import { PronunciationAttemptsService } from './pronunciation-attempts.service';
import { CreatePronunciationAttemptDto } from './dto/create-pronunciation-attempt.dto/create-pronunciation-attempt.dto';

@ApiTags('Pronunciation Attempts')
@ApiBearerAuth('access-token')
@Controller('pronunciation-attempts')
@UseGuards(JwtAuthGuard)
export class PronunciationAttemptsController {
  constructor(private readonly pronunciationAttemptsService: PronunciationAttemptsService) {}

  @Post()
  create(
    @CurrentUser() currentUser: ICurrentUser,
    @Body() dto: CreatePronunciationAttemptDto,
  ) {
    return this.pronunciationAttemptsService.create(currentUser.userId, dto);
  }

  @Get('history')
  history(
    @CurrentUser() currentUser: ICurrentUser,
    @Query('vocabularyId') vocabularyId?: string,
  ) {
    return this.pronunciationAttemptsService.history(currentUser.userId, vocabularyId);
  }
}
