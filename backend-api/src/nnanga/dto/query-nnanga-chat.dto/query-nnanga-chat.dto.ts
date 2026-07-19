import { IsOptional, IsUUID } from 'class-validator';
import { PaginationDto } from '../../../common/dto/pagination.dto';

export class QueryNnangaChatDto extends PaginationDto {
  @IsOptional()
  @IsUUID()
  userId?: string;
}