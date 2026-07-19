import { IsBoolean, IsOptional, IsString, MinLength } from 'class-validator';

export class CreateLanguageDto {
  @IsString()
  @MinLength(2)
  name: string;

  @IsString()
  @MinLength(2)
  code: string;

  @IsOptional()
  @IsString()
  country?: string;

  @IsOptional()
  @IsString()
  flagUrl?: string;

  @IsOptional()
  @IsBoolean()
  isActive?: boolean;
}