import { Body, Controller, Get, Post, Query, UseGuards } from '@nestjs/common';
import { UserRole } from '@prisma/client';

import { JwtAuthGuard } from '../auth/guards/jwt-auth/jwt-auth.guard';
import { CurrentUser } from '../common/decorators/current-user.decorator';
import type { ICurrentUser } from '../common/interfaces/current-user.interface';

import { BookProgressService } from './book-progress.service';
import { CreateBookProgressDto } from './dto/create-book-progress.dto';
import { QueryBookProgressDto } from './dto/query-book-progress.dto';

@Controller('book-progress')
@UseGuards(JwtAuthGuard)
export class BookProgressController {
  constructor(private readonly bookProgressService: BookProgressService) {}

  @Post()
  recordProgress(
    @CurrentUser() currentUser: ICurrentUser,
    @Body() dto: CreateBookProgressDto,
  ) {
    // A learner can only ever record their own progress; the userId in the
    // body is honored for staff only.
    const userId =
      currentUser.role === UserRole.LEARNER ? currentUser.userId : dto.userId;
    return this.bookProgressService.recordProgress({ ...dto, userId });
  }

  @Get()
  findAll(
    @CurrentUser() currentUser: ICurrentUser,
    @Query() query: QueryBookProgressDto,
  ) {
    const userId =
      currentUser.role === UserRole.LEARNER ? currentUser.userId : query.userId;
    return this.bookProgressService.findAll({ ...query, userId });
  }
}
