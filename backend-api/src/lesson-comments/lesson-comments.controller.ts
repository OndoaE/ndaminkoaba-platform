import {
  Body,
  Controller,
  Delete,
  Get,
  Param,
  Post,
  UseGuards,
} from '@nestjs/common';
import { UserRole } from '@prisma/client';

import { JwtAuthGuard } from '../auth/guards/jwt-auth/jwt-auth.guard';
import { RolesGuard } from '../auth/guards/roles/roles.guard';
import { Roles } from '../auth/decorators/roles/roles.decorator';
import { CurrentUser } from '../common/decorators/current-user.decorator';
import type { ICurrentUser } from '../common/interfaces/current-user.interface';

import { LessonCommentsService } from './lesson-comments.service';
import { CreateLessonCommentDto } from './dto/create-lesson-comment.dto';

@Controller()
@UseGuards(JwtAuthGuard, RolesGuard)
@Roles(UserRole.ADMIN, UserRole.TEACHER)
export class LessonCommentsController {
  constructor(
    private readonly lessonCommentsService: LessonCommentsService,
  ) {}

  @Get('lessons/:lessonId/comments')
  findAllForLesson(@Param('lessonId') lessonId: string) {
    return this.lessonCommentsService.findAllForLesson(lessonId);
  }

  @Post('lessons/:lessonId/comments')
  create(
    @Param('lessonId') lessonId: string,
    @Body() dto: CreateLessonCommentDto,
    @CurrentUser() currentUser: ICurrentUser,
  ) {
    return this.lessonCommentsService.create(
      lessonId,
      currentUser.userId,
      dto,
    );
  }

  @Delete('lesson-comments/:id')
  remove(@Param('id') id: string) {
    return this.lessonCommentsService.remove(id);
  }
}
