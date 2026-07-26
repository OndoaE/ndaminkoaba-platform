import { IsOptional, IsString, IsUUID, MinLength } from 'class-validator';

export class CreatePronunciationAttemptDto {
  @IsString()
  @MinLength(1)
  targetText: string;

  // The audio was already uploaded via POST /uploads/audio; this is the URL
  // that returned, e.g. /uploads/audio/<uuid>.webm.
  @IsString()
  audioUrl: string;

  @IsOptional()
  @IsUUID()
  vocabularyId?: string;

  @IsOptional()
  @IsUUID()
  lessonId?: string;
}
