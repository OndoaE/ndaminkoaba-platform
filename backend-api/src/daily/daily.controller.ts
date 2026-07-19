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

import { DailyService } from './daily.service';
import { CreateDailyWordDto } from './dto/create-daily-word.dto';
import { UpdateDailyWordDto } from './dto/update-daily-word.dto';
import { CreateDailyVerseDto } from './dto/create-daily-verse.dto';
import { UpdateDailyVerseDto } from './dto/update-daily-verse.dto';
import { QueryDailyDto } from './dto/query-daily.dto';

@Controller('daily')
export class DailyController {
  constructor(private readonly dailyService: DailyService) {}

  // ---------- Learner-facing (public) ----------

  @Get('word')
  todayWord(@Query('languageId') languageId?: string) {
    return this.dailyService.todayWord(languageId);
  }

  @Get('verse')
  todayVerse(@Query('languageId') languageId?: string) {
    return this.dailyService.todayVerse(languageId);
  }

  // ---------- Admin: Daily Words ----------

  @Get('words')
  @UseGuards(JwtAuthGuard, RolesGuard)
  @Roles(UserRole.ADMIN, UserRole.TEACHER)
  findAllWords(@Query() query: QueryDailyDto) {
    return this.dailyService.findAllWords(query);
  }

  @Post('words')
  @UseGuards(JwtAuthGuard, RolesGuard)
  @Roles(UserRole.ADMIN, UserRole.TEACHER)
  @Audited('Daily Word')
  createWord(@Body() dto: CreateDailyWordDto) {
    return this.dailyService.createWord(dto);
  }

  @Patch('words/:id')
  @UseGuards(JwtAuthGuard, RolesGuard)
  @Roles(UserRole.ADMIN, UserRole.TEACHER)
  @Audited('Daily Word')
  updateWord(@Param('id') id: string, @Body() dto: UpdateDailyWordDto) {
    return this.dailyService.updateWord(id, dto);
  }

  @Delete('words/:id')
  @UseGuards(JwtAuthGuard, RolesGuard)
  @Roles(UserRole.ADMIN, UserRole.TEACHER)
  @Audited('Daily Word')
  removeWord(@Param('id') id: string) {
    return this.dailyService.removeWord(id);
  }

  // ---------- Admin: Daily Verses ----------

  @Get('verses')
  @UseGuards(JwtAuthGuard, RolesGuard)
  @Roles(UserRole.ADMIN, UserRole.TEACHER)
  findAllVerses(@Query() query: QueryDailyDto) {
    return this.dailyService.findAllVerses(query);
  }

  @Post('verses')
  @UseGuards(JwtAuthGuard, RolesGuard)
  @Roles(UserRole.ADMIN, UserRole.TEACHER)
  @Audited('Daily Verse')
  createVerse(@Body() dto: CreateDailyVerseDto) {
    return this.dailyService.createVerse(dto);
  }

  @Patch('verses/:id')
  @UseGuards(JwtAuthGuard, RolesGuard)
  @Roles(UserRole.ADMIN, UserRole.TEACHER)
  @Audited('Daily Verse')
  updateVerse(@Param('id') id: string, @Body() dto: UpdateDailyVerseDto) {
    return this.dailyService.updateVerse(id, dto);
  }

  @Delete('verses/:id')
  @UseGuards(JwtAuthGuard, RolesGuard)
  @Roles(UserRole.ADMIN, UserRole.TEACHER)
  @Audited('Daily Verse')
  removeVerse(@Param('id') id: string) {
    return this.dailyService.removeVerse(id);
  }
}
