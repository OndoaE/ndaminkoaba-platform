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

import { SyllabaryService } from './syllabary.service';
import { CreateSyllabaryEntryDto } from './dto/create-syllabary-entry.dto';
import { UpdateSyllabaryEntryDto } from './dto/update-syllabary-entry.dto';
import { QuerySyllabaryDto } from './dto/query-syllabary.dto';
import { ExtractSyllabaryDto } from './dto/extract-syllabary.dto';

@Controller('syllabary')
export class SyllabaryController {
  constructor(private readonly syllabaryService: SyllabaryService) {}

  // ---------- Learner-facing (public) ----------

  @Get('letters')
  getLetters(@Query('languageId') languageId: string) {
    return this.syllabaryService.getLetters(languageId);
  }

  @Get('chart')
  getChart(@Query('languageId') languageId: string, @Query('letter') letter: string) {
    return this.syllabaryService.getChart(languageId, letter);
  }

  // ---------- Admin: CRUD ----------

  @Get('entries')
  @UseGuards(JwtAuthGuard, RolesGuard)
  @Roles(UserRole.ADMIN, UserRole.TEACHER)
  findAll(@Query() query: QuerySyllabaryDto) {
    return this.syllabaryService.findAll(query);
  }

  @Post('entries')
  @UseGuards(JwtAuthGuard, RolesGuard)
  @Roles(UserRole.ADMIN, UserRole.TEACHER)
  @Audited('Syllabary Entry')
  create(@Body() dto: CreateSyllabaryEntryDto) {
    return this.syllabaryService.create(dto);
  }

  @Patch('entries/:id')
  @UseGuards(JwtAuthGuard, RolesGuard)
  @Roles(UserRole.ADMIN, UserRole.TEACHER)
  @Audited('Syllabary Entry')
  update(@Param('id') id: string, @Body() dto: UpdateSyllabaryEntryDto) {
    return this.syllabaryService.update(id, dto);
  }

  @Delete('entries/:id')
  @UseGuards(JwtAuthGuard, RolesGuard)
  @Roles(UserRole.ADMIN, UserRole.TEACHER)
  @Audited('Syllabary Entry')
  remove(@Param('id') id: string) {
    return this.syllabaryService.remove(id);
  }

  // ---------- Admin: AI extraction (read-only, never writes to the DB) ----------

  @Post('extract')
  @UseGuards(JwtAuthGuard, RolesGuard)
  @Roles(UserRole.ADMIN, UserRole.TEACHER)
  extract(@Body() dto: ExtractSyllabaryDto) {
    return this.syllabaryService.extract(dto);
  }
}
