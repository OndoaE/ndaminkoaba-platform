import { Controller, Get, UseGuards } from '@nestjs/common';
import { ApiBearerAuth, ApiTags } from '@nestjs/swagger';

import { JwtAuthGuard } from '../auth/guards/jwt-auth/jwt-auth.guard';
import { CurrentUser } from '../common/decorators/current-user.decorator';
import type { ICurrentUser } from '../common/interfaces/current-user.interface';

import { BadgesService } from './badges.service';

@ApiTags('Badges')
@ApiBearerAuth('access-token')
@Controller('badges')
@UseGuards(JwtAuthGuard)
export class BadgesController {
  constructor(private readonly badgesService: BadgesService) {}

  @Get()
  findAll(@CurrentUser() currentUser: ICurrentUser) {
    return this.badgesService.getBadgesForUser(currentUser.userId);
  }
}
