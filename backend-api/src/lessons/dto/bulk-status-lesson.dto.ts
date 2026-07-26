import { LessonStatus } from '@prisma/client';
import { ArrayNotEmpty, IsArray, IsEnum, IsUUID } from 'class-validator';

export class BulkStatusLessonDto {
  @IsArray()
  @ArrayNotEmpty()
  @IsUUID('4', { each: true })
  ids: string[];

  @IsEnum(LessonStatus)
  status: LessonStatus;
}
