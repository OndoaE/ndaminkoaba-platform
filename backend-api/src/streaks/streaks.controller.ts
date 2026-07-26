import { Body, Controller, Get, Patch, UseGuards } from '@nestjs/common';
import { ApiBearerAuth, ApiTags } from '@nestjs/swagger';

import { JwtAuthGuard } from '../auth/guards/jwt-auth/jwt-auth.guard';
import { CurrentUser } from '../common/decorators/current-user.decorator';
import type { ICurrentUser } from '../common/interfaces/current-user.interface';

import { StreaksService } from './streaks.service';
import { UpdateGoalDto } from './dto/update-goal.dto/update-goal.dto';

@ApiTags('Streaks')
@ApiBearerAuth('access-token')
@Controller('streaks')
@UseGuards(JwtAuthGuard)
export class StreaksController {
  constructor(private readonly streaksService: StreaksService) {}

  @Get('me')
  getMe(@CurrentUser() currentUser: ICurrentUser) {
    return this.streaksService.getMe(currentUser.userId);
  }

  @Patch('goal')
  updateGoal(
    @CurrentUser() currentUser: ICurrentUser,
    @Body() dto: UpdateGoalDto,
  ) {
    return this.streaksService.updateGoal(currentUser.userId, dto.minutes);
  }
}
