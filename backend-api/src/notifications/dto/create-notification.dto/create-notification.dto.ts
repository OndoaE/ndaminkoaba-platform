import { IsString, IsUUID, MinLength } from 'class-validator';

export class CreateNotificationDto {
  @IsUUID()
  userId: string;

  @IsString()
  @MinLength(3)
  title: string;

  @IsString()
  @MinLength(5)
  message: string;
}