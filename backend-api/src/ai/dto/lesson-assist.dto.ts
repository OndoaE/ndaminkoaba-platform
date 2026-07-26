import { IsEnum, IsOptional, IsString, MinLength } from 'class-validator';

export enum LessonAssistAction {
  GENERATE_EXAMPLES = 'GENERATE_EXAMPLES',
  CREATE_QUIZ = 'CREATE_QUIZ',
  SIMPLIFY_CONTENT = 'SIMPLIFY_CONTENT',
  CHECK_TRANSLATIONS = 'CHECK_TRANSLATIONS',
}

export class LessonAssistDto {
  @IsEnum(LessonAssistAction)
  action: LessonAssistAction;

  @IsString()
  @MinLength(1)
  lessonContent: string;

  @IsOptional()
  @IsString()
  frenchContent?: string;

  // Free-text instruction from the "Ask AI to improve this lesson…" input.
  @IsOptional()
  @IsString()
  instruction?: string;
}
