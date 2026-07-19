import { IsOptional, IsString, IsUUID, MinLength } from 'class-validator';

export class CreateDailyWordDto {
  @IsString()
  @MinLength(1)
  word: string;

  @IsUUID()
  languageId: string;

  @IsOptional()
  @IsString()
  englishMeaning?: string;

  @IsOptional()
  @IsString()
  frenchMeaning?: string;

  @IsOptional()
  @IsString()
  usageHint?: string;
}
