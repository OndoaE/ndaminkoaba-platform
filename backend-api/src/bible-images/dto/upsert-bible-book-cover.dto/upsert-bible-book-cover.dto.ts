import { IsNotEmpty, IsString } from 'class-validator';

export class UpsertBibleBookCoverDto {
  @IsString()
  @IsNotEmpty()
  languageId: string;

  @IsString()
  @IsNotEmpty()
  bookKey: string;

  @IsString()
  @IsNotEmpty()
  coverUrl: string;
}
