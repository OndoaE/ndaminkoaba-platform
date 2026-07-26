import { IsString, MinLength } from 'class-validator';

export class CreateLessonCommentDto {
  @IsString()
  @MinLength(1)
  text: string;
}
