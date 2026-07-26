import { IsOptional, IsString, IsUUID, MinLength, ValidateIf } from 'class-validator';

export class CreateNnangaChatDto {
  // Always overridden with the authenticated user's id in the controller —
  // optional here so a normal client request (which never sends this) isn't
  // rejected by validation before it reaches the controller.
  @IsOptional()
  @IsUUID()
  userId?: string;

  // Required unless a voice message (audioUrl) was sent instead — the
  // service transcribes audioUrl into prompt text before running the usual
  // pipeline, so exactly one of the two must be present.
  @ValidateIf((dto) => !dto.audioUrl)
  @IsString()
  @MinLength(2)
  prompt: string;

  // Learner voice message, already uploaded via POST /uploads/audio.
  @IsOptional()
  @IsString()
  audioUrl?: string;

  @IsOptional()
  @IsUUID()
  enrollmentId?: string;

  @IsOptional()
  @IsUUID()
  lessonId?: string;

  @IsOptional()
  @IsUUID()
  vocabularyId?: string;

  // The learner's current learning language — used to scope local-knowledge
  // search and to tell Nnanga which language it's tutoring in. Optional so
  // older clients don't get rejected; falls back to general knowledge only
  // (no local-content grounding) when omitted.
  @IsOptional()
  @IsUUID()
  languageId?: string;
}