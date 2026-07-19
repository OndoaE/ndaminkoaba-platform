import { Injectable, Logger } from '@nestjs/common';
import { Prisma } from '@prisma/client';

import { PrismaService } from '../prisma/prisma.service';
import { QueryAuditLogDto } from './dto/query-audit-log.dto';

export interface RecordAuditLogInput {
  userId?: string;
  action: string;
  entity: string;
  entityId?: string;
  summary?: string;
}

@Injectable()
export class AuditLogService {
  private readonly logger = new Logger(AuditLogService.name);

  constructor(private readonly prisma: PrismaService) {}

  /// Fire-and-forget: audit logging must never fail the request it's
  /// recording, so failures are swallowed (and logged) rather than thrown.
  record(input: RecordAuditLogInput): void {
    this.prisma.auditLog
      .create({
        data: {
          userId: input.userId,
          action: input.action,
          entity: input.entity,
          entityId: input.entityId,
          summary: input.summary,
        },
      })
      .catch((error) => this.logger.warn(`Failed to record audit log: ${error}`));
  }

  async findAll(query: QueryAuditLogDto) {
    const { page = 1, limit = 20, entity, userId, search } = query;
    const skip = (page - 1) * limit;

    const where: Prisma.AuditLogWhereInput = {
      ...(entity ? { entity } : {}),
      ...(userId ? { userId } : {}),
      ...(search
        ? { summary: { contains: search, mode: Prisma.QueryMode.insensitive } }
        : {}),
    };

    const [items, total] = await Promise.all([
      this.prisma.auditLog.findMany({
        where,
        skip,
        take: limit,
        orderBy: { createdAt: 'desc' },
        include: {
          user: { select: { id: true, fullName: true, email: true, role: true } },
        },
      }),
      this.prisma.auditLog.count({ where }),
    ]);

    return { items, total, page, limit, totalPages: Math.ceil(total / limit) };
  }
}
