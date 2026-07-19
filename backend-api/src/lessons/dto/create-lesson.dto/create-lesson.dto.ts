import { IsInt, IsOptional, IsString, IsUUID, Min, MinLength } from 'class-validator';

export class CreateLessonDto {
  @IsString()
  @MinLength(3)
  title: string;

  @IsOptional()
  @IsString()
  summary?: string;

  @IsString()
  @MinLength(10)
  content: string;

  @IsOptional()
  @IsString()
  frenchTitle?: string;

  @IsOptional()
  @IsString()
  frenchSummary?: string;

  @IsOptional()
  @IsString()
  frenchContent?: string;

  @IsOptional()
  @IsString()
  audioUrl?: string;

  @IsOptional()
  @IsString()
  videoUrl?: string;

  @IsInt()
  @Min(1)
  orderNumber: number;

  @IsUUID()
  moduleId: string;
}