import { Injectable } from '@nestjs/common';
import { ThrottlerGuard } from '@nestjs/throttler';

import { resolveClientIp } from './client-ip';

/// ThrottlerGuard that counts requests per real client address (see
/// resolveClientIp) rather than per whichever proxy hop Express reports.
@Injectable()
export class ClientIpThrottlerGuard extends ThrottlerGuard {
  protected getTracker(req: Record<string, any>): Promise<string> {
    return Promise.resolve(resolveClientIp(req));
  }
}
