import { UserRole } from '@prisma/client';

/** Shape of the payload encoded into the JWT (see AuthService.login). */
export interface IJwtPayload {
  sub: string;
  email: string;
  role: UserRole;
}
