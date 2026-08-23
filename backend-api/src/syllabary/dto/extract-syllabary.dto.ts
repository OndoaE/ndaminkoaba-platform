import { IsOptional, IsString, IsUUID } from 'class-validator';

/// Exactly one content source is expected: [imageBase64] (photographed
/// chart, sent to a vision model), [documentBase64] (an uploaded
/// PDF/Word/Excel/txt file, text-extracted then sent to a text model), or
/// [text] (pasted/typed content, sent straight to a text model) — see
/// `SyllabaryService.extract`'s dispatch logic. [mimeType] is required
/// alongside [imageBase64] or [documentBase64], not for [text].
export class ExtractSyllabaryDto {
  /// Raw base64 image data, no "data:image/...;base64," prefix.
  @IsOptional()
  @IsString()
  imageBase64?: string;

  /// Raw base64 document data (PDF/Word/Excel/txt), no data-URI prefix.
  @IsOptional()
  @IsString()
  documentBase64?: string;

  /// Pasted or typed text/table content, sent directly to a text model.
  @IsOptional()
  @IsString()
  text?: string;

  /// e.g. "image/jpeg", "application/pdf". Required with imageBase64 or
  /// documentBase64; unused for text.
  @IsOptional()
  @IsString()
  mimeType?: string;

  @IsUUID()
  languageId: string;
}
