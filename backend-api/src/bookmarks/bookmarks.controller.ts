import {
  Body,
  Controller,
  Delete,
  Get,
  Param,
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

import { BookmarksService } from './bookmarks.service';
import { CreateBookmarkDto } from './dto/create-bookmark.dto/create-bookmark.dto';
import { QueryBookmarkDto } from './dto/query-bookmark.dto/query-bookmark.dto';

@Controller('bookmarks')
@UseGuards(JwtAuthGuard)
export class BookmarksController {
  constructor(private readonly bookmarksService: BookmarksService) {}

  @Get()
  findAll(
    @CurrentUser() currentUser: ICurrentUser,
    @Query() query: QueryBookmarkDto,
  ) {
    const userId =
      currentUser.role === UserRole.LEARNER ? currentUser.userId : query.userId;

    return this.bookmarksService.findAll({ ...query, userId });
  }

  @Get(':id')
  findOne(@CurrentUser() currentUser: ICurrentUser, @Param('id') id: string) {
    return this.bookmarksService.findOneForUser(id, currentUser);
  }

  @Post()
  @UseGuards(RolesGuard)
  @Roles(UserRole.ADMIN, UserRole.TEACHER, UserRole.LEARNER)
  create(
    @CurrentUser() currentUser: ICurrentUser,
    @Body() dto: CreateBookmarkDto,
  ) {
    const userId =
      currentUser.role === UserRole.LEARNER ? currentUser.userId : dto.userId;

    return this.bookmarksService.create({ ...dto, userId });
  }

  @Delete(':id')
  @UseGuards(RolesGuard)
  @Roles(UserRole.ADMIN, UserRole.TEACHER, UserRole.LEARNER)
  remove(@CurrentUser() currentUser: ICurrentUser, @Param('id') id: string) {
    return this.bookmarksService.removeForUser(id, currentUser);
  }
}
