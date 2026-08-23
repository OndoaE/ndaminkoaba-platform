import { Body, Controller, Get, Post, Query, UseGuards } from '@nestjs/common';

import { JwtAuthGuard } from '../auth/guards/jwt-auth/jwt-auth.guard';

import { BookProgressService } from './book-progress.service';
import { CreateBookProgressDto } from './dto/create-book-progress.dto';
import { QueryBookProgressDto } from './dto/query-book-progress.dto';

@Controller('book-progress')
export class BookProgressController {
  constructor(private readonly bookProgressService: BookProgressService) {}

  @Post()
  @UseGuards(JwtAuthGuard)
  recordProgress(@Body() dto: CreateBookProgressDto) {
    return this.bookProgressService.recordProgress(dto);
  }

  @Get()
  @UseGuards(JwtAuthGuard)
  findAll(@Query() query: QueryBookProgressDto) {
    return this.bookProgressService.findAll(query);
  }
}
