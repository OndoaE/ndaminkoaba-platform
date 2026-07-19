import { IsOptional, IsString, IsUUID, MinLength } from 'class-validator';

export class CreateKnowledgeTextDto {
  @IsString()
  @MinLength(1)
  text: string;

  @IsUUID()
  languageId: string;

  @IsOptional()
  @IsString()
  translation?: string;
}
