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

import { NotificationsService } from './notifications.service';
import { CreateNotificationDto } from './dto/create-notification.dto/create-notification.dto';
import { QueryNotificationDto } from './dto/query-notification.dto/query-notification.dto';
import { BroadcastNotificationDto } from './dto/broadcast-notification.dto/broadcast-notification.dto';

@Controller('notifications')
@UseGuards(JwtAuthGuard)
export class NotificationsController {
  constructor(private readonly notificationsService: NotificationsService) {}

  @Get()
  findAll(
    @CurrentUser() currentUser: ICurrentUser,
    @Query() query: QueryNotificationDto,
  ) {
    const userId =
      currentUser.role === UserRole.LEARNER ? currentUser.userId : query.userId;

    return this.notificationsService.findAll({ ...query, userId });
  }

  @Get(':id')
  findOne(@CurrentUser() currentUser: ICurrentUser, @Param('id') id: string) {
    return this.notificationsService.findOneForUser(id, currentUser);
  }

  @Post()
  @UseGuards(RolesGuard)
  @Roles(UserRole.ADMIN, UserRole.TEACHER)
  create(@Body() dto: CreateNotificationDto) {
    return this.notificationsService.create(dto);
  }

  @Post('broadcast')
  @UseGuards(RolesGuard)
  @Roles(UserRole.ADMIN)
  @Audited('Announcement')
  broadcast(@Body() dto: BroadcastNotificationDto) {
    return this.notificationsService.broadcast(dto);
  }

  @Patch(':id/read')
  markAsRead(@CurrentUser() currentUser: ICurrentUser, @Param('id') id: string) {
    return this.notificationsService.markAsReadForUser(id, currentUser);
  }

  @Delete(':id')
  @UseGuards(RolesGuard)
  @Roles(UserRole.ADMIN)
  remove(@Param('id') id: string) {
    return this.notificationsService.remove(id);
  }
}
