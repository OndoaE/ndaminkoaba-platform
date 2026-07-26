import {
  CourseEnrollmentMode,
  CourseStatus,
  CourseVisibility,
  Level,
} from '@prisma/client';
import {
  IsArray,
  IsBoolean,
  IsDateString,
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
  subtitle?: string;

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

  @IsOptional()
  @IsString()
  category?: string;

  @IsOptional()
  @IsArray()
  @IsString({ each: true })
  tags?: string[];

  @IsOptional()
  @IsArray()
  @IsString({ each: true })
  learningObjectives?: string[];

  @IsOptional()
  @IsArray()
  @IsString({ each: true })
  supportLanguageCodes?: string[];

  @IsOptional()
  @IsEnum(CourseVisibility)
  visibility?: CourseVisibility;

  @IsOptional()
  @IsEnum(CourseEnrollmentMode)
  enrollmentMode?: CourseEnrollmentMode;

  @IsOptional()
  @IsBoolean()
  issueCertificate?: boolean;

  @IsOptional()
  @IsDateString()
  publicationDate?: string;

  @IsOptional()
  @IsUUID()
  reviewerId?: string;

  @IsOptional()
  @IsUUID()
  prerequisiteCourseId?: string;
}
