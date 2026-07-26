import {
  Body,
  Controller,
  Delete,
  Get,
  Param,
  Patch,
  Post,
  UseGuards,
} from '@nestjs/common';
import { UserRole } from '@prisma/client';

import { JwtAuthGuard } from '../auth/guards/jwt-auth/jwt-auth.guard';
import { RolesGuard } from '../auth/guards/roles/roles.guard';
import { Roles } from '../auth/decorators/roles/roles.decorator';
import { Audited } from '../audit-log/decorators/audited.decorator';

import { LessonBlocksService } from './lesson-blocks.service';
import { CreateLessonBlockDto } from './dto/create-lesson-block.dto';
import { ReorderLessonBlocksDto } from './dto/reorder-lesson-blocks.dto';
import { UpdateLessonBlockDto } from './dto/update-lesson-block.dto';

@Controller()
@UseGuards(JwtAuthGuard, RolesGuard)
@Roles(UserRole.ADMIN, UserRole.TEACHER)
export class LessonBlocksController {
  constructor(private readonly lessonBlocksService: LessonBlocksService) {}

  @Get('lessons/:lessonId/blocks')
  findAllForLesson(@Param('lessonId') lessonId: string) {
    return this.lessonBlocksService.findAllForLesson(lessonId);
  }

  @Post('lesson-blocks')
  @Audited('LessonBlock')
  create(@Body() dto: CreateLessonBlockDto) {
    return this.lessonBlocksService.create(dto);
  }

  // Declared before 'lesson-blocks/:id' so 'reorder' isn't matched as a
  // block id.
  @Patch('lesson-blocks/reorder')
  @Audited('LessonBlock')
  reorder(@Body() dto: ReorderLessonBlocksDto) {
    return this.lessonBlocksService.reorder(dto);
  }

  @Patch('lesson-blocks/:id')
  @Audited('LessonBlock')
  update(@Param('id') id: string, @Body() dto: UpdateLessonBlockDto) {
    return this.lessonBlocksService.update(id, dto);
  }

  @Delete('lesson-blocks/:id')
  @Audited('LessonBlock')
  remove(@Param('id') id: string) {
    return this.lessonBlocksService.remove(id);
  }
}
