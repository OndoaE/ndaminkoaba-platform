import { Controller, Delete, Get, HttpCode, HttpStatus, Query, UseGuards } from '@nestjs/common';
import { UserRole } from '@prisma/client';

import { JwtAuthGuard } from '../auth/guards/jwt-auth/jwt-auth.guard';
import { RolesGuard } from '../auth/guards/roles/roles.guard';
import { Roles } from '../auth/decorators/roles/roles.decorator';

import { AuditLogService } from './audit-log.service';
import { QueryAuditLogDto } from './dto/query-audit-log.dto';

@Controller('audit-logs')
@UseGuards(JwtAuthGuard, RolesGuard)
@Roles(UserRole.ADMIN, UserRole.TEACHER)
export class AuditLogController {
  constructor(private readonly auditLogService: AuditLogService) {}

  @Get()
  findAll(@Query() query: QueryAuditLogDto) {
    return this.auditLogService.findAll(query);
  }

  // Deliberately not @Audited — auditing this action would immediately
  // insert a new "DELETE" entry right after wiping the table, so the
  // history would never actually appear empty.
  @Delete()
  @Roles(UserRole.ADMIN)
  @HttpCode(HttpStatus.NO_CONTENT)
  removeAll() {
    return this.auditLogService.removeAll();
  }
}
