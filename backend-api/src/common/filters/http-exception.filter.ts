import {
  ArgumentsHost,
  Catch,
  ExceptionFilter,
  HttpException,
  HttpStatus,
} from '@nestjs/common';

// Duck-typed rather than `instanceof Prisma.PrismaClientKnownRequestError` —
// under ts-node's hot-reload, the running process can end up with two
// separate module instances of @prisma/client, which breaks `instanceof`
// checks even though the object really is a Prisma error at runtime.
function isPrismaKnownRequestError(
  exception: unknown,
): exception is { code: string } {
  return (
    typeof exception === 'object' &&
    exception !== null &&
    'code' in exception &&
    typeof (exception as { code: unknown }).code === 'string' &&
    (exception as { code: string }).code.startsWith('P')
  );
}

// Some constraint violations (e.g. an explicit `RESTRICT` FK, which this
// schema uses everywhere since no `onDelete` is set) don't map to Prisma's
// own P-codes and surface as a generic PrismaClientUnknownRequestError whose
// only useful signal is the underlying Postgres error text.
function isForeignKeyViolation(exception: unknown): boolean {
  const message = exception instanceof Error ? exception.message : '';
  return (
    message.includes('foreign key constraint') ||
    message.includes('violates RESTRICT')
  );
}

@Catch()
export class HttpExceptionFilter implements ExceptionFilter {
  catch(exception: unknown, host: ArgumentsHost) {
    const ctx = host.switchToHttp();
    const response = ctx.getResponse();
    const request = ctx.getRequest();

    const { status, errorResponse } = this.resolve(exception);

    if (status === HttpStatus.INTERNAL_SERVER_ERROR) {
      // Anything that reaches here is a genuine bug or infra failure — log
      // it server-side since the client only ever sees a generic message.
      // eslint-disable-next-line no-console
      console.error(exception);
    }

    response.status(status).json({
      success: false,
      statusCode: status,
      path: request.url,
      error: errorResponse,
      timestamp: new Date().toISOString(),
    });
  }

  private resolve(exception: unknown): { status: number; errorResponse: unknown } {
    if (exception instanceof HttpException) {
      return { status: exception.getStatus(), errorResponse: exception.getResponse() };
    }

    // Prisma throws its own error classes for DB-level failures (FK
    // violations, unique constraints, missing rows) — without this they'd
    // leak as a bare 500 with no useful message.
    if (isPrismaKnownRequestError(exception)) {
      if (exception.code === 'P2003') {
        return {
          status: HttpStatus.CONFLICT,
          errorResponse: {
            statusCode: HttpStatus.CONFLICT,
            error: 'Conflict',
            message:
              'Cannot complete this action — other records still depend on this item. Remove those first.',
          },
        };
      }

      if (exception.code === 'P2002') {
        return {
          status: HttpStatus.CONFLICT,
          errorResponse: {
            statusCode: HttpStatus.CONFLICT,
            error: 'Conflict',
            message: 'A record with these details already exists.',
          },
        };
      }

      if (exception.code === 'P2025') {
        return {
          status: HttpStatus.NOT_FOUND,
          errorResponse: {
            statusCode: HttpStatus.NOT_FOUND,
            error: 'Not Found',
            message: 'The requested record was not found.',
          },
        };
      }
    }

    if (isForeignKeyViolation(exception)) {
      return {
        status: HttpStatus.CONFLICT,
        errorResponse: {
          statusCode: HttpStatus.CONFLICT,
          error: 'Conflict',
          message:
            'Cannot complete this action — other records still depend on this item. Remove those first.',
        },
      };
    }

    return {
      status: HttpStatus.INTERNAL_SERVER_ERROR,
      errorResponse: 'Internal server error',
    };
  }
}