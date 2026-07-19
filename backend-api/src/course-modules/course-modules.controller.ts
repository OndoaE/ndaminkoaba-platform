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

import { CourseModulesService } from './course-modules.service';
import { CreateCourseModuleDto } from './dto/create-course-module.dto/create-course-module.dto';
import { QueryCourseModuleDto } from './dto/query-course-module.dto/query-course-module.dto';
import { UpdateCourseModuleDto } from './dto/update-course-module.dto/update-course-module.dto';

@Controller('course-modules')
export class CourseModulesController {
  constructor(private readonly courseModulesService: CourseModulesService) {}

  @Get()
  findAll(@Query() query: QueryCourseModuleDto) {
    return this.courseModulesService.findAll(query);
  }

  @Get(':id')
  findOne(@Param('id') id: string) {
    return this.courseModulesService.findOne(id);
  }

  @Post()
  @UseGuards(JwtAuthGuard, RolesGuard)
  @Roles(UserRole.ADMIN, UserRole.TEACHER)
  @Audited('Module')
  create(@Body() dto: CreateCourseModuleDto) {
    return this.courseModulesService.create(dto);
  }

  @Patch(':id')
  @UseGuards(JwtAuthGuard, RolesGuard)
  @Roles(UserRole.ADMIN, UserRole.TEACHER)
  @Audited('Module')
  update(@Param('id') id: string, @Body() dto: UpdateCourseModuleDto) {
    return this.courseModulesService.update(id, dto);
  }

  @Delete(':id')
  @UseGuards(JwtAuthGuard, RolesGuard)
  @Roles(UserRole.ADMIN)
  @Audited('Module')
  remove(@Param('id') id: string) {
    return this.courseModulesService.remove(id);
  }
}