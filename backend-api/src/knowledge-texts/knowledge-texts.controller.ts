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

import { KnowledgeTextsService } from './knowledge-texts.service';
import { CreateKnowledgeTextDto } from './dto/create-knowledge-text.dto/create-knowledge-text.dto';
import { QueryKnowledgeTextDto } from './dto/query-knowledge-text.dto/query-knowledge-text.dto';
import { UpdateKnowledgeTextDto } from './dto/update-knowledge-text.dto/update-knowledge-text.dto';

@Controller('knowledge-texts')
export class KnowledgeTextsController {
  constructor(private readonly knowledgeTextsService: KnowledgeTextsService) {}

  @Get()
  findAll(@Query() query: QueryKnowledgeTextDto) {
    return this.knowledgeTextsService.findAll(query);
  }

  @Get(':id')
  findOne(@Param('id') id: string) {
    return this.knowledgeTextsService.findOne(id);
  }

  @Post()
  @UseGuards(JwtAuthGuard, RolesGuard)
  @Roles(UserRole.ADMIN, UserRole.TEACHER)
  @Audited('Knowledge Text')
  create(@Body() dto: CreateKnowledgeTextDto) {
    return this.knowledgeTextsService.create(dto);
  }

  @Patch(':id')
  @UseGuards(JwtAuthGuard, RolesGuard)
  @Roles(UserRole.ADMIN, UserRole.TEACHER)
  @Audited('Knowledge Text')
  update(@Param('id') id: string, @Body() dto: UpdateKnowledgeTextDto) {
    return this.knowledgeTextsService.update(id, dto);
  }

  @Delete(':id')
  @UseGuards(JwtAuthGuard, RolesGuard)
  @Roles(UserRole.ADMIN, UserRole.TEACHER)
  @Audited('Knowledge Text')
  remove(@Param('id') id: string) {
    return this.knowledgeTextsService.remove(id);
  }
}
