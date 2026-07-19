import { IsNotEmpty } from 'class-validator';

export class FacebookLoginDto {
  @IsNotEmpty()
  accessToken: string;
}
