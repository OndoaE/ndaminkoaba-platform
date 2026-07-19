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
import { redactChoiceAnswer, redactChoiceAnswers } from '../common/utils/helpers';

import { ChoicesService } from './choices.service';
import { CreateChoiceDto } from './dto/create-choice.dto/create-choice.dto';
import { QueryChoiceDto } from './dto/query-choice.dto/query-choice.dto';
import { UpdateChoiceDto } from './dto/update-choice.dto/update-choice.dto';

@Controller('choices')
@UseGuards(JwtAuthGuard)
export class ChoicesController {
  constructor(private readonly choicesService: ChoicesService) {}

  @Get()
  async findAll(
    @CurrentUser() currentUser: ICurrentUser,
    @Query() query: QueryChoiceDto,
  ) {
    const result = await this.choicesService.findAll(query);
    return {
      ...result,
      items: redactChoiceAnswers(result.items, currentUser.role),
    };
  }

  @Get(':id')
  async findOne(
    @CurrentUser() currentUser: ICurrentUser,
    @Param('id') id: string,
  ) {
    const choice = await this.choicesService.findOne(id);
    return redactChoiceAnswer(choice, currentUser.role);
  }

  @Post()
  @UseGuards(RolesGuard)
  @Roles(UserRole.ADMIN, UserRole.TEACHER)
  create(@Body() dto: CreateChoiceDto) {
    return this.choicesService.create(dto);
  }

  @Patch(':id')
  @UseGuards(RolesGuard)
  @Roles(UserRole.ADMIN, UserRole.TEACHER)
  update(@Param('id') id: string, @Body() dto: UpdateChoiceDto) {
    return this.choicesService.update(id, dto);
  }

  @Delete(':id')
  @UseGuards(RolesGuard)
  @Roles(UserRole.ADMIN)
  remove(@Param('id') id: string) {
    return this.choicesService.remove(id);
  }
}
