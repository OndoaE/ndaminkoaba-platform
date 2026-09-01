import { BookCategory, Level } from '@prisma/client';
import { IsBoolean, IsEnum, IsIn, IsInt, IsOptional, IsString, IsUUID, Min } from 'class-validator';

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
  frenchDescription?: string;

  @IsOptional()
  @IsString()
  coverUrl?: string;

  /// A book can be created with neither a file nor pages — pages are added
  /// afterward via the book-pages module. Both optional, mirroring how a
  /// Lesson starts with zero blocks.
  @IsOptional()
  @IsString()
  fileUrl?: string;

  @IsOptional()
  @IsIn(['pdf', 'epub'])
  fileType?: string;

  @IsOptional()
  @IsEnum(BookCategory)
  category?: BookCategory;

  @IsOptional()
  @IsEnum(Level)
  level?: Level;

  @IsOptional()
  @IsInt()
  @Min(1)
  readingTimeMinutes?: number;

  @IsOptional()
  @IsInt()
  @Min(0)
  recommendedAge?: number;

  @IsOptional()
  @IsBoolean()
  hasImages?: boolean;

  @IsOptional()
  @IsInt()
  @Min(1)
  pageCount?: number;
}
