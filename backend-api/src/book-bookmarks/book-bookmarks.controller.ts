import { Body, Controller, Delete, Get, Param, Post, Query, UseGuards } from '@nestjs/common';
import { UserRole } from '@prisma/client';

import { JwtAuthGuard } from '../auth/guards/jwt-auth/jwt-auth.guard';
import { RolesGuard } from '../auth/guards/roles/roles.guard';
import { Roles } from '../auth/decorators/roles/roles.decorator';
import { CurrentUser } from '../common/decorators/current-user.decorator';
import type { ICurrentUser } from '../common/interfaces/current-user.interface';

import { BookBookmarksService } from './book-bookmarks.service';
import { CreateBookBookmarkDto } from './dto/create-book-bookmark.dto';
import { QueryBookBookmarkDto } from './dto/query-book-bookmark.dto';

@Controller('book-bookmarks')
@UseGuards(JwtAuthGuard)
export class BookBookmarksController {
  constructor(private readonly bookBookmarksService: BookBookmarksService) {}

  @Get()
  findAll(@CurrentUser() currentUser: ICurrentUser, @Query() query: QueryBookBookmarkDto) {
    const userId = currentUser.role === UserRole.LEARNER ? currentUser.userId : query.userId;
    return this.bookBookmarksService.findAll({ ...query, userId });
  }

  @Post()
  @UseGuards(RolesGuard)
  @Roles(UserRole.ADMIN, UserRole.TEACHER, UserRole.LEARNER)
  create(@CurrentUser() currentUser: ICurrentUser, @Body() dto: CreateBookBookmarkDto) {
    const userId = currentUser.role === UserRole.LEARNER ? currentUser.userId : dto.userId;
    return this.bookBookmarksService.create({ ...dto, userId });
  }

  @Delete(':id')
  @UseGuards(RolesGuard)
  @Roles(UserRole.ADMIN, UserRole.TEACHER, UserRole.LEARNER)
  remove(@CurrentUser() currentUser: ICurrentUser, @Param('id') id: string) {
    return this.bookBookmarksService.removeForUser(id, currentUser);
  }
}
