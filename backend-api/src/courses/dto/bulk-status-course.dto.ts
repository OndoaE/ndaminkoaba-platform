import { CourseStatus } from '@prisma/client';
import { ArrayNotEmpty, IsArray, IsEnum, IsUUID } from 'class-validator';

export class BulkStatusCourseDto {
  @IsArray()
  @ArrayNotEmpty()
  @IsUUID('4', { each: true })
  ids: string[];

  @IsEnum(CourseStatus)
  status: CourseStatus;
}
