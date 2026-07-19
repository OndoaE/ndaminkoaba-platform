import { IsOptional, IsString, IsUUID, MinLength } from 'class-validator';

export class CreatePronunciationDto {
  @IsUUID()
  vocabularyId: string;

  @IsString()
  @MinLength(3)
  audioUrl: string;

  @IsOptional()
  @IsString()
  speakerName?: string;

  @IsOptional()
  @IsString()
  dialect?: string;
}