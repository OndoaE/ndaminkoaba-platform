import { Body, Controller, Delete, Get, Param, Patch, Post, Query, UseGuards } from '@nestjs/common';
import { UserRole } from '@prisma/client';

import { JwtAuthGuard } from '../auth/guards/jwt-auth/jwt-auth.guard';
import { RolesGuard } from '../auth/guards/roles/roles.guard';
import { Roles } from '../auth/decorators/roles/roles.decorator';
import { Audited } from '../audit-log/decorators/audited.decorator';

import { BookPagesService } from './book-pages.service';
import { CreateBookPageDto } from './dto/create-book-page.dto';
import { UpdateBookPageDto } from './dto/update-book-page.dto';
import { ReorderBookPagesDto } from './dto/reorder-book-pages.dto';

@Controller('book-pages')
export class BookPagesController {
  constructor(private readonly bookPagesService: BookPagesService) {}

  // Public — the learner-facing illustrated reader reads pages directly
  // (no derive-to-flat-field step exists for BookPage, unlike LessonBlock).
  @Get()
  findAllForBook(@Query('bookId') bookId: string) {
    return this.bookPagesService.findAllForBook(bookId);
  }

  @Post()
  @UseGuards(JwtAuthGuard, RolesGuard)
  @Roles(UserRole.ADMIN, UserRole.TEACHER)
  @Audited('BookPage')
  create(@Body() dto: CreateBookPageDto) {
    return this.bookPagesService.create(dto);
  }

  // Declared before ':id' so 'reorder' isn't matched as a page id.
  @Patch('reorder')
  @UseGuards(JwtAuthGuard, RolesGuard)
  @Roles(UserRole.ADMIN, UserRole.TEACHER)
  @Audited('BookPage')
  reorder(@Body() dto: ReorderBookPagesDto) {
    return this.bookPagesService.reorder(dto);
  }

  @Patch(':id')
  @UseGuards(JwtAuthGuard, RolesGuard)
  @Roles(UserRole.ADMIN, UserRole.TEACHER)
  @Audited('BookPage')
  update(@Param('id') id: string, @Body() dto: UpdateBookPageDto) {
    return this.bookPagesService.update(id, dto);
  }

  @Delete(':id')
  @UseGuards(JwtAuthGuard, RolesGuard)
  @Roles(UserRole.ADMIN, UserRole.TEACHER)
  @Audited('BookPage')
  remove(@Param('id') id: string) {
    return this.bookPagesService.remove(id);
  }
}
