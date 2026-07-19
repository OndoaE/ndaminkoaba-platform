import { IsString, MinLength } from 'class-validator';

export class BroadcastNotificationDto {
  @IsString()
  @MinLength(3)
  title: string;

  @IsString()
  @MinLength(5)
  message: string;
}
