import { SetMetadata } from '@nestjs/common';

export const AUDITED_ENTITY_KEY = 'auditedEntity';

/// Marks a controller method for automatic audit logging. `entity` is a
/// human-readable noun (e.g. "Course", "Daily Word") shown in the History
/// screen. The action (CREATE/UPDATE/DELETE) is inferred from the HTTP
/// method by `AuditLogInterceptor`, so this decorator alone is enough —
/// no manual logging calls needed inside the service.
export const Audited = (entity: string) => SetMetadata(AUDITED_ENTITY_KEY, entity);
