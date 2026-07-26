import { ArrayNotEmpty, IsArray, IsUUID } from 'class-validator';

export class ReorderLessonBlocksDto {
  @IsUUID()
  lessonId: string;

  // Block ids in their new display order — orderNumber becomes index+1.
  @IsArray()
  @ArrayNotEmpty()
  @IsUUID('4', { each: true })
  orderedIds: string[];
}
