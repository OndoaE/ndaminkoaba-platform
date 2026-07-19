import { IsOptional, IsUUID } from 'class-validator';
import { PaginationDto } from '../../../common/dto/pagination.dto';

export class QueryChoiceDto extends PaginationDto {
  @IsOptional()
  @IsUUID()
  questionId?: string;
}