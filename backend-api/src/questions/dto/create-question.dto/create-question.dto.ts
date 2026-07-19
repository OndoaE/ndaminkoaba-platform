import { QuestionType } from '@prisma/client';
import {
  IsEnum,
  IsOptional,
  IsString,
  IsUUID,
  MinLength,
} from 'class-validator';

export class CreateQuestionDto {
  @IsString()
  @MinLength(5)
  questionText: string;

  @IsOptional()
  @IsString()
  frenchQuestionText?: string;

  @IsOptional()
  @IsEnum(QuestionType)
  type?: QuestionType;

  @IsOptional()
  @IsString()
  explanation?: string;

  @IsOptional()
  @IsString()
  frenchExplanation?: string;

  @IsUUID()
  quizId: string;
}