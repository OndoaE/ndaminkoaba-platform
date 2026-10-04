import { Body, Controller, Get, Post, Query, UseGuards } from '@nestjs/common';
import { UserRole } from '@prisma/client';

import { JwtAuthGuard } from '../auth/guards/jwt-auth/jwt-auth.guard';
import { CurrentUser } from '../common/decorators/current-user.decorator';
import type { ICurrentUser } from '../common/interfaces/current-user.interface';

import { LessonHistoryService } from './lesson-history.service';
import { CreateLessonHistoryDto } from './dto/create-lesson-history.dto';
import { QueryLessonHistoryDto } from './dto/query-lesson-history.dto';

@Controller('lesson-history')
@UseGuards(JwtAuthGuard)
export class LessonHistoryController {
  constructor(private readonly lessonHistoryService: LessonHistoryService) {}

  @Post()
  recordView(
    @CurrentUser() currentUser: ICurrentUser,
    @Body() dto: CreateLessonHistoryDto,
  ) {
    // A learner can only ever record their own views; the userId in the body
    // is honored for staff only.
    const userId =
      currentUser.role === UserRole.LEARNER ? currentUser.userId : dto.userId;
    return this.lessonHistoryService.recordView({ ...dto, userId });
  }

  @Get()
  findAll(
    @CurrentUser() currentUser: ICurrentUser,
    @Query() query: QueryLessonHistoryDto,
  ) {
    const userId =
      currentUser.role === UserRole.LEARNER ? currentUser.userId : query.userId;
    return this.lessonHistoryService.findAllForUser({ ...query, userId });
  }
}
