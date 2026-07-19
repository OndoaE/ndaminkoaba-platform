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

import { LessonImagesService } from './lesson-images.service';
import { CreateLessonImageDto } from './dto/create-lesson-image.dto/create-lesson-image.dto';
import { QueryLessonImageDto } from './dto/query-lesson-image.dto/query-lesson-image.dto';
import { UpdateLessonImageDto } from './dto/update-lesson-image.dto/update-lesson-image.dto';

@Controller('lesson-images')
export class LessonImagesController {
  constructor(private readonly lessonImagesService: LessonImagesService) {}

  @Get()
  findAll(@Query() query: QueryLessonImageDto) {
    return this.lessonImagesService.findAll(query);
  }

  @Get(':id')
  findOne(@Param('id') id: string) {
    return this.lessonImagesService.findOne(id);
  }

  @Post()
  @UseGuards(JwtAuthGuard, RolesGuard)
  @Roles(UserRole.ADMIN, UserRole.TEACHER)
  create(@Body() dto: CreateLessonImageDto) {
    return this.lessonImagesService.create(dto);
  }

  @Patch(':id')
  @UseGuards(JwtAuthGuard, RolesGuard)
  @Roles(UserRole.ADMIN, UserRole.TEACHER)
  update(@Param('id') id: string, @Body() dto: UpdateLessonImageDto) {
    return this.lessonImagesService.update(id, dto);
  }

  @Delete(':id')
  @UseGuards(JwtAuthGuard, RolesGuard)
  @Roles(UserRole.ADMIN, UserRole.TEACHER)
  remove(@Param('id') id: string) {
    return this.lessonImagesService.remove(id);
  }
}
