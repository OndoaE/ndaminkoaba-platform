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

import { ProgressService } from './progress.service';
import { CreateProgressDto } from './dto/create-progress.dto/create-progress.dto';
import { QueryProgressDto } from './dto/query-progress.dto/query-progress.dto';
import { UpdateProgressDto } from './dto/update-progress.dto/update-progress.dto';

@Controller('progress')
@UseGuards(JwtAuthGuard)
export class ProgressController {
  constructor(private readonly progressService: ProgressService) {}

  @Get()
  findAll(
    @CurrentUser() currentUser: ICurrentUser,
    @Query() query: QueryProgressDto,
  ) {
    const userId =
      currentUser.role === UserRole.LEARNER ? currentUser.userId : query.userId;

    return this.progressService.findAll({ ...query, userId });
  }

  @Get(':id')
  findOne(@CurrentUser() currentUser: ICurrentUser, @Param('id') id: string) {
    return this.progressService.findOneForUser(id, currentUser);
  }

  @Post()
  @UseGuards(RolesGuard)
  @Roles(UserRole.ADMIN, UserRole.TEACHER, UserRole.LEARNER)
  create(
    @CurrentUser() currentUser: ICurrentUser,
    @Body() dto: CreateProgressDto,
  ) {
    const userId =
      currentUser.role === UserRole.LEARNER ? currentUser.userId : dto.userId;

    return this.progressService.create({ ...dto, userId });
  }

  @Patch(':id')
  @UseGuards(RolesGuard)
  @Roles(UserRole.ADMIN, UserRole.TEACHER, UserRole.LEARNER)
  update(
    @CurrentUser() currentUser: ICurrentUser,
    @Param('id') id: string,
    @Body() dto: UpdateProgressDto,
  ) {
    return this.progressService.updateForUser(id, dto, currentUser);
  }

  @Delete(':id')
  @UseGuards(RolesGuard)
  @Roles(UserRole.ADMIN)
  remove(@Param('id') id: string) {
    return this.progressService.remove(id);
  }
}
