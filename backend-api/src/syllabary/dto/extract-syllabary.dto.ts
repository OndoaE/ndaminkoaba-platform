import { IsString, IsUUID, MinLength } from 'class-validator';

export class ExtractSyllabaryDto {
  /// Raw base64 image data, no "data:image/...;base64," prefix.
  @IsString()
  @MinLength(1)
  imageBase64: string;

  /// e.g. "image/jpeg", "image/png".
  @IsString()
  @MinLength(1)
  mimeType: string;

  @IsUUID()
  languageId: string;
}
