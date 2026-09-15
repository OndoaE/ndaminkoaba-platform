import { IsInt, IsNotEmpty, IsString, Min } from 'class-validator';

export class UpsertBibleChapterAudioDto {
  @IsString()
  @IsNotEmpty()
  languageId: string;

  @IsString()
  @IsNotEmpty()
  book: string;

  @IsInt()
  @Min(1)
  chapter: number;

  @IsString()
  @IsNotEmpty()
  audioUrl: string;
}
