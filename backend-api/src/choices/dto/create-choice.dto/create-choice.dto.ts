import { IsBoolean, IsOptional, IsString, IsUUID, MinLength } from 'class-validator';

export class CreateChoiceDto {
  @IsString()
  @MinLength(1)
  choiceText: string;

  @IsOptional()
  @IsString()
  frenchChoiceText?: string;

  @IsBoolean()
  isCorrect: boolean;

  @IsUUID()
  questionId: string;
}