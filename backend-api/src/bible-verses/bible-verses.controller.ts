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
import { Audited } from '../audit-log/decorators/audited.decorator';

import { BibleVersesService } from './bible-verses.service';
import { BulkUpsertBibleVersesDto } from './dto/bulk-upsert-bible-verses.dto/bulk-upsert-bible-verses.dto';
import { QueryBibleVersesDto } from './dto/query-bible-verses.dto/query-bible-verses.dto';

@Controller('bible-verses')
export class BibleVersesController {
  constructor(private readonly bibleVersesService: BibleVersesService) {}

  @Get('chapters')
  getChapters(@Query('languageId') languageId?: string) {
    return this.bibleVersesService.getChapters(languageId);
  }

  @Get()
  findAll(@Query() query: QueryBibleVersesDto) {
    return this.bibleVersesService.findAll(query);
  }

  @Post('bulk')
  @UseGuards(JwtAuthGuard, RolesGuard)
  @Roles(UserRole.ADMIN, UserRole.TEACHER)
  @Audited('Bible Verses')
  bulkUpsert(@Body() dto: BulkUpsertBibleVersesDto) {
    return this.bibleVersesService.bulkUpsert(dto);
  }

  @Delete('chapter')
  @UseGuards(JwtAuthGuard, RolesGuard)
  @Roles(UserRole.ADMIN, UserRole.TEACHER)
  @Audited('Bible Verses')
  deleteChapter(
    @Query('book') book: string,
    @Query('chapter') chapter: string,
    @Query('version') version?: string,
    @Query('languageId') languageId?: string,
  ) {
    return this.bibleVersesService.deleteChapter(book, Number(chapter), version, languageId);
  }

  @Delete(':id')
  @UseGuards(JwtAuthGuard, RolesGuard)
  @Roles(UserRole.ADMIN, UserRole.TEACHER)
  @Audited('Bible Verses')
  remove(@Param('id') id: string) {
    return this.bibleVersesService.remove(id);
  }
}
