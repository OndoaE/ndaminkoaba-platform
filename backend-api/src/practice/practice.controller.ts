import { Controller, Get, UseGuards } from '@nestjs/common';
import { ApiBearerAuth, ApiTags } from '@nestjs/swagger';

import { JwtAuthGuard } from '../auth/guards/jwt-auth/jwt-auth.guard';
import { CurrentUser } from '../common/decorators/current-user.decorator';
import type { ICurrentUser } from '../common/interfaces/current-user.interface';

import { PracticeService } from './practice.service';

@ApiTags('Practice')
@ApiBearerAuth('access-token')
@Controller('practice')
@UseGuards(JwtAuthGuard)
export class PracticeController {
  constructor(private readonly practiceService: PracticeService) {}

  @Get('today')
  getToday(@CurrentUser() currentUser: ICurrentUser) {
    return this.practiceService.getToday(currentUser.userId);
  }

  @Get('weekly-calendar')
  getWeeklyCalendar(@CurrentUser() currentUser: ICurrentUser) {
    return this.practiceService.getWeeklyCalendar(currentUser.userId);
  }
}
