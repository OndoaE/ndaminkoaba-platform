import { IsOptional, IsUUID } from 'class-validator';
import { PaginationDto } from '../../../common/dto/pagination.dto';

export class QueryLessonImageDto extends PaginationDto {
  @IsOptional()
  @IsUUID()
  lessonId?: string;
}
