import { IsIn, IsOptional, IsString, IsUUID } from 'class-validator';

export class CreateBookDto {
  @IsString()
  title: string;

  @IsUUID()
  languageId: string;

  @IsOptional()
  @IsString()
  author?: string;

  @IsOptional()
  @IsString()
  description?: string;

  @IsOptional()
  @IsString()
  coverUrl?: string;

  @IsString()
  fileUrl: string;

  @IsIn(['pdf', 'epub'])
  fileType: string;
}
