import {
  Controller,
  ForbiddenException,
  Get,
  Param,
  Query,
  UseGuards,
} from '@nestjs/common';
import { UserRole } from '@prisma/client';

import { JwtAuthGuard } from '../auth/guards/jwt-auth/jwt-auth.guard';
import { RolesGuard } from '../auth/guards/roles/roles.guard';
import { Roles } from '../auth/decorators/roles/roles.decorator';
import { CurrentUser } from '../common/decorators/current-user.decorator';
import type { ICurrentUser } from '../common/interfaces/current-user.interface';

import { DashboardService } from './dashboard.service';

@Controller('dashboard')
@UseGuards(JwtAuthGuard)
export class DashboardController {
  constructor(private readonly dashboardService: DashboardService) {}

  @Get('admin')
  @UseGuards(RolesGuard)
  @Roles(UserRole.ADMIN)
  adminDashboard(@Query('languageId') languageId?: string) {
    return this.dashboardService.getAdminDashboard(languageId);
  }

  @Get('teacher')
  @UseGuards(RolesGuard)
  @Roles(UserRole.ADMIN, UserRole.TEACHER)
  teacherDashboard() {
    return this.dashboardService.getTeacherDashboard();
  }

  @Get('learner/:userId')
  learnerDashboard(
    @CurrentUser() currentUser: ICurrentUser,
    @Param('userId') userId: string,
  ) {
    const isOwner = currentUser.userId === userId;
    const isStaff =
      currentUser.role === UserRole.ADMIN || currentUser.role === UserRole.TEACHER;

    if (!isOwner && !isStaff) {
      throw new ForbiddenException("You can only view your own dashboard.");
    }

    return this.dashboardService.getLearnerDashboard(userId);
  }
}