import {
  Body,
  Controller,
  Delete,
  Get,
  Param,
  Post,
  Query,
  UseGuards,
} from '@nestjs/common';
import { UserRole } from '@prisma/client';

import { JwtAuthGuard } from '../auth/guards/jwt-auth/jwt-auth.guard';
import { RolesGuard } from '../auth/guards/roles/roles.guard';
import { Roles } from '../auth/decorators/roles/roles.decorator';
import { CurrentUser } from '../common/decorators/current-user.decorator';
import type { ICurrentUser } from '../common/interfaces/current-user.interface';

import { QuizAttemptsService } from './quiz-attempts.service';
import { CreateQuizAttemptDto } from './dto/create-quiz-attempt.dto/create-quiz-attempt.dto';
import { QueryQuizAttemptDto } from './dto/query-quiz-attempt.dto/query-quiz-attempt.dto';

@Controller('quiz-attempts')
@UseGuards(JwtAuthGuard)
export class QuizAttemptsController {
  constructor(private readonly quizAttemptsService: QuizAttemptsService) {}

  @Get()
  findAll(
    @CurrentUser() currentUser: ICurrentUser,
    @Query() query: QueryQuizAttemptDto,
  ) {
    const userId =
      currentUser.role === UserRole.LEARNER ? currentUser.userId : query.userId;

    return this.quizAttemptsService.findAll({ ...query, userId });
  }

  @Get(':id')
  findOne(@CurrentUser() currentUser: ICurrentUser, @Param('id') id: string) {
    return this.quizAttemptsService.findOneForUser(id, currentUser);
  }

  @Post()
  @UseGuards(RolesGuard)
  @Roles(UserRole.ADMIN, UserRole.TEACHER, UserRole.LEARNER)
  create(
    @CurrentUser() currentUser: ICurrentUser,
    @Body() dto: CreateQuizAttemptDto,
  ) {
    const userId =
      currentUser.role === UserRole.LEARNER ? currentUser.userId : dto.userId;

    return this.quizAttemptsService.create({ ...dto, userId });
  }

  @Delete(':id')
  @UseGuards(RolesGuard)
  @Roles(UserRole.ADMIN)
  remove(@Param('id') id: string) {
    return this.quizAttemptsService.remove(id);
  }
}
