import { SetMetadata } from '@nestjs/common';

export const IS_PUBLIC_KEY = 'isPublic';

/**
 * Marks a route as intentionally public. Not currently read by any guard
 * (every controller in this app applies `@UseGuards(JwtAuthGuard)` explicitly
 * rather than a global guard), but kept available/consistent for the day this
 * app switches to a global `JwtAuthGuard` + `Reflector`-based allow-list.
 */
export const Public = () => SetMetadata(IS_PUBLIC_KEY, true);
