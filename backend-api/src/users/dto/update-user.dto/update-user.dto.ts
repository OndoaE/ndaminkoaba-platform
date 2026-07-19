import { IsOptional, IsString } from 'class-validator';
import { IsStrongPassword } from '../../../common/validators/password.validator';

export class UpdateUserDto {
  @IsOptional()
  @IsString()
  fullName?: string;

  @IsOptional()
  @IsStrongPassword()
  password?: string;
}
