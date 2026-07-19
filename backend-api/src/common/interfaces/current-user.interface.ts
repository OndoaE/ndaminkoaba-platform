import { UserRole } from '@prisma/client';

export interface ICurrentUser {
  userId: string;
  email: string;
  role: UserRole;
}
