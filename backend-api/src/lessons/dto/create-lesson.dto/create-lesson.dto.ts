import { Level, LessonStatus } from '@prisma/client';
import {
  IsArray,
  IsBoolean,
  IsEnum,
  IsInt,
  IsOptional,
  IsString,
  IsUUID,
  Min,
  MinLength,
} from 'class-validator';

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

  // Mock two-speaker dialogue for the lesson screen's "In Conversation"
  // block: array of {speaker, text, frenchText?}.
  @IsOptional()
  @IsArray()
  conversationJson?: Record<string, any>[];

  @IsOptional()
  @IsEnum(LessonStatus)
  status?: LessonStatus;

  @IsOptional()
  @IsBoolean()
  generatedByAi?: boolean;

  @IsOptional()
  @IsUUID()
  reviewerId?: string;

  @IsOptional()
  @IsEnum(Level)
  difficulty?: Level;

  @IsOptional()
  @IsString()
  lessonType?: string;

  @IsOptional()
  @IsUUID()
  prerequisiteLessonId?: string;

  @IsOptional()
  @IsString()
  visibility?: string;

  @IsOptional()
  @IsString()
  completionRule?: string;

  @IsOptional()
  @IsString()
  category?: string;

  @IsOptional()
  @IsInt()
  @Min(1)
  estimatedMinutes?: number;

  @IsOptional()
  @IsString()
  coverImageUrl?: string;

  @IsOptional()
  @IsArray()
  @IsString({ each: true })
  learningObjectives?: string[];

  @IsOptional()
  @IsArray()
  @IsString({ each: true })
  outcomes?: string[];
}