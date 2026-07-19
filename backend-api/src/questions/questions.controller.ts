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
import { CurrentUser } from '../common/decorators/current-user.decorator';
import type { ICurrentUser } from '../common/interfaces/current-user.interface';
import { redactQuestionAnswers } from '../common/utils/helpers';

import { QuestionsService } from './questions.service';
import { CreateQuestionDto } from './dto/create-question.dto/create-question.dto';
import { QueryQuestionDto } from './dto/query-question.dto/query-question.dto';
import { UpdateQuestionDto } from './dto/update-question.dto/update-question.dto';

@Controller('questions')
@UseGuards(JwtAuthGuard)
export class QuestionsController {
  constructor(private readonly questionsService: QuestionsService) {}

  @Get()
  async findAll(
    @CurrentUser() currentUser: ICurrentUser,
    @Query() query: QueryQuestionDto,
  ) {
    const result = await this.questionsService.findAll(query);
    return {
      ...result,
      items: result.items.map((question) =>
        redactQuestionAnswers(question, currentUser.role),
      ),
    };
  }

  @Get(':id')
  async findOne(
    @CurrentUser() currentUser: ICurrentUser,
    @Param('id') id: string,
  ) {
    const question = await this.questionsService.findOne(id);
    return redactQuestionAnswers(question, currentUser.role);
  }

  @Post()
  @UseGuards(RolesGuard)
  @Roles(UserRole.ADMIN, UserRole.TEACHER)
  create(@Body() dto: CreateQuestionDto) {
    return this.questionsService.create(dto);
  }

  @Patch(':id')
  @UseGuards(RolesGuard)
  @Roles(UserRole.ADMIN, UserRole.TEACHER)
  update(@Param('id') id: string, @Body() dto: UpdateQuestionDto) {
    return this.questionsService.update(id, dto);
  }

  @Delete(':id')
  @UseGuards(RolesGuard)
  @Roles(UserRole.ADMIN)
  remove(@Param('id') id: string) {
    return this.questionsService.remove(id);
  }
}
