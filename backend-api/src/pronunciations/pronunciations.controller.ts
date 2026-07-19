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

import { PronunciationsService } from './pronunciations.service';
import { CreatePronunciationDto } from './dto/create-pronunciation.dto/create-pronunciation.dto';
import { QueryPronunciationDto } from './dto/query-pronunciation.dto/query-pronunciation.dto';
import { UpdatePronunciationDto } from './dto/update-pronunciation.dto/update-pronunciation.dto';

@Controller('pronunciations')
export class PronunciationsController {
  constructor(private readonly pronunciationsService: PronunciationsService) {}

  @Get()
  findAll(@Query() query: QueryPronunciationDto) {
    return this.pronunciationsService.findAll(query);
  }

  @Get(':id')
  findOne(@Param('id') id: string) {
    return this.pronunciationsService.findOne(id);
  }

  @Post()
  @UseGuards(JwtAuthGuard, RolesGuard)
  @Roles(UserRole.ADMIN, UserRole.TEACHER)
  create(@Body() dto: CreatePronunciationDto) {
    return this.pronunciationsService.create(dto);
  }

  @Patch(':id')
  @UseGuards(JwtAuthGuard, RolesGuard)
  @Roles(UserRole.ADMIN, UserRole.TEACHER)
  update(@Param('id') id: string, @Body() dto: UpdatePronunciationDto) {
    return this.pronunciationsService.update(id, dto);
  }

  @Delete(':id')
  @UseGuards(JwtAuthGuard, RolesGuard)
  @Roles(UserRole.ADMIN)
  remove(@Param('id') id: string) {
    return this.pronunciationsService.remove(id);
  }
}