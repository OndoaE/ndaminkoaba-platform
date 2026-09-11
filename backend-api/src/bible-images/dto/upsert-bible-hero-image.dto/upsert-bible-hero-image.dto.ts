import { IsNotEmpty, IsString } from 'class-validator';

export class UpsertBibleHeroImageDto {
  @IsString()
  @IsNotEmpty()
  languageId: string;

  @IsString()
  @IsNotEmpty()
  imageUrl: string;
}
