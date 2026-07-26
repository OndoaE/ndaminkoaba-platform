import {
  Body,
  Controller,
  Get,
  Param,
  Post,
  Query,
  UseGuards,
} from '@nestjs/common';
import { ApiBearerAuth, ApiTags } from '@nestjs/swagger';

import { JwtAuthGuard } from '../auth/guards/jwt-auth/jwt-auth.guard';
import { CurrentUser } from '../common/decorators/current-user.decorator';
import type { ICurrentUser } from '../common/interfaces/current-user.interface';

import { VocabularyReviewService } from './vocabulary-review.service';
import { GradeReviewDto } from './dto/grade-review.dto/grade-review.dto';

@ApiTags('Vocabulary Review')
@ApiBearerAuth('access-token')
@Controller('vocabulary-review')
@UseGuards(JwtAuthGuard)
export class VocabularyReviewController {
  constructor(private readonly vocabularyReviewService: VocabularyReviewService) {}

  @Get('due')
  getDue(
    @CurrentUser() currentUser: ICurrentUser,
    @Query('limit') limit?: string,
  ) {
    return this.vocabularyReviewService.getDue(
      currentUser.userId,
      limit ? parseInt(limit, 10) : undefined,
    );
  }

  @Post(':vocabularyId/grade')
  grade(
    @CurrentUser() currentUser: ICurrentUser,
    @Param('vocabularyId') vocabularyId: string,
    @Body() dto: GradeReviewDto,
  ) {
    return this.vocabularyReviewService.grade(currentUser.userId, vocabularyId, dto.grade);
  }
}
