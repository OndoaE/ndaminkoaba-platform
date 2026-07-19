import {
  IsInt,
  IsOptional,
  IsString,
  IsUUID,
  Min,
  MinLength,
} from 'class-validator';

export class CreateCourseModuleDto {
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

  @IsInt()
  @Min(1)
  orderNumber: number;

  @IsUUID()
  courseId: string;
}