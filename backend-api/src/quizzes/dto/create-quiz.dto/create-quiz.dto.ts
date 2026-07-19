import { IsInt, IsOptional, IsString, IsUUID, Min, MinLength } from 'class-validator';

export class CreateQuizDto {
  @IsString()
  @MinLength(3)
  title: string;

  @IsOptional()
  @IsString()
  description?: string;

  @IsOptional()
  @IsString()
  frenchTitle?: string;

  @IsOptional()
  @IsString()
  frenchDescription?: string;

  @IsOptional()
  @IsInt()
  @Min(1)
  passingScore?: number;

  @IsUUID()
  lessonId: string;
}