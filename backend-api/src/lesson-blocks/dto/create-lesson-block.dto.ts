import { LessonBlockStatus, LessonBlockType } from '@prisma/client';
import {
  IsArray,
  IsEnum,
  IsInt,
  IsOptional,
  IsString,
  IsUUID,
  Min,
} from 'class-validator';

export class CreateLessonBlockDto {
  @IsUUID()
  lessonId: string;

  @IsInt()
  @Min(1)
  orderNumber: number;

  @IsEnum(LessonBlockType)
  type: LessonBlockType;

  @IsOptional()
  @IsEnum(LessonBlockStatus)
  status?: LessonBlockStatus;

  // Reused per block type: e.g. the eyebrow label ("INTRODUCTION") for TEXT
  // blocks, or the required LessonImage.word label for IMAGE blocks.
  @IsOptional()
  @IsString()
  titleLabel?: string;

  @IsOptional()
  @IsString()
  textContent?: string;

  @IsOptional()
  @IsString()
  frenchTextContent?: string;

  @IsOptional()
  @IsUUID()
  vocabularyId?: string;

  // The image/audio/video asset URL, for IMAGE/AUDIO/VIDEO blocks.
  @IsOptional()
  @IsString()
  mediaUrl?: string;

  @IsOptional()
  @IsArray()
  dialogueJson?: Record<string, any>[];

  @IsOptional()
  exerciseJson?: Record<string, any>;

  @IsOptional()
  @IsUUID()
  quizId?: string;
}
