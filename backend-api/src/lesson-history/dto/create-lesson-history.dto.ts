import { IsUUID } from 'class-validator';

export class CreateLessonHistoryDto {
  @IsUUID()
  userId: string;

  @IsUUID()
  lessonId: string;
}
