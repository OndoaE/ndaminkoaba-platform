import { IsOptional, IsString, IsUUID, MinLength } from 'class-validator';

export class CreateDailyVerseDto {
  @IsString()
  @MinLength(1)
  text: string;

  @IsUUID()
  languageId: string;

  @IsOptional()
  @IsString()
  englishText?: string;

  @IsOptional()
  @IsString()
  frenchText?: string;

  @IsString()
  @MinLength(1)
  reference: string;
}
