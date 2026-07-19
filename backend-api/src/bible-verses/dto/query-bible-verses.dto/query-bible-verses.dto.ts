import { Type } from 'class-transformer';
import { IsInt, IsOptional, IsString, IsUUID } from 'class-validator';

export class QueryBibleVersesDto {
  @IsOptional()
  @IsString()
  book?: string;

  @IsOptional()
  @Type(() => Number)
  @IsInt()
  chapter?: number;

  @IsOptional()
  @IsString()
  version?: string;

  @IsOptional()
  @IsUUID()
  languageId?: string;
}
