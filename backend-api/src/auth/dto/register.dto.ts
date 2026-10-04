import { IsEmail, IsNotEmpty } from 'class-validator';
import { IsStrongPassword } from '../../common/validators/password.validator';

// Deliberately has no `role` field: self-registration always creates a
// LEARNER. Staff accounts are created by an admin (POST /users) or promoted
// via PATCH /users/:id, both of which are ADMIN-only and audited.
export class RegisterDto {
  @IsNotEmpty()
  fullName: string;

  @IsEmail()
  email: string;

  @IsStrongPassword()
  password: string;
}
