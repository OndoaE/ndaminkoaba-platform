import { Controller, Get, Query, UseGuards } from '@nestjs/common';
import { UserRole } from '@prisma/client';

import { JwtAuthGuard } from '../auth/guards/jwt-auth/jwt-auth.guard';
import { RolesGuard } from '../auth/guards/roles/roles.guard';
import { Roles } from '../auth/decorators/roles/roles.decorator';

import { ContentWorkflowService } from './content-workflow.service';

@Controller('admin/content-workflow')
@UseGuards(JwtAuthGuard, RolesGuard)
@Roles(UserRole.ADMIN, UserRole.TEACHER)
export class ContentWorkflowController {
  constructor(
    private readonly contentWorkflowService: ContentWorkflowService,
  ) {}

  @Get()
  getContentWorkflow(@Query('languageId') languageId?: string) {
    return this.contentWorkflowService.getContentWorkflow(languageId);
  }
}
