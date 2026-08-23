import { IsInt, IsOptional, IsString, IsUUID, Min, MinLength } from 'class-validator';

export class CreateSyllabaryEntryDto {
  @IsOptional()
  @IsString()
  consonant?: string;

  @IsString()
  @MinLength(1)
  vowel: string;

  @IsString()
  @MinLength(1)
  syllable: string;

  @IsOptional()
  @IsString()
  exampleWord?: string;

  @IsOptional()
  @IsString()
  translation?: string;

  @IsOptional()
  @IsString()
  exampleSentence?: string;

  @IsInt()
  @Min(0)
  orderNumber: number;

  @IsUUID()
  languageId: string;
}
