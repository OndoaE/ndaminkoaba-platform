import {
  Body,
  Controller,
  Delete,
  Get,
  Param,
  Patch,
  Post,
  Query,
  UseGuards,
} from '@nestjs/common';
import { UserRole } from '@prisma/client';

import { JwtAuthGuard } from '../auth/guards/jwt-auth/jwt-auth.guard';
import { RolesGuard } from '../auth/guards/roles/roles.guard';
import { Roles } from '../auth/decorators/roles/roles.decorator';
import { Audited } from '../audit-log/decorators/audited.decorator';
import { CurrentUser } from '../common/decorators/current-user.decorator';
import type { ICurrentUser } from '../common/interfaces/current-user.interface';
import { redactQuizAnswers } from '../common/utils/helpers';

import { QuizzesService } from './quizzes.service';
import { CreateQuizDto } from './dto/create-quiz.dto/create-quiz.dto';
import { QueryQuizDto } from './dto/query-quiz.dto/query-quiz.dto';
import { UpdateQuizDto } from './dto/update-quiz.dto/update-quiz.dto';

@Controller('quizzes')
@UseGuards(JwtAuthGuard)
export class QuizzesController {
  constructor(private readonly quizzesService: QuizzesService) {}

  @Get()
  async findAll(
    @CurrentUser() currentUser: ICurrentUser,
    @Query() query: QueryQuizDto,
  ) {
    const result = await this.quizzesService.findAll(query);
    return {
      ...result,
      items: result.items.map((quiz) => redactQuizAnswers(quiz, currentUser.role)),
    };
  }

  @Get(':id')
  async findOne(
    @CurrentUser() currentUser: ICurrentUser,
    @Param('id') id: string,
  ) {
    const quiz = await this.quizzesService.findOne(id);
    return redactQuizAnswers(quiz, currentUser.role);
  }

  @Post()
  @UseGuards(JwtAuthGuard, RolesGuard)
  @Roles(UserRole.ADMIN, UserRole.TEACHER)
  @Audited('Quiz')
  create(@Body() dto: CreateQuizDto) {
    return this.quizzesService.create(dto);
  }

  @Patch(':id')
  @UseGuards(JwtAuthGuard, RolesGuard)
  @Roles(UserRole.ADMIN, UserRole.TEACHER)
  @Audited('Quiz')
  update(@Param('id') id: string, @Body() dto: UpdateQuizDto) {
    return this.quizzesService.update(id, dto);
  }

  @Delete(':id')
  @UseGuards(JwtAuthGuard, RolesGuard)
  @Roles(UserRole.ADMIN)
  @Audited('Quiz')
  remove(@Param('id') id: string) {
    return this.quizzesService.remove(id);
  }
}