import { IsInt, IsOptional, IsString, IsUUID, Min, MinLength } from 'class-validator';

export class CreateLessonImageDto {
  @IsString()
  imageUrl: string;

  @IsString()
  @MinLength(1)
  word: string;

  @IsOptional()
  @IsString()
  caption?: string;

  @IsOptional()
  @IsInt()
  @Min(1)
  orderNumber?: number;

  @IsUUID()
  lessonId: string;
}
