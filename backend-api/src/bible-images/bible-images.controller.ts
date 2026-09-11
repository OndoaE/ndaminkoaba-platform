import { Body, Controller, Delete, Get, Param, Post, Query, UseGuards } from '@nestjs/common';
import { UserRole } from '@prisma/client';

import { JwtAuthGuard } from '../auth/guards/jwt-auth/jwt-auth.guard';
import { RolesGuard } from '../auth/guards/roles/roles.guard';
import { Roles } from '../auth/decorators/roles/roles.decorator';
import { Audited } from '../audit-log/decorators/audited.decorator';

import { BibleImagesService } from './bible-images.service';
import { UpsertBibleBookCoverDto } from './dto/upsert-bible-book-cover.dto/upsert-bible-book-cover.dto';
import { UpsertBibleHeroImageDto } from './dto/upsert-bible-hero-image.dto/upsert-bible-hero-image.dto';

@Controller('bible-images')
export class BibleImagesController {
  constructor(private readonly bibleImagesService: BibleImagesService) {}

  @Get()
  getImages(@Query('languageId') languageId?: string) {
    return this.bibleImagesService.getImages(languageId);
  }

  @Post('cover')
  @UseGuards(JwtAuthGuard, RolesGuard)
  @Roles(UserRole.ADMIN, UserRole.TEACHER)
  @Audited('Bible Images')
  upsertBookCover(@Body() dto: UpsertBibleBookCoverDto) {
    return this.bibleImagesService.upsertBookCover(dto);
  }

  @Post('hero')
  @UseGuards(JwtAuthGuard, RolesGuard)
  @Roles(UserRole.ADMIN, UserRole.TEACHER)
  @Audited('Bible Images')
  upsertHeroImage(@Body() dto: UpsertBibleHeroImageDto) {
    return this.bibleImagesService.upsertHeroImage(dto);
  }

  @Delete('cover/:id')
  @UseGuards(JwtAuthGuard, RolesGuard)
  @Roles(UserRole.ADMIN, UserRole.TEACHER)
  @Audited('Bible Images')
  removeBookCover(@Param('id') id: string) {
    return this.bibleImagesService.removeBookCover(id);
  }

  @Delete('hero/:id')
  @UseGuards(JwtAuthGuard, RolesGuard)
  @Roles(UserRole.ADMIN, UserRole.TEACHER)
  @Audited('Bible Images')
  removeHeroImage(@Param('id') id: string) {
    return this.bibleImagesService.removeHeroImage(id);
  }
}
