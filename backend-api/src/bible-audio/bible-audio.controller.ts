import { Body, Controller, Delete, Get, Param, Post, Query, UseGuards } from '@nestjs/common';
import { UserRole } from '@prisma/client';

import { JwtAuthGuard } from '../auth/guards/jwt-auth/jwt-auth.guard';
import { RolesGuard } from '../auth/guards/roles/roles.guard';
import { Roles } from '../auth/decorators/roles/roles.decorator';
import { Audited } from '../audit-log/decorators/audited.decorator';

import { BibleAudioService } from './bible-audio.service';
import { UpsertBibleChapterAudioDto } from './dto/upsert-bible-chapter-audio.dto/upsert-bible-chapter-audio.dto';

@Controller('bible-audio')
export class BibleAudioController {
  constructor(private readonly bibleAudioService: BibleAudioService) {}

  @Get()
  getAudio(@Query('languageId') languageId?: string) {
    return this.bibleAudioService.getAudio(languageId);
  }

  @Post()
  @UseGuards(JwtAuthGuard, RolesGuard)
  @Roles(UserRole.ADMIN, UserRole.TEACHER)
  @Audited('Bible Audio')
  upsertAudio(@Body() dto: UpsertBibleChapterAudioDto) {
    return this.bibleAudioService.upsertAudio(dto);
  }

  @Delete(':id')
  @UseGuards(JwtAuthGuard, RolesGuard)
  @Roles(UserRole.ADMIN, UserRole.TEACHER)
  @Audited('Bible Audio')
  removeAudio(@Param('id') id: string) {
    return this.bibleAudioService.removeAudio(id);
  }
}
