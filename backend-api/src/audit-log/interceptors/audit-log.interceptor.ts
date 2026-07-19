import { CallHandler, ExecutionContext, Injectable, NestInterceptor } from '@nestjs/common';
import { Reflector } from '@nestjs/core';
import { tap } from 'rxjs/operators';

import { AuditLogService } from '../audit-log.service';
import { AUDITED_ENTITY_KEY } from '../decorators/audited.decorator';

function actionForMethod(method: string): string | null {
  switch (method) {
    case 'POST':
      return 'CREATE';
    case 'PATCH':
    case 'PUT':
      return 'UPDATE';
    case 'DELETE':
      return 'DELETE';
    default:
      return null;
  }
}

/// Best-effort label for the History screen. Tries the fields that are
/// meaningful across our various admin-managed entities in priority order,
/// falling back to a book/chapter/verse composite for Bible-shaped records.
function extractSummary(raw: unknown): string | undefined {
  if (Array.isArray(raw)) return `${raw.length} item${raw.length === 1 ? '' : 's'}`;
  if (!raw || typeof raw !== 'object') return undefined;
  const record = raw as Record<string, unknown>;
  if (typeof record.count === 'number') {
    return `${record.count} item${record.count === 1 ? '' : 's'}`;
  }
  if (record.book && record.chapter != null && record.verse != null) {
    return `${record.book} ${record.chapter}:${record.verse}`;
  }
  const candidates = [
    'title',
    'fullName',
    'name',
    'word',
    'questionText',
    'choiceText',
    'text',
    'reference',
    'email',
  ];
  for (const key of candidates) {
    const value = record[key];
    if (typeof value === 'string' && value.trim()) return value;
  }
  return undefined;
}

@Injectable()
export class AuditLogInterceptor implements NestInterceptor {
  constructor(
    private readonly reflector: Reflector,
    private readonly auditLogService: AuditLogService,
  ) {}

  intercept(context: ExecutionContext, next: CallHandler) {
    const entity = this.reflector.get<string | undefined>(AUDITED_ENTITY_KEY, context.getHandler());
    if (!entity) return next.handle();

    const request = context.switchToHttp().getRequest();
    const action = actionForMethod(request.method);
    if (!action) return next.handle();

    const userId: string | undefined = request.user?.userId;
    if (!userId) return next.handle();

    return next.handle().pipe(
      tap((response) => {
        const raw =
          response && typeof response === 'object' && 'data' in response
            ? (response as { data: unknown }).data
            : response;
        const entityId = (raw as { id?: string } | undefined)?.id ?? request.params?.id;
        // Some endpoints (e.g. broadcast) return only a result count, not the
        // entity fields — fall back to the request body, which usually has
        // the human-readable label (title, name, etc.) that was submitted.
        const summary = extractSummary(raw) ?? extractSummary(request.body);
        this.auditLogService.record({
          userId,
          action,
          entity,
          entityId,
          summary,
        });
      }),
    );
  }
}
