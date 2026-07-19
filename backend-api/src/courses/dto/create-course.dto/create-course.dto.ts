import { CourseStatus, Level } from '@prisma/client';
import {
  IsEnum,
  IsInt,
  IsOptional,
  IsString,
  IsUUID,
  Min,
  MinLength,
} from 'class-validator';

export class CreateCourseDto {
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
  @IsString()
  thumbnailUrl?: string;

  @IsEnum(Level)
  level: Level;

  @IsOptional()
  @IsEnum(CourseStatus)
  status?: CourseStatus;

  @IsOptional()
  @IsInt()
  @Min(1)
  estimatedHours?: number;

  @IsUUID()
  languageId: string;

  @IsOptional()
  @IsUUID()
  teacherId?: string;
}
