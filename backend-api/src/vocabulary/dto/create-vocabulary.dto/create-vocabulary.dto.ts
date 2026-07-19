import { Level } from '@prisma/client';
import { IsEnum, IsOptional, IsString, IsUUID, MinLength } from 'class-validator';

export class CreateVocabularyDto {
  @IsString()
  @MinLength(1)
  word: string;

  @IsUUID()
  languageId: string;

  @IsOptional()
  @IsString()
  frenchMeaning?: string;

  @IsOptional()
  @IsString()
  englishMeaning?: string;

  @IsOptional()
  @IsString()
  partOfSpeech?: string;

  @IsOptional()
  @IsString()
  exampleSentence?: string;

  @IsOptional()
  @IsString()
  exampleTranslation?: string;

  @IsOptional()
  @IsString()
  frenchExampleTranslation?: string;

  @IsOptional()
  @IsEnum(Level)
  difficulty?: Level;

  @IsOptional()
  @IsString()
  audioUrl?: string;

  @IsOptional()
  @IsString()
  imageUrl?: string;

  @IsOptional()
  @IsUUID()
  lessonId?: string;

  @IsOptional()
  @IsUUID()
  categoryId?: string;
}