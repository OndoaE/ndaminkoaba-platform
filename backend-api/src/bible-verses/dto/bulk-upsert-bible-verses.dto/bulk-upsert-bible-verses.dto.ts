import { Type } from 'class-transformer';
import {
  IsArray,
  IsInt,
  IsOptional,
  IsString,
  IsUUID,
  Min,
  MinLength,
  ValidateNested,
} from 'class-validator';

export class BibleVerseInputDto {
  @IsString()
  @MinLength(1)
  book: string;

  @IsInt()
  @Min(1)
  chapter: number;

  @IsInt()
  @Min(1)
  verse: number;

  @IsString()
  @MinLength(1)
  text: string;

  @IsOptional()
  @IsString()
  englishText?: string;

  @IsOptional()
  @IsString()
  frenchText?: string;

  @IsOptional()
  @IsString()
  version?: string;
}

export class BulkUpsertBibleVersesDto {
  @IsUUID()
  languageId: string;

  @IsArray()
  @ValidateNested({ each: true })
  @Type(() => BibleVerseInputDto)
  verses: BibleVerseInputDto[];
}
