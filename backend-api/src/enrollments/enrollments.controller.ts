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

import { EnrollmentsService } from './enrollments.service';
import { CreateEnrollmentDto } from './dto/create-enrollment.dto/create-enrollment.dto';
import { QueryEnrollmentDto } from './dto/query-enrollment.dto/query-enrollment.dto';
import { UpdateEnrollmentDto } from './dto/update-enrollment.dto/update-enrollment.dto';

@Controller('enrollments')
@UseGuards(JwtAuthGuard)
export class EnrollmentsController {
  constructor(private readonly enrollmentsService: EnrollmentsService) {}

  @Get()
  findAll(
    @CurrentUser() currentUser: ICurrentUser,
    @Query() query: QueryEnrollmentDto,
  ) {
    const userId =
      currentUser.role === UserRole.LEARNER ? currentUser.userId : query.userId;

    return this.enrollmentsService.findAll({ ...query, userId });
  }

  @Get(':id')
  findOne(@CurrentUser() currentUser: ICurrentUser, @Param('id') id: string) {
    return this.enrollmentsService.findOneForUser(id, currentUser);
  }

  @Post()
  @UseGuards(RolesGuard)
  @Roles(UserRole.ADMIN, UserRole.TEACHER, UserRole.LEARNER)
  create(
    @CurrentUser() currentUser: ICurrentUser,
    @Body() dto: CreateEnrollmentDto,
  ) {
    const userId =
      currentUser.role === UserRole.LEARNER ? currentUser.userId : dto.userId;

    return this.enrollmentsService.create({ ...dto, userId });
  }

  @Patch(':id')
  @UseGuards(RolesGuard)
  @Roles(UserRole.ADMIN, UserRole.TEACHER)
  update(@Param('id') id: string, @Body() dto: UpdateEnrollmentDto) {
    return this.enrollmentsService.update(id, dto);
  }

  @Delete(':id')
  @UseGuards(RolesGuard)
  @Roles(UserRole.ADMIN)
  remove(@Param('id') id: string) {
    return this.enrollmentsService.remove(id);
  }
}
