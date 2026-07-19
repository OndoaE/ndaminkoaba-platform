import { IsOptional, IsString, IsUUID } from 'class-validator';
import { PaginationDto } from '../../../common/dto/pagination.dto';

export class QueryPronunciationDto extends PaginationDto {
  @IsOptional()
  @IsUUID()
  vocabularyId?: string;

  @IsOptional()
  @IsString()
  dialect?: string;
}