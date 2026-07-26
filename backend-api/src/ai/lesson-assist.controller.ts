import { Body, Controller, Post, UseGuards } from '@nestjs/common';
import { UserRole } from '@prisma/client';

import { JwtAuthGuard } from '../auth/guards/jwt-auth/jwt-auth.guard';
import { RolesGuard } from '../auth/guards/roles/roles.guard';
import { Roles } from '../auth/decorators/roles/roles.decorator';

import { LessonAssistDto } from './dto/lesson-assist.dto';
import { LessonAssistService } from './lesson-assist.service';

@Controller('ai')
@UseGuards(JwtAuthGuard, RolesGuard)
@Roles(UserRole.ADMIN, UserRole.TEACHER)
export class LessonAssistController {
  constructor(private readonly lessonAssistService: LessonAssistService) {}

  @Post('lesson-assist')
  assist(@Body() dto: LessonAssistDto) {
    return this.lessonAssistService.assist(
      dto.action,
      dto.lessonContent,
      dto.frenchContent,
      dto.instruction,
    );
  }
}
