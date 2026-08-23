import { Body, Controller, Get, Post, Query, UseGuards } from '@nestjs/common';

import { JwtAuthGuard } from '../auth/guards/jwt-auth/jwt-auth.guard';

import { LessonHistoryService } from './lesson-history.service';
import { CreateLessonHistoryDto } from './dto/create-lesson-history.dto';
import { QueryLessonHistoryDto } from './dto/query-lesson-history.dto';

@Controller('lesson-history')
export class LessonHistoryController {
  constructor(private readonly lessonHistoryService: LessonHistoryService) {}

  @Post()
  @UseGuards(JwtAuthGuard)
  recordView(@Body() dto: CreateLessonHistoryDto) {
    return this.lessonHistoryService.recordView(dto);
  }

  @Get()
  @UseGuards(JwtAuthGuard)
  findAll(@Query() query: QueryLessonHistoryDto) {
    return this.lessonHistoryService.findAllForUser(query);
  }
}
